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
@import UIKit;
@import UserNotifications;


@interface PeachCollectorQueue()

@property (nonatomic, strong) NSMutableDictionary *publisherTimers;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) NSInteger ongoingRequests;

@end


@implementation PeachCollectorQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.publisherTimers = [NSMutableDictionary new];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [[PeachCollector sharedCollector] persistentContainer].viewContext;
}

- (void)addEvent:(PeachCollectorEvent *)event
{
    for (NSString *publisherID in [PeachCollector sharedCollector].publishers.allKeys) {
        PeachCollectorPublisher *publisher = [[PeachCollector sharedCollector].publishers objectForKey:publisherID];
        if ([publisher shouldProcessEvent:event]) {
            PeachCollectorPublisherEventStatus *eventStatus = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorPublisherEventStatus" inManagedObjectContext:[self managedObjectContext]];
            eventStatus.status = PCEventStatusQueued;
            eventStatus.publisherName = publisherID;
            eventStatus.event = event;
        }
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive
        && [event shouldBeFlushedWhenReceivedInBackgroundState]) {
        [self flush];
    }
    
    [self checkPublishers];
}

- (void)checkPublishers
{
    for (NSString *publisherName in [PeachCollector sharedCollector].publishers.allKeys) {
        PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
        NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus pendingEventsStatusesForPublisherNamed:publisherName];
        
        if (eventsStatuses.count >= publisher.maxEvents || publisher.interval == 0) {
            [self sendEventsToPublisherNamed:publisherName];
        }
        else if ([eventsStatuses count] >= 1 && publisher.maxEvents > 1) {
            if ([self.publisherTimers objectForKey:publisherName] == nil) {
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:publisher.interval target:self selector:@selector(sendEventsToPublisherWithTimer:) userInfo:@{@"publisherName":publisherName} repeats:NO];
                [self.publisherTimers setObject:timer forKey:publisherName];
            }
        }
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
    
    for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
        eventStatus.status = PCEventStatusSentToPublisher;
    }
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    
    NSMutableArray *events = [NSMutableArray new];
    for (PeachCollectorPublisherEventStatus *status in eventsStatuses) {
        [events addObject:status.event];
    }
    
    [self registerBackgroundTask];
    
    [publisher sendEvents:events withCompletionHandler:^(NSError * _Nullable error) {
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            eventStatus.status = (error) ? PCEventStatusQueued : PCEventStatusPublished;
            if ([eventStatus.event canBeRemoved]){
                [[PeachCollector managedObjectContext] deleteObject:eventStatus.event];
            }
        }
        
        NSError *contextError = nil;
        if ([[PeachCollector managedObjectContext] save:&contextError] == NO) {
            [[PeachCollector managedObjectContext] rollback];
            //NSAssert(NO, @"Error saving context: %@\n%@", [contextError localizedDescription], [contextError userInfo]);
        }
        
        if (error) {
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:publisher.interval target:self selector:@selector(sendEventsToPublisherWithTimer:) userInfo:@{@"publisherName":publisherName} repeats:NO];
            [self.publisherTimers setObject:timer forKey:publisherName];
            
            if ([[PeachCollector sharedCollector] isUnitTesting]) {
                [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                  object:nil userInfo:@{PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Failed to publish events", publisherName]}];
            }
                
        }
        else if ([[PeachCollector sharedCollector] isUnitTesting]) {
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
        
        [self endBackgroundTask];
    }];
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

@end
