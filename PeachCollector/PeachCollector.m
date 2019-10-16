//
//  PeachCollector.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollector.h"
#import "PeachCollectorQueue.h"
#import "PeachPersistentContainer.h"
#import "PeachCollectorOperation.h"
#import <UIKit/UIKit.h>

@interface PeachCollector()

@property (nonatomic, strong) PeachCollectorQueue *queue;
@property (nonatomic, strong) NSArray<NSString *> *flushableEventTypes;
@property (nonatomic) NSInteger sessionStartTimestamp;
@property (nonatomic) NSInteger lastRecordedEventTimestamp;
@property (nonatomic) NSTimer *sessionHeartbeatTimer;

@property (nonatomic, strong) NSMutableArray *operations;

@end

@implementation PeachCollector
static NSString *_implementationVersion = @"0";
static NSString *_userID = nil;
static NSInteger _inactivityInterval = -1;

#pragma mark - Versions

+ (NSString *)version
{
    NSBundle *bundle = [NSBundle bundleForClass:[PeachCollector class]];
    NSString *buildNumber = [bundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@-%@", version, buildNumber];
}

+ (NSString *)implementationVersion
{
    return _implementationVersion;
}

+ (void)setImplementationVersion:(NSString *)version
{
    _implementationVersion = [version copy];
}

#pragma mark - Initialization & Life cycle

+ (void)load{
    [PeachCollector sharedCollector];
    [[PeachCollector sharedCollector].queue resetStatuses];
}

+ (instancetype)sharedCollector
{
    static PeachCollector *s_sharedInstance = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_sharedInstance = [[PeachCollector alloc] init];
    });
    return s_sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _flushableEventTypes = @[PCEventTypeMediaStop, PCEventTypeMediaPause];
        self.queue = [[PeachCollectorQueue alloc] init];
        self.operations = [NSMutableArray array];
        
        self.sessionStartTimestamp = [[NSUserDefaults standardUserDefaults] integerForKey:PeachCollectorSessionStartTimestampKey];
        self.lastRecordedEventTimestamp = [[NSUserDefaults standardUserDefaults] integerForKey:PeachCollectorLastRecordedEventTimestampKey];
        [self checkInactivity];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
    }
    return self;
}


- (void)appDidBecomeActive:(NSNotification *)notification
{
    if (self.queue) {
        [self.queue checkPublishers];
    }
    
    if (self.sessionHeartbeatTimer) {
        [self.sessionHeartbeatTimer invalidate];
        self.sessionHeartbeatTimer = nil;
    }
    
    [self checkInactivity];
}

- (void)checkInactivity
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentTimestamp = (int)[[NSDate date] timeIntervalSince1970];
    NSInteger inactivityInterval = (PeachCollector.inactivityInterval == -1) ? PeachCollectorDefaultInactiveSessionInterval : PeachCollector.inactivityInterval;
    if (currentTimestamp - self.lastRecordedEventTimestamp > inactivityInterval) {
        self.sessionStartTimestamp = currentTimestamp;
        [userDefault setInteger:self.sessionStartTimestamp forKey:PeachCollectorSessionStartTimestampKey];
    }
    self.lastRecordedEventTimestamp = currentTimestamp;
    [userDefault setInteger:self.lastRecordedEventTimestamp forKey:PeachCollectorLastRecordedEventTimestampKey];
    
    [userDefault synchronize];
}

- (void)appWillResignActive:(NSNotification *)notification
{
    [self.queue flush];
    self.sessionHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(appIsAliveInBackground) userInfo:nil repeats:YES];
}

- (void)appIsAliveInBackground
{
    [self checkInactivity];
}

- (void)appWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.queue flush];
}

+ (NSInteger)sessionStartTimestamp
{
    return [PeachCollector sharedCollector].sessionStartTimestamp;
}

+ (NSInteger)inactivityInterval
{
    return _inactivityInterval;
}

+ (void)setInactivityInterval:(NSInteger)inactivityInterval
{
    _inactivityInterval = inactivityInterval;
}

#pragma mark - Queue management

