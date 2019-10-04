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
#import <UIKit/UIKit.h>

@interface PeachCollector()

@property (nonatomic, strong) PeachCollectorConfiguration *configuration;
@property (nonatomic, strong) PeachCollectorQueue *queue;
@property (nonatomic, strong) NSArray<NSString *> *flushableEventTypes;

@end

@implementation PeachCollector

+ (void)load{
    [PeachCollector sharedCollector];
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
}

- (void)appWillResignActive:(NSNotification *)notification
{
    [self.queue flush];
}

- (void)appWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.queue flush];
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
    [self.queue checkPublishers];
}


#pragma mark - Event management

+ (void)addEventToQueue:(PeachCollectorEvent *)event
{
    [[PeachCollector sharedCollector].queue addEvent:event];
}

+ (void)addFlushableEventType:(NSString *)eventType
{
    [PeachCollector sharedCollector].flushableEventTypes = [[PeachCollector sharedCollector].flushableEventTypes arrayByAddingObject:eventType];
}

#pragma mark - User management

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    
    /*NSMutableDictionary *mutableClientInfo = [self.clientInfo mutableCopy];
    [mutableClientInfo setObject:userID forKey:@"user_id"];
    
    self.clientInfo = [mutableClientInfo copy];*/
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




@end
