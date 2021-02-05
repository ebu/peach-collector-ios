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

@property (nonatomic, strong) PeachCollectorDataStore *dataStore;
@property (nonatomic, strong) PeachCollectorQueue *queue;
@property (nonatomic, strong) NSArray<NSString *> *flushableEventTypes;
@property (nonatomic) NSInteger sessionStartTimestamp;
@property (nonatomic) NSInteger lastRecordedEventTimestamp;
@property (nonatomic) NSTimer *sessionHeartbeatTimer;

@end

@implementation PeachCollector
static NSString *_implementationVersion = @"0";
static NSString *_userID = nil;
static NSString *_appID = nil;
static BOOL _userIsLoggedIn = false;
static NSString *_deviceID = nil;
static NSInteger _inactivityInterval = -1;
static NSInteger _maxStoredEvents = -1;
static NSInteger _maxStoredDays = -1;

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
        _deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.dataStore = [[PeachCollectorDataStore alloc] init];
        self.queue = [[PeachCollectorQueue alloc] init];
        
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
        [self.queue checkStorage];
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
    NSInteger currentTimestamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    NSInteger inactivityInterval = ((PeachCollector.inactivityInterval == -1) ? PeachCollectorDefaultInactiveSessionInterval : PeachCollector.inactivityInterval) * 1000;
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

+ (NSInteger)maximumStoredEvents
{
    return _maxStoredEvents;
}

+ (void)setMaximumStoredEvents:(NSInteger)maximumStoredEvents
{
    _maxStoredEvents = maximumStoredEvents;
    [[PeachCollector sharedCollector].queue checkStorage];
}

+ (NSInteger)maximumStorageDays
{
    return _maxStoredDays;
}

+ (void)setMaximumStorageDays:(NSInteger)maximumStorageDays
{
    _maxStoredDays = maximumStorageDays;
    [[PeachCollector sharedCollector].queue checkStorage];
}

#pragma mark - Queue management

+ (PeachCollectorDataStore *)dataStore
{
    return [PeachCollector sharedCollector].dataStore;
}

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
    [[PeachCollector dataStore] performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:nameEntity];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

        NSError *deleteError;
        [managedObjectContext executeRequest:delete error:&deleteError];
        [managedObjectContext processPendingChanges];
    } withPriority:NSOperationQueuePriorityVeryHigh completionBlock:nil];
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

+ (BOOL)shouldCollectEvents
{
    return [[PeachCollector sharedCollector] shouldCollectAnonymousEvents] || PeachCollector.deviceID || PeachCollector.userID;
}

+ (void)addEventToQueue:(PeachCollectorEvent *)event
{
    [PeachCollector sharedCollector].lastRecordedEventTimestamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    [[PeachCollector sharedCollector].queue addEvent:event];
}

+ (void)addFlushableEventType:(NSString *)eventType
{
    [PeachCollector sharedCollector].flushableEventTypes = [[PeachCollector sharedCollector].flushableEventTypes arrayByAddingObject:eventType];
}

#pragma mark - User management

+ (NSString *)deviceID
{
    return _deviceID;
}

+ (NSString *)userID
{
    return _userID;
}

+ (void)setUserID:(NSString *)userID
{
    _userID = [userID copy];
}

+ (BOOL)userIsLoggedIn
{
    return _userIsLoggedIn;
}

+ (void)setUserIsLoggedIn:(BOOL)userIsLoggedIn
{
    _userIsLoggedIn = userIsLoggedIn;
}

#pragma mark - AppID management


+ (NSString *)appID
{
    return _appID;
}

+ (void)setAppID:(NSString *)appID
{
    _appID = [appID copy];
}



@end
