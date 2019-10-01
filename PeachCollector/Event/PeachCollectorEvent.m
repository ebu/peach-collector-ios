//
//  PeachCollectorEvent.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorEvent.h"
#import "PeachCollector.h"

@implementation PeachCollectorEvent (Peach)

+ (void)sendRecommendationHitWithID:(NSString *)eventID
                              items:(NSArray<NSString *> *)items
                     itemsDisplayed:(NSInteger)itemsDisplayed
                           hitIndex:(NSInteger)hitIndex
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component
{
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];
    
    
    event.type = PCEventTypeRecommendationHit;
    event.eventID = eventID;
    event.creationDate = [NSDate date];
    
    PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items itemsDisplayedCount:itemsDisplayed appSectionID:appSectionID source:source component:component hitIndex:hitIndex];
    
    event.context = [context dictionaryDescription];
    
    NSError *error = nil;
    if ([[event managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    [event send];
}

+ (void)sendRecommendationDisplayedWithID:(NSString *)eventID
                                    items:(NSArray<NSString *> *)items
                      itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component
{
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];
    
    event.type = PCEventTypeRecommendationDisplayed;
    event.eventID = eventID;
    event.creationDate = [NSDate date];
    
    PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items itemsDisplayedCount:itemsDisplayedCount appSectionID:appSectionID source:source component:component];

    event.context = [context dictionaryDescription];
    
    NSError *error = nil;
    if ([[event managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    [event send];
}

+ (void)sendEventWithType:(PCEventType)type
                  eventID:(NSString *)eventID
               properties:(nullable PeachCollectorProperties *)properties
                  context:(nullable PeachCollectorContext *)context
                 metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];
    
    event.type = type;
    event.eventID = eventID;
    event.creationDate = [NSDate date];
    if (context) {
        event.context = [context dictionaryDescription];
    }
    if (properties) {
        event.props = [properties dictionaryDescription];
    }
    if (metadata) {
        event.metadata = metadata;
    }
    
    NSError *error = nil;
    if ([[event managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    [event send];
}

+ (void)sendMediaPlayWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPlay eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaPauseWithID:(NSString *)mediaID
                  properties:(PeachCollectorProperties *)properties
                     context:(PeachCollectorContext *)context
                    metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPause eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaSeekWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaSeek eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaStopWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaStop eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaHeartbeatWithID:(NSString *)mediaID
                      properties:(PeachCollectorProperties *)properties
                         context:(PeachCollectorContext *)context
                        metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaHeartbeat eventID:mediaID properties:properties context:context metadata:metadata];
}



- (BOOL)canBeRemoved
{
    for (PeachCollectorPublisherEventStatus *publisherStatus in self.eventStatuses) {
        if (publisherStatus.status != PCEventStatusPublished) return NO;
    }
    return YES;
}

- (void)send
{
    [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                      object:nil
                                                    userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"+ Event (%@)", self.type] }];
    [PeachCollector addEventToQueue:self];
}

- (BOOL)shouldBeFlushedWhenReceivedInBackgroundState
{
    if (self.type != nil) {
        return [[[PeachCollector sharedCollector] flushableEventTypes] containsObject:self.type];
    }
    return NO;
}

@end
