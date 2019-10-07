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
    
    event.context = [context dictionaryRepresentation];
    
    [PeachCollector save];
    
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

    event.context = [context dictionaryRepresentation];
    
    [PeachCollector save];
    
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
        event.context = [context dictionaryRepresentation];
    }
    if (properties) {
        event.props = [properties dictionaryRepresentation];
    }
    if (metadata) {
        event.metadata = metadata;
    }
    
    [PeachCollector save];
    
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


- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    [representation setObject:self.type forKey:PCEventTypeKey];
    [representation setObject:self.eventID forKey:PCEventIDKey];
    [representation setObject:@((int)[self.creationDate timeIntervalSince1970]) forKey:PCEventTimestampKey];
    
    if (self.context) [representation setObject:self.context forKey:PCEventContextKey];
    if (self.props) [representation setObject:self.props forKey:PCEventPropertiesKey];
    if (self.metadata) [representation setObject:self.metadata forKey:PCEventMetadataKey];
    
    return representation;
}

@end
