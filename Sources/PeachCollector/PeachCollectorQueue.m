//
//  PeachCollectorQueue.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorQueue.h"
#import "PeachCollector.h"
#import "PeachCollectorDataFormat.h"
#import "PeachCollectorReachability.h"
@import UIKit;
@import UserNotifications;


@interface PeachCollectorQueue()

@property (nonatomic, strong) NSMutableDictionary *publisherTimers;
@property (nonatomic, strong) NSMutableDictionary *numberOfFailures;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSInteger ongoingRequests;

@end


@implementation PeachCollectorQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.publisherTimers = [NSMutableDictionary new];
        self.numberOfFailures = [NSMutableDictionary new];
        self.backgroundTask = UIBackgroundTaskInvalid;
        
        [[PeachCollectorReachability internetReachability] startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:PeachCollectorReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)reachabilityChanged
{
    if ([[PeachCollectorReachability internetReachability] isReachable])
    {
        NSMutableArray *publishersToFlush = [[self.numberOfFailures allKeys] copy];
        for (NSString *publisher in publishersToFlush) {
            [self sendEventsToPublisherNamed:publisher];
        }
    }
}

- (void)resetStatuses
{
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus allEventsStatusesInContext:managedObjectContext];
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            eventStatus.status = PCEventStatusQueued;
        }
    } withPriority:NSOperationQueuePriorityHigh completionBlock:nil];
}

- (void)checkStorage
{
    NSInteger maxStoredEvents = (PeachCollector.maximumStoredEvents == -1) ? PeachCollectorDefaultMaxStoredEvents : PeachCollector.maximumStoredEvents;
    [[PeachCollector dataStore] performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PeachCollectorEvent"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
        [request setSortDescriptors:@[sortDescriptor]];
        request.fetchOffset = maxStoredEvents;
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

        NSError *deleteError;
        [managedObjectContext executeRequest:delete error:&deleteError];
        [managedObjectContext processPendingChanges];
    } withPriority:NSOperationQueuePriorityHigh completionBlock:nil];
    
    [[PeachCollector dataStore] performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        NSInteger maxStorageDays = (PeachCollector.maximumStorageDays == -1) ? PeachCollectorDefaultMaxStorageDays : PeachCollector.maximumStorageDays;
        NSDate *limitDate = [[NSDate date] dateByAddingTimeInterval: - (maxStorageDays * 60 * 60 * 24)];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PeachCollectorEvent"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"creationDate <= %@", limitDate]];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

        NSError *deleteError;
        [managedObjectContext executeRequest:delete error:&deleteError];
        [managedObjectContext processPendingChanges];
    } withPriority:NSOperationQueuePriorityHigh completionBlock:nil];
}

- (void)addEvent:(PeachCollectorEvent *)event
{
    __block BOOL shouldBeFlushedWhenReceivedInBackgroundState;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        PeachCollectorEvent *addedEvent = [managedObjectContext objectWithID:event.objectID];
        for (NSString *publisherID in [PeachCollector sharedCollector].publishers.allKeys) {
            PeachCollectorPublisher *publisher = [[PeachCollector sharedCollector].publishers objectForKey:publisherID];
            if ([publisher shouldProcessEvent:addedEvent]) {
                PeachCollectorPublisherEventStatus *eventStatus = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorPublisherEventStatus" inManagedObjectContext:managedObjectContext];
                eventStatus.status = PCEventStatusQueued;
                eventStatus.publisherName = publisherID;
                eventStatus.event = addedEvent;
            }
        }
        shouldBeFlushedWhenReceivedInBackgroundState = [addedEvent shouldBeFlushedWhenReceivedInBackgroundState];
    } withPriority:NSOperationQueuePriorityHigh completionBlock:^(NSError * _Nullable error) {
        if (error){
            if ([[PeachCollector sharedCollector] isUnitTesting]) NSLog(@"PeachCollector DB Error: %@", [error description]);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive
                && shouldBeFlushedWhenReceivedInBackgroundState) {
                [self flush];
            }
        
            [self checkPublishers];
        });
    }];
}

- (void)checkPublishers
{
    for (NSString *publisherName in [PeachCollector sharedCollector].publishers.allKeys) {
        [self checkPublisherNamed:publisherName];
    }
}

- (void)checkPublisherNamed:(NSString *)publisherName
{
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
    
    [PeachCollector.dataStore performBackgroundReadTask:^id _Nullable(NSManagedObjectContext * _Nonnull managedObjectContext) {
        NSArray *pendingEventStatuses = [PeachCollectorPublisherEventStatus eventsStatusesForPublisherNamed:publisherName withStatus:PCEventStatusSentToPublisher inContext:managedObjectContext];
        if (pendingEventStatuses.count > 0) return nil;
        return [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName inContext:managedObjectContext];
    } withPriority:NSOperationQueuePriorityHigh completionBlock:^(id  _Nullable result, NSError * _Nullable error) {
        NSArray *eventsStatuses = result;
        if (result == nil || [result count] == 0) return;
        BOOL lastPublishingHasFailed = [self.numberOfFailures objectForKey:publisherName] != nil;
        BOOL hasTooManyEvents = eventsStatuses.count >= publisher.maxEventsPerBatchAfterOfflineSession;
        if (!lastPublishingHasFailed && (eventsStatuses.count >= publisher.maxEventsPerBatch || publisher.interval == 0) && !hasTooManyEvents) {
            [self sendEventsToPublisherNamed:publisherName];
        }
        else if ([self.publisherTimers objectForKey:publisherName] == nil) {
            [self startTimerForPublisherNamed:publisherName followPolicy:hasTooManyEvents];
        }
    }];
}

