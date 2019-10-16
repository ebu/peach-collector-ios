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
    [PeachCollector queueOperation:^{
        NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus allEventsStatuses];
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            eventStatus.status = PCEventStatusQueued;
        }
        [PeachCollector save];
    } withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)addEvent:(PeachCollectorEvent *)event
{
    [PeachCollector queueOperation:^{
        for (NSString *publisherID in [PeachCollector sharedCollector].publishers.allKeys) {
            PeachCollectorPublisher *publisher = [[PeachCollector sharedCollector].publishers objectForKey:publisherID];
            if ([publisher shouldProcessEvent:event]) {
                PeachCollectorPublisherEventStatus *eventStatus = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorPublisherEventStatus" inManagedObjectContext:[PeachCollector managedObjectContext]];
                eventStatus.status = PCEventStatusQueued;
                eventStatus.publisherName = publisherID;
                eventStatus.event = event;
            }
        }
        
        [PeachCollector save];
    } withCompletionHandler:^(NSError * _Nullable error) {
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive
            && [event shouldBeFlushedWhenReceivedInBackgroundState]) {
            [self flush];
        }
        
        [self checkPublishers];
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
    NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName];
    
    BOOL lastPublishingHasFailed = [self.numberOfFailures objectForKey:publisherName] != nil;
    
    if (!lastPublishingHasFailed && (eventsStatuses.count >= publisher.maxEventsPerBatch || publisher.interval == 0)) {
        [self sendEventsToPublisherNamed:publisherName];
    }
    else if ([eventsStatuses count] && [self.publisherTimers objectForKey:publisherName] == nil) {
        [self startTimerForPublisherNamed:publisherName];
    }
}

- (void)sendEventsToPublisherWithTimer:(NSTimer *)timer
{
    NSString *publisherName = [[timer userInfo] objectForKey:@"publisherName"];
    [self sendEventsToPublisherNamed:publisherName];
}

- (void)sendEventsToPublisherNamed:(NSString *)publisherName
{
    NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName];
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
    
    if (eventsStatuses.count == 0) return;
    
    NSTimer *timer = [self.publisherTimers objectForKey:publisherName];
    if (timer) {
        [timer invalidate];
        [self.publisherTimers removeObjectForKey:publisherName];
    }
    
    NSMutableArray *events = [NSMutableArray new];
    for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
        if (events.count < publisher.maxEventsPerBatchAfterOfflineSession) {
            [events addObject:eventStatus.event];
        }
    }
    
    [PeachCollector queueOperation:^{
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            if ([events containsObject:eventStatus.event]) {
               eventStatus.status = PCEventStatusSentToPublisher;
            }
        }
        [PeachCollector save];
    } withCompletionHandler:^(NSError * _Nullable error) {
        [self registerBackgroundTask];
        
        [publisher processEvents:events withCompletionHandler:^(NSError * _Nullable error) {
            BOOL shouldContinueSending = NO;
            if (eventsStatuses.count > events.count && error == nil) {
                shouldContinueSending = YES;
            }
            
            [PeachCollector queueOperation:^{
                for (PeachCollectorEvent *event in events) {
                    [event setStatus:(error) ? PCEventStatusQueued : PCEventStatusPublished forPublisherNamed:publisherName];
                    if ([event canBeRemoved]){
                        [[PeachCollector managedObjectContext] deleteObject:event];
                    }
                }
                [PeachCollector save];
            } withCompletionHandler:^(NSError * _Nullable saveError) {
                if (error) {
                    NSNumber *numberOfFailures = [self.numberOfFailures objectForKey:publisherName];
                    numberOfFailures = (numberOfFailures == nil) ? @(1) : @(numberOfFailures.integerValue + 1);
                    [self.numberOfFailures setObject:numberOfFailures forKey:publisherName];
                    
                    [self startTimerForPublisherNamed:publisherName];
                    
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
                    
                    if ([[PeachCollector sharedCollector] isUnitTesting]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
                                UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                                content.title = @"Peach";
                                content.body = [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)eventsStatuses.count];
                                
                                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:content trigger:nil];
                                
                                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                    
                                }];
                            }
                        });
                        
                        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                                          object:nil
                                                                        userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)eventsStatuses.count] }];
                    }
                }
                
                [self endBackgroundTask];
            }];
            
        }];
    }];
    
    
}

- (void)startTimerForPublisherNamed:(NSString *)publisherName
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:[self intervalForPublisherNamed:publisherName]
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

- (NSInteger)intervalForPublisherNamed:(NSString *)publisherName
{
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
    NSNumber *numberOfFailures = [self.numberOfFailures objectForKey:publisherName];
    if (numberOfFailures != nil){
        return MIN(300, publisher.interval * ([numberOfFailures integerValue] + 1));
    }
    return publisher.interval;
}

@end
