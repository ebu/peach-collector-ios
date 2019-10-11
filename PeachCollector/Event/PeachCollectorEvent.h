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

/**
 *  Set status of the event for a specific publisher
 *  @param status The status of the event
 *  @param publisherName The name of the publisher
 */
- (void)setStatus:(NSInteger)status forPublisherNamed:(NSString *)publisherName;


/**
 *  Send a new event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param type    Name of the event's type.
 *  @param eventID unique identifier related to the event (e.g., data source id for a recommendation hit, media id for a media play)
 *  @param properties optional properties related to the event
 *  @param context optional context of the event (usually contains a component, e.g. Carousel, VideoPlayer...)
 *  @param metadata optional dictionary of metadatas (should be kept as small as possible)
 */
+ (void)sendEventWithType:(PCEventType)type
                  eventID:(NSString *)eventID
               properties:(nullable PeachCollectorProperties *)properties
                  context:(nullable PeachCollectorContext *)context
                 metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

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
                   metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata;

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

+ (void)sendMediaHeartbeatWithID:(NSString *)mediaID
                      properties:(PeachCollectorProperties *)properties
                         context:(PeachCollectorContext *)context
                        metadata:(NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  @return `YES` if the event has been sent successfully through all registered publishers. `NO` if the event is still queued for any publisher.
 */
- (BOOL)canBeRemoved;


/**
 * @return `YES` if the event should be directly sent by publishers if received when the application is not in active state.
 * When playing a media in background, pausing/stoping the media will freeze the application after 10 seconds.
*/
- (BOOL)shouldBeFlushedWhenReceivedInBackgroundState;

/**
* @return a dictionary representation of the event as defined in the Peach documentation
*/
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