- (void)sendEventsToPublisherWithTimer:(NSTimer *)timer
{
    NSString *publisherName = [[timer userInfo] objectForKey:@"publisherName"];
    [self sendEventsToPublisherNamed:publisherName];
}

- (void)sendEventsToPublisherNamed:(NSString *)publisherName
{
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        // Check if there is events that are being processed by the publisher
        NSArray *pendingEventStatuses = [PeachCollectorPublisherEventStatus eventsStatusesForPublisherNamed:publisherName withStatus:PCEventStatusSentToPublisher inContext:managedObjectContext];
        if (pendingEventStatuses.count > 0) return;
        
        // Check if there is events to process for the publisher
        NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName inContext:managedObjectContext];
        if (eventsStatuses.count == 0) return;
        
        PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
        NSTimer *timer = [self.publisherTimers objectForKey:publisherName];
        if (timer) {
            [timer invalidate];
            [self.publisherTimers removeObjectForKey:publisherName];
        }
        
        NSMutableArray *events = [NSMutableArray new];
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            if (events.count < publisher.maxEventsPerBatchAfterOfflineSession) {
                [events addObject:eventStatus.event];
                eventStatus.status = PCEventStatusSentToPublisher;
            }
        }
        [self registerBackgroundTask];
        
        [publisher processEvents:events withCompletionHandler:^(NSError * _Nullable processError) {
            
            __block BOOL shouldContinueSending = NO;
            [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
                // If there are pending events for the publisher, set a flag to run a check (to either send another request or start a timer)
                NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName inContext:managedObjectContext];
                if (eventsStatuses.count && processError == nil) {
                    shouldContinueSending = YES;
                }
                
                for (PeachCollectorEvent *event in events) {
                    // Retrieve event in the current context
                    PeachCollectorEvent *currentEvent = [managedObjectContext objectWithID:event.objectID];
                    // Check the statuses of the event
                    for (PeachCollectorPublisherEventStatus *eventStatus in currentEvent.eventStatuses) {
                        // if the event has a status with the publisher, update it
                        if ([eventStatus.publisherName isEqualToString:publisherName]) {
                            eventStatus.status = (processError) ? PCEventStatusQueued : PCEventStatusPublished;
                            break;
                        }
                    }
                    // Check if all statuses of the event are `Published` and remove it if it is
                    if ([currentEvent canBeRemoved]) {
                        [managedObjectContext deleteObject:currentEvent];
                    }
                }
                
            } withPriority:NSOperationQueuePriorityHigh completionBlock:^(NSError * _Nullable error) {
                if (processError) {
                    NSNumber *numberOfFailures = [self.numberOfFailures objectForKey:publisherName];
                    numberOfFailures = (numberOfFailures == nil) ? @(1) : @(numberOfFailures.integerValue + 1);
                    [self.numberOfFailures setObject:numberOfFailures forKey:publisherName];
                    
                    [self startTimerForPublisherNamed:publisherName followPolicy:NO];
                    
                    if ([[PeachCollector sharedCollector] isUnitTesting]) {
                        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                          object:nil userInfo:@{PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Failed to publish events", publisherName]}];
                    }
                }
                else {
                    [self.numberOfFailures removeObjectForKey:publisherName];
                    if (shouldContinueSending) {
                        [self checkPublisherNamed:publisherName];
                    }
                    
                    #if TARGET_OS_IOS

                    if ([[PeachCollector sharedCollector] isUnitTesting]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
                                UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                                content.title = @"Peach";
                                content.body = [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)events.count];
                                
                                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:content trigger:nil];
                                
                                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                    
                                }];
                            }
                        });
                        
                        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                                          object:nil
                                                                        userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)events.count] }];
                    }
                    #endif
                }
                
                [self endBackgroundTask];
            }];
            
        }];
        
    } withPriority:NSOperationQueuePriorityHigh completionBlock:nil];
    
    
}

- (void)startTimerForPublisherNamed:(NSString *)publisherName followPolicy:(BOOL)shouldFollowPolicy
{
    NSInteger interval = [self intervalForPublisherNamed:publisherName followPolicy:shouldFollowPolicy];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:self
                                           selector:@selector(sendEventsToPublisherWithTimer:)
                                           userInfo:@{@"publisherName":publisherName}
                                            repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self.publisherTimers setObject:timer forKey:publisherName];
}

- (void)flush
{
    for (NSString *publisherName in [PeachCollector sharedCollector].publishers.allKeys) {
        [self sendEventsToPublisherNamed:publisherName];
    }
}

- (void)registerBackgroundTask
{
    self.ongoingRequests++;
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
            self.ongoingRequests = 0;
        }];
    }
}
- (void)endBackgroundTask
{
    self.ongoingRequests = MAX(0, self.ongoingRequests-1);
    if (self.ongoingRequests == 0) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)cleanTimers{
    for (NSTimer *timer in [self.publisherTimers allValues]) {
        [timer invalidate];
    }
    [self.publisherTimers removeAllObjects];
}

- (NSInteger)intervalForPublisherNamed:(NSString *)publisherName followPolicy:(BOOL)shouldFollowPolicy
{
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
    NSNumber *numberOfFailures = [self.numberOfFailures objectForKey:publisherName];
    if (numberOfFailures != nil){
        return MIN(300, publisher.interval * ([numberOfFailures integerValue] + 1));
    }
    
    if (shouldFollowPolicy) {
        if (publisher.gotBackPolicy == PCPublisherGotBackOnlinePolicySendAll) {
            return 0;
        }
        else {
            return arc4random_uniform(60);
        }
    }
    
    return publisher.interval;
}

@end
