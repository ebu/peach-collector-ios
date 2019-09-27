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

@end

@implementation PeachCollector

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)appDidEnterBackground:(NSNotification *)note
{
    NSLog(@"appDidEnterBackground");
}

- (void)appWillResignActive:(NSNotification *)note
{
    NSLog(@"appWillResignActive");
    [self.queue flush];
}

- (void)appWillTerminate:(NSNotification *)note
{
    NSLog(@"appWillTerminate");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (void)startWithConfiguration:(PeachCollectorConfiguration *)configuration
{
    [PeachCollector sharedCollector].configuration = configuration;
    [PeachCollector defaultPublisher];
    [PeachCollector sharedCollector].queue = [[PeachCollectorQueue alloc] init];
}


#pragma mark - Publisher management

+ (PeachCollectorPublisher *)defaultPublisher
{
    if ([[PeachCollector sharedCollector].publishers objectForKey:PeachCollectorDefaultPublisherName] == nil) {
        PeachCollectorConfiguration * config = [PeachCollector sharedCollector].configuration;
        PeachCollectorPublisher *defaultPublisher = [[PeachCollectorPublisher alloc] initWithServiceURL:config.serviceURL interval:config.recommandedSendingInterval maxEvents:config.recommandedMaxSendingEvents gotBackOnlinePolicy:config.gotBackOnlinePolicy];
        [[PeachCollector sharedCollector] setPublisher:defaultPublisher forKey:PeachCollectorDefaultPublisherName];
    }
    
    return [[PeachCollector sharedCollector].publishers objectForKey:PeachCollectorDefaultPublisherName];
}

+ (PeachCollectorPublisher *)publisherNamed:(NSString *)publisherName{
    return [[PeachCollector sharedCollector].publishers objectForKey:publisherName];
}

+ (void)addPublisher:(PeachCollectorPublisher *)publisher withName:(NSString *)publisherName
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