+ (void)flush
{
    if ([[PeachCollector sharedCollector] queue]) {
        [[[PeachCollector sharedCollector] queue] flush];
    }
}

+ (void)clean
{
    if ([[PeachCollector sharedCollector] queue]) {
        [[[PeachCollector sharedCollector] queue] cleanTimers];
    }
    [PeachCollector deleteAllEntities:@"PeachCollectorEvent"];
}

+ (void)deleteAllEntities:(NSString *)nameEntity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:nameEntity];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

    NSError *deleteError;
    [[PeachCollector managedObjectContext] executeRequest:delete error:&deleteError];
    [[PeachCollector managedObjectContext] processPendingChanges];
    [PeachCollector save];
    
}


#pragma mark - Publisher management

+ (PeachCollectorPublisher *)publisherNamed:(NSString *)publisherName{
    return [[PeachCollector sharedCollector].publishers objectForKey:publisherName];
}

+ (void)setPublisher:(PeachCollectorPublisher *)publisher withUniqueName:(NSString *)publisherName
{
    [[PeachCollector sharedCollector] setPublisher:publisher forKey:publisherName];
}

- (void)setPublisher:(PeachCollectorPublisher *)publisher forKey:(NSString *)publisherName
{
    if (self.publishers == nil) {
        _publishers = @{publisherName:publisher};
    }
    else {
        NSMutableDictionary *mutablePublishers = [self.publishers mutableCopy];
        [mutablePublishers setObject:publisher forKey:publisherName];
        _publishers = [mutablePublishers copy];
    }
    // After adding a publisher, check if there are any events previously added to its queue
    // In case there are events cached, proceed with the publishing process
    [self.queue checkPublisherNamed:publisherName];
}


#pragma mark - Event management

+ (void)addEventToQueue:(PeachCollectorEvent *)event
{
    [PeachCollector sharedCollector].lastRecordedEventTimestamp = (int)[[NSDate date] timeIntervalSince1970];
    [[PeachCollector sharedCollector].queue addEvent:event];
}

+ (void)addFlushableEventType:(NSString *)eventType
{
    [PeachCollector sharedCollector].flushableEventTypes = [[PeachCollector sharedCollector].flushableEventTypes arrayByAddingObject:eventType];
}

#pragma mark - User management

+ (NSString *)userID
{
    return _userID;
}

+ (void)setUserID:(NSString *)userID
{
    _userID = [userID copy];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            NSURL *directoryURL = [[NSPersistentContainer defaultDirectoryURL] URLByAppendingPathComponent:@"PeachCollector"];
            if (! [NSFileManager.defaultManager fileExistsAtPath:directoryURL.absoluteString]) {
                NSError *err;
                if (![NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&err]) { //Create folder
                    NSLog(@"Unable to create folder at %@: %@", directoryURL, err);
                }
            }
            
            _persistentContainer = [[PeachPersistentContainer alloc] initWithName:@"PeachCollector"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    return [PeachCollector sharedCollector].persistentContainer.viewContext;
}

+ (BOOL)save{
    NSError *contextError = nil;
    if ([[PeachCollector managedObjectContext] save:&contextError] == NO) {
        [[PeachCollector managedObjectContext] rollback];
        //NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        return NO;
    }
    return YES;
}


+ (void)queueOperation:(void (^)(void))operationBlock withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    PeachCollectorOperation *operation = [PeachCollectorOperation new];
    operation.operationBlock = operationBlock;
    operation.completionBlock = completionHandler;
    

    [[PeachCollector sharedCollector].operations addObject:operation];
    if ([PeachCollector sharedCollector].operations.count == 1) {
        [[PeachCollector sharedCollector] dequeueOperation];
    }
}

- (void)dequeueOperation
{
    PeachCollectorOperation *operation = [self.operations firstObject];
    operation.operationBlock();
    operation.completionBlock(nil);
    
    if (self.operations.count > 1) {
        [self.operations removeObjectAtIndex:0];
        [self dequeueOperation];
    }
    else {
        [self.operations removeObjectAtIndex:0];
    }
}



@end
