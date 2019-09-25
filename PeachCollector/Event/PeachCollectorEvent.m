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

- (void)setContextValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *mutableContext = [self.context mutableCopy];
    if (mutableContext == nil) {
        mutableContext = [NSMutableDictionary new];
    }
    [mutableContext setObject:value forKey:key];
    self.context = [mutableContext copy];
}

- (void)setPropsValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *mutableProps = [self.props mutableCopy];
    if (mutableProps == nil) {
        mutableProps = [NSMutableDictionary new];
    }
    [mutableProps setObject:value forKey:key];
    self.props = [mutableProps copy];
}

- (void)setMetadataValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *mutableMetadata = [self.metadata mutableCopy];
    if (mutableMetadata == nil) {
        mutableMetadata = [NSMutableDictionary new];
    }
    [mutableMetadata setObject:value forKey:key];
    self.metadata = [mutableMetadata copy];
}


+ (void)sendRecommendationHitWithID:(NSString *)eventID
                              items:(NSArray<NSString *> *)items
                     itemsDisplayed:(NSInteger)itemsDisplayed
                           hitIndex:(NSInteger)index
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component
{
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];
    
    
    event.type = @"recommendation_hit";
    event.eventID = eventID;
    event.creationDate = [NSDate date];
    event.context = @{@"items":items,
                      @"items_displayed":@(itemsDisplayed),
                      @"hit_index":@(index)};
    
    if (appSectionID) {
        [event setContextValue:appSectionID forKey:@"page_uri"];
    }
    if (source) {
        [event setContextValue:source forKey:@"source"];
    }
    if (component && [component dictionaryDescription]) {
        [event setContextValue:[component dictionaryDescription] forKey:@"component"];
    }
    
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
    
    event.type = @"recommendation_displayed";
    event.eventID = eventID;
    event.creationDate = [NSDate date];
    event.context = @{@"items":items,
                      @"items_displayed":@(itemsDisplayedCount)};
    
    if (appSectionID) {
        [event setContextValue:appSectionID forKey:@"page_uri"];
    }
    if (source) {
        [event setContextValue:source forKey:@"source"];
    }
    if (component && [component dictionaryDescription]) {
        [event setContextValue:[component dictionaryDescription] forKey:@"component"];
    }
    
    NSError *error = nil;
    if ([[event managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    [event send];
}

+ (void)sendMediaHeartbeatWithStartEvent:(PeachCollectorEvent *)startEvent
{
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];
    
    NSLog(@"startEvent = %@", startEvent);
    
    event.type = PCEventTypeMediaHeartbeat;
    event.eventID = startEvent.eventID;
    event.creationDate = [NSDate date];
    if (startEvent.context) {
        event.context = startEvent.context;
    }
    if (startEvent.props) {
        if ([startEvent.props objectForKey:PeachCollectorPlaybackPositionKey]) {
            NSMutableDictionary *mutableProps = [startEvent.props mutableCopy];
            NSNumber *playbackPosition = [startEvent.props objectForKey:PeachCollectorPlaybackPositionKey];
            NSTimeInterval diff = [event.creationDate timeIntervalSinceDate:startEvent.creationDate];
            playbackPosition = @(playbackPosition.integerValue + diff);
            [mutableProps setObject:playbackPosition forKey:PeachCollectorPlaybackPositionKey];
            event.props = [mutableProps copy];
        }
        else {
            event.props = startEvent.props;
        }
    }
    if (startEvent.metadata) {
        event.metadata = startEvent.metadata;
    }
    
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
      automaticHeartbeats:(BOOL)startHeartbeats
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
    if (startHeartbeats) {
        [PeachCollector startHeartbeatsWithEvent:event];
    }
}

+ (void)sendMediaPlayWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
        automaticHeartbeats:(BOOL)startHeartbeats
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPlay eventID:mediaID properties:properties context:context metadata:metadata automaticHeartbeats:startHeartbeats];
}

+ (void)sendMediaPauseWithID:(NSString *)mediaID
                  properties:(PeachCollectorProperties *)properties
                     context:(PeachCollectorContext *)context
                    metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaPause eventID:mediaID properties:properties context:context metadata:metadata automaticHeartbeats:NO];
}

+ (void)sendMediaSeekWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaSeek eventID:mediaID properties:properties context:context metadata:metadata automaticHeartbeats:NO];
}

+ (void)sendMediaStopWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
{
    [PeachCollectorEvent sendEventWithType:PCEventTypeMediaStop eventID:mediaID properties:properties context:context metadata:metadata automaticHeartbeats:NO];
}



- (BOOL)canBeRemoved
{
    for (PeachCollectorPublisherEventStatus *publisherStatus in self.eventStatuses) {
        if (publisherStatus.status != PCEventStatusPublished) return NO;
    }
    if ([PeachCollector heartbeatStartEvent] == self) return NO;
    return YES;
}

- (void)send
{
    [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                      object:nil
                                                    userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"+ Event (%@)", self.type] }];
    [PeachCollector addEventToQueue:self];
}

@end
