//
//  PeachCollectorEvent.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorEvent+CoreDataClass.h"
#import "PeachCollectorContext.h"
#import "PeachCollectorProperties.h"
#import "PeachCollectorDataFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorEvent (Peach)

- (void)setContextValue:(id)value forKey:(NSString *)key;
- (void)setPropsValue:(id)value forKey:(NSString *)key;
- (void)setMetadataValue:(id)value forKey:(NSString *)key;

- (void)send;

+ (void)sendRecommendationHitWithID:(NSString *)recommendationID
                              items:(NSArray<NSString *> *)items
                     itemsDisplayed:(NSInteger)itemsDisplayed
                           hitIndex:(NSInteger)index
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component;

+ (void)sendRecommendationDisplayedWithID:(NSString *)recommendationID
                                    items:(NSArray<NSString *> *)items
                      itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component;


+ (void)sendMediaPlayWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata
        automaticHeartbeats:(BOOL)startHeartbeats;

+ (void)sendMediaPauseWithID:(NSString *)mediaID
                  properties:(PeachCollectorProperties *)properties
                     context:(PeachCollectorContext *)context
                    metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata;

+ (void)sendMediaSeekWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata;

+ (void)sendMediaStopWithID:(NSString *)mediaID
                 properties:(PeachCollectorProperties *)properties
                    context:(PeachCollectorContext *)context
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata;

+ (void)sendMediaHeartbeatWithStartEvent:(PeachCollectorEvent *)startEvent;

//+ (NSArray<PeachCollectorEvent *> *)eventsForPublisherNamed:(NSString *)publisherName;

- (BOOL)canBeRemoved;

@end

NS_ASSUME_NONNULL_END
