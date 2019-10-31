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
                itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                           hitIndex:(NSInteger)hitIndex
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component
{
    __block PeachCollectorEvent *event;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = PCEventTypeRecommendationHit;
        event.eventID = eventID;
        event.creationDate = [NSDate date];
        
        PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items appSectionID:appSectionID source:source component:component itemsDisplayedCount:itemsDisplayedCount hitIndex:hitIndex];
        event.context = [context dictionaryRepresentation];
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        [event send];
    }];
}

+ (void)sendRecommendationDisplayedWithID:(NSString *)eventID
                                    items:(NSArray<NSString *> *)items
                      itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component
{
    __block PeachCollectorEvent *event;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = PCEventTypeRecommendationDisplayed;
        event.eventID = eventID;
        event.creationDate = [NSDate date];
        
        PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items appSectionID:appSectionID source:source component:component itemsDisplayedCount:itemsDisplayedCount];

        event.context = [context dictionaryRepresentation];
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        [event send];
    }];
}

+ (void)sendRecommendationLoadedWithID:(NSString *)recommendationID
                                 items:(NSArray<NSString *> *)items
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source
                             component:(nullable PeachCollectorContextComponent *)component
{
    __block PeachCollectorEvent *event;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = PCEventTypeRecommendationLoaded;
        event.eventID = recommendationID;
        event.creationDate = [NSDate date];
        
        PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items appSectionID:appSectionID source:source component:component];

        event.context = [context dictionaryRepresentation];
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        [event send];
    }];
}

+ (void)sendPageViewWithID:(NSString *)pageID
                  referrer:(nullable NSString *)referrer
{
    __block PeachCollectorEvent *event;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = PCEventTypePageView;
        event.creationDate = [NSDate date];
        event.eventID = pageID;
        
        NSMutableDictionary *pageViewContext = [NSMutableDictionary new];
        if (referrer) [pageViewContext setObject:referrer forKey:PCContextReferrerKey];
        event.context = [pageViewContext copy];
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        [event send];
    }];
}

+ (void)sendEventWithType:(PCEventType)type
                  eventID:(NSString *)eventID
               properties:(nullable PeachCollectorProperties *)properties
                  context:(nullable PeachCollectorContext *)context
                 metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    __block PeachCollectorEvent *event;
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = type;
        event.eventID = eventID;
        event.creationDate = [NSDate date];
        if (context && [context dictionaryRepresentation]) {
            event.context = [context dictionaryRepresentation];
        }
        if (properties && [properties dictionaryRepresentation]) {
            event.props = [properties dictionaryRepresentation];
        }
        if (metadata) {
            event.metadata = metadata;
        }
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        [event send];
    }];
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
    if ([[PeachCollector sharedCollector] isUnitTesting]) {
        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification object:nil
                                                        userInfo:@{PeachCollectorNotificationLogKey:[NSString stringWithFormat:@"+ Event (%@)", self.type]}];
    }
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
    if (self.type == nil || self.eventID == nil || self.creationDate == nil) return nil;
    
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
