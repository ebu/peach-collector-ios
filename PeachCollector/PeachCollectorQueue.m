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
@import UserNotifications;


@interface PeachCollectorQueue()

@property (nonatomic, strong) NSMutableDictionary *publisherTimers;

@end


@implementation PeachCollectorQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.publisherTimers = [NSMutableDictionary new];
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
    
    [self checkPublishers];
}


/*
 *  Check queue state for any publisher
 *  If a publisher has enough events in queue, send them.
 *  If there are events but no timer, start the timer with the needed interval
 */
- (void)checkPublishers
{
    for (NSString *publisherName in [PeachCollector sharedCollector].publishers.allKeys) {
        PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:publisherName];
        NSArray *eventsStatuses = [PeachCollectorPublisherEventStatus eventsStatusesForPublisherNamed:publisherName withStatus:PCEventStatusQueued];
        
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
    }
    [publisher sendEvents:eventsStatuses withCompletionHandler:^(NSError * _Nullable error) {
        for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
            eventStatus.status = (error) ? PCEventStatusPlublicationFailed : PCEventStatusPublished;
            if ([eventStatus.event canBeRemoved]){
                [[PeachCollector managedObjectContext] deleteObject:eventStatus.event];
            }
        }
        
        NSError *contextError = nil;
        if ([[PeachCollector managedObjectContext] save:&contextError] == NO) {
            NSAssert(NO, @"Error saving context: %@\n%@", [contextError localizedDescription], [contextError userInfo]);
        }
        
        if (error) {
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:publisher.interval target:self selector:@selector(sendEventsToPublisherWithTimer:) userInfo:@{@"publisherName":publisherName} repeats:NO];
            [self.publisherTimers setObject:timer forKey:publisherName];
            return;
        }
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = @"Peach";
            content.body = [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)eventsStatuses.count];
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:content trigger:nil];
            
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                          object:nil
                                                        userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Published %d events", publisherName, (int)eventsStatuses.count] }];
    }];
}

- (void)flush
{
    for (NSString *publisherName in [PeachCollector sharedCollector].publishers.allKeys) {
        [self sendEventsToPublisherNamed:publisherName];
    }
}

- (void)empty
{
    
}

@end
