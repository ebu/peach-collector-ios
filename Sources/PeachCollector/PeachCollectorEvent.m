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

+ (void)sendRecommendationHitWithID:(NSString *)recommendationID
                             itemID:(NSString *)itemID
                           hitIndex:(NSInteger)hitIndex
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component
{
    if (![PeachCollector shouldCollectEvents]) return;
    
    __block PeachCollectorEvent *event;
    NSMutableDictionary *mutableContext = [NSMutableDictionary new];
    [mutableContext setObject:[itemID copy] forKey:PCContextItemIDKey];
    [mutableContext setObject:@(hitIndex) forKey:PCContextHitIndexKey];
    if (appSectionID) [mutableContext setObject:[appSectionID copy] forKey:PCContextPageURIKey];
    if (source) [mutableContext setObject:[source copy] forKey:PCContextSourceKey];
    if (component && [component dictionaryRepresentation]) [mutableContext setObject:[component dictionaryRepresentation] forKey:PCContextComponentKey];
    NSDictionary *context = [mutableContext copy];
    
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        event.type = PCEventTypeRecommendationHit;
        event.eventID = recommendationID;
        event.creationDate = [NSDate date];
        event.context = [context copy];
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if ([[PeachCollector sharedCollector] isUnitTesting]) NSLog(@"PeachCollector DB Error: %@", [error description]);
            return;
        }
        [event send];
    }];
}
+ (void)sendRecommendationDisplayedWithID:(NSString *)recommendationID
                           itemsDisplayed:(NSArray<NSString *> *)itemsDisplayed
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component
{
    if (![PeachCollector shouldCollectEvents]) return;
    
    __block PeachCollectorEvent *event;
    NSMutableDictionary *mutableContext = [NSMutableDictionary new];
    [mutableContext setObject:[itemsDisplayed copy] forKey:PCContextItemsKey];
    if (appSectionID) [mutableContext setObject:[appSectionID copy] forKey:PCContextPageURIKey];
    if (source) [mutableContext setObject:[source copy] forKey:PCContextSourceKey];
    if (component && [component dictionaryRepresentation]) [mutableContext setObject:[component dictionaryRepresentation] forKey:PCContextComponentKey];
    NSDictionary *context = [mutableContext copy];
    
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        event.type = PCEventTypeRecommendationDisplayed;
        event.eventID = recommendationID;
        event.creationDate = [NSDate date];
        event.context = context;
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
    if (![PeachCollector shouldCollectEvents]) return;
    
    __block PeachCollectorEvent *event;
    NSMutableDictionary *mutableContext = [NSMutableDictionary new];
    [mutableContext setObject:[items copy] forKey:PCContextItemsKey];
    if (appSectionID) [mutableContext setObject:[appSectionID copy] forKey:PCContextPageURIKey];
    if (source) [mutableContext setObject:[source copy] forKey:PCContextSourceKey];
    if (component && [component dictionaryRepresentation]) [mutableContext setObject:[component dictionaryRepresentation] forKey:PCContextComponentKey];
    NSDictionary *context = [mutableContext copy];
    
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        
        event.type = PCEventTypeRecommendationLoaded;
        event.eventID = recommendationID;
        event.creationDate = [NSDate date];
        event.context = context;
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if ([[PeachCollector sharedCollector] isUnitTesting]) NSLog(@"PeachCollector DB Error: %@", [error description]);
            return;
        }
        [event send];
    }];
}

+ (void)sendPageViewWithID:(NSString *)pageID
                  referrer:(nullable NSString *)referrer
          recommendationID:(nullable NSString *)recommendationID
{
    if (![PeachCollector shouldCollectEvents]) return;
    
    __block PeachCollectorEvent *event;
    NSDictionary *context;
    if (referrer || recommendationID) {
    NSMutableDictionary *pageViewContext = [NSMutableDictionary new];
        if (referrer) [pageViewContext setObject:[referrer copy] forKey:PCContextReferrerKey];
        if (recommendationID) [pageViewContext setObject:[recommendationID copy] forKey:PCContextIDKey];
        context = [pageViewContext copy];
    }
    
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        event.type = PCEventTypePageView;
        event.creationDate = [NSDate date];
        event.eventID = pageID;
        event.context = context;
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if ([[PeachCollector sharedCollector] isUnitTesting]) NSLog(@"PeachCollector DB Error: %@", [error description]);
            return;
        }
        [event send];
    }];
}

+ (void)sendEventWithType:(PCEventType)type
                  eventID:(NSString *)eventID
               properties:(nullable PeachCollectorProperties *)properties
                  context:(nullable PeachCollectorContext *)context
                 metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    if (![PeachCollector shouldCollectEvents]) return;
    
    __block PeachCollectorEvent *event;
    NSDictionary *propsDictionary = (properties && [properties dictionaryRepresentation]) ? [properties dictionaryRepresentation] : nil;
    NSDictionary *contextDictionary = (context && [context dictionaryRepresentation]) ? [context dictionaryRepresentation] : nil;
    NSDictionary *metadataDictionary = (metadata && metadata.allKeys.count > 0) ? [metadata copy] : nil;
    
    [PeachCollector.dataStore performBackgroundWriteTask:^(NSManagedObjectContext * _Nonnull managedObjectContext) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:managedObjectContext];
        event.type = type;
        event.eventID = eventID;
        event.creationDate = [NSDate date];
        event.context = contextDictionary;
        event.props = propsDictionary;
        event.metadata = metadataDictionary;
    } withPriority:NSOperationQueuePriorityNormal completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if ([[PeachCollector sharedCollector] isUnitTesting]) NSLog(@"PeachCollector DB Error: %@", [error description]);
            return;
        }
        [event send];
    }];
}

+ (void)sendMediaPlayWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPlay eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaPauseWithID:(NSString *)mediaID
                  properties:(nullable PeachCollectorProperties *)properties
                     context:(nullable PeachCollectorContext *)context
                    metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPause eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaSeekWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaSeek eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaStopWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaStop eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaEndWithID:(NSString *)mediaID
                properties:(nullable PeachCollectorProperties *)properties
                   context:(nullable PeachCollectorContext *)context
                  metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaEnd eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaHeartbeatWithID:(NSString *)mediaID
                      properties:(nullable PeachCollectorProperties *)properties
                         context:(nullable PeachCollectorContext *)context
                        metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaHeartbeat eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaPlaylistAddWithID:(NSString *)mediaID
                        properties:(nullable PeachCollectorProperties *)properties
                           context:(nullable PeachCollectorContext *)context
                          metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPlaylistAdd eventID:mediaID properties:properties context:context metadata:metadata];
}

+ (void)sendMediaPlaylistRemoveWithID:(NSString *)mediaID
                           properties:(nullable PeachCollectorProperties *)properties
                              context:(nullable PeachCollectorContext *)context
                             metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPlaylistRemove eventID:mediaID properties:properties context:context metadata:metadata];
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
    if (self != nil && self.type != nil) {
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
    [representation setObject:@((NSInteger)([self.creationDate timeIntervalSince1970] * 1000)) forKey:PCEventTimestampKey];
    
    if (self.context) [representation setObject:self.context forKey:PCEventContextKey];
    if (self.props) [representation setObject:self.props forKey:PCEventPropertiesKey];
    if (self.metadata) [representation setObject:self.metadata forKey:PCEventMetadataKey];
    
    return representation;
}

@end
