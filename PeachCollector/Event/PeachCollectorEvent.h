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

/**
 *  Send a recommendation hit event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param recommendationID    Unique identifier of the recommendation.
 *  @param itemID Unique identifier of the clip, media or article selected
 *  @param hitIndex Index of the item that has been hit
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendRecommendationHitWithID:(NSString *)recommendationID
                             itemID:(NSString *)itemID
                           hitIndex:(NSInteger)hitIndex
                       appSectionID:(nullable NSString *)appSectionID
                             source:(nullable NSString *)source
                          component:(nullable PeachCollectorContextComponent *)component;

/**
 *  Send a recommendation displayed event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param recommendationID Unique identifier of the recommendation.
 *  @param itemsDisplayed List of unique identifiers for the clips, medias or articles that are visible to the user
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendRecommendationDisplayedWithID:(NSString *)recommendationID
                           itemsDisplayed:(NSArray<NSString *> *)itemsDisplayed
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component;

/**
 *  Send a recommendation loaded event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param recommendationID Unique identifier of the recommendation.
 *  @param items List of unique identifiers for the clips, medias or articles recommended
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendRecommendationLoadedWithID:(NSString *)recommendationID
                                 items:(NSArray<NSString *> *)items
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source
                             component:(nullable PeachCollectorContextComponent *)component;

/**
 *  Send a page view event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param pageID Unique identifier of the page.
 *  @param referrer Identifier of the previous page that led to this page view
 *  @param recommendationID recommendation identifier If the page view is initiated by a recommendation hit
 */
+ (void)sendPageViewWithID:(NSString *)pageID
                  referrer:(nullable NSString *)referrer
          recommendationID:(nullable NSString *)recommendationID;

/**
 *  Send a media play event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaPlayWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media pause event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaPauseWithID:(NSString *)mediaID
                  properties:(nullable PeachCollectorProperties *)properties
                     context:(nullable PeachCollectorContext *)context
                    metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media seek event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaSeekWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media stop event.
 *  Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaStopWithID:(NSString *)mediaID
                 properties:(nullable PeachCollectorProperties *)properties
                    context:(nullable PeachCollectorContext *)context
                   metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media end event (usually when a media reaches the end of its playback).
 *  Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaEndWithID:(NSString *)mediaID
                properties:(nullable PeachCollectorProperties *)properties
                   context:(nullable PeachCollectorContext *)context
                  metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media heartbeat event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaHeartbeatWithID:(NSString *)mediaID
                      properties:(nullable PeachCollectorProperties *)properties
                         context:(nullable PeachCollectorContext *)context
                        metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

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
