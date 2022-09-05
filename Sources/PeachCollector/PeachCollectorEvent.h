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
 *  Send a collection item displayed event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param itemID Unique identifier of the item that has been displayed
 *  @param itemsCount Total number of items in the collection
 *  @param itemIndex Index of the item that has been displayed
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendCollectionItemDisplayedWithID:(NSString *)collectionID
                                   itemID:(NSString *)itemID
                               itemsCount:(NSInteger)itemsCount
                                itemIndex:(NSInteger)itemIndex
                             experimentID:(nullable NSString *)experimentID
                      experimentComponent:(nullable NSString *)experimentComponent
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component;

/**
 *  Send a collection item displayed event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param itemID Unique identifier of the item that has been displayed
 *  @param itemsCount Total number of items in the collection
 *  @param itemIndex Index of the item that has been displayed
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 *  @param contextID Identifier for the context
 *  @param contextType Context type
 */
+ (void)sendCollectionItemDisplayedWithID:(NSString *)collectionID
                                   itemID:(NSString *)itemID
                               itemsCount:(NSInteger)itemsCount
                                itemIndex:(NSInteger)itemIndex
                             experimentID:(nullable NSString *)experimentID
                      experimentComponent:(nullable NSString *)experimentComponent
                             appSectionID:(nullable NSString *)appSectionID
                                   source:(nullable NSString *)source
                                component:(nullable PeachCollectorContextComponent *)component
                                contextID:(nullable NSString *)contextID
                              contextType:(nullable NSString *)contextType;
/**
 *  Send a collection hit event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param itemID Unique identifier of the clip, media or article selected
 *  @param hitIndex Index of the item that has been hit
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendCollectionHitWithID:(NSString *)collectionID
                         itemID:(NSString *)itemID
                       hitIndex:(NSInteger)hitIndex
                   experimentID:(nullable NSString *)experimentID
            experimentComponent:(nullable NSString *)experimentComponent
                   appSectionID:(nullable NSString *)appSectionID
                         source:(nullable NSString *)source
                      component:(nullable PeachCollectorContextComponent *)component;
/**
 *  Send a collection hit event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param itemID Unique identifier of the clip, media or article selected
 *  @param hitIndex Index of the item that has been hit
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 *  @param contextID Identifier for the context
 *  @param contextType Context type
 */
+ (void)sendCollectionHitWithID:(NSString *)collectionID
                         itemID:(NSString *)itemID
                       hitIndex:(NSInteger)hitIndex
                   experimentID:(nullable NSString *)experimentID
            experimentComponent:(nullable NSString *)experimentComponent
                   appSectionID:(nullable NSString *)appSectionID
                         source:(nullable NSString *)source
                      component:(nullable PeachCollectorContextComponent *)component
                      contextID:(nullable NSString *)contextID
                    contextType:(nullable NSString *)contextType;

/**
 *  Send a collection displayed event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param items Array of strings (identifiers for items)
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendCollectionDisplayedWithID:(NSString *)collectionID
                                items:(NSArray<NSString *> *)items
                         experimentID:(nullable NSString *)experimentID
                  experimentComponent:(nullable NSString *)experimentComponent
                         appSectionID:(nullable NSString *)appSectionID
                               source:(nullable NSString *)source
                            component:(nullable PeachCollectorContextComponent *)component;
/**
 *  Send a collection displayed event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID    Unique identifier of the recommendation.
 *  @param items Array of strings (identifiers for items)
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 *  @param contextID Identifier for the context
 *  @param contextType Context type
 */
+ (void)sendCollectionDisplayedWithID:(NSString *)collectionID
                                items:(NSArray<NSString *> *)items
                         experimentID:(nullable NSString *)experimentID
                  experimentComponent:(nullable NSString *)experimentComponent
                         appSectionID:(nullable NSString *)appSectionID
                               source:(nullable NSString *)source
                            component:(nullable PeachCollectorContextComponent *)component
                            contextID:(nullable NSString *)contextID
                          contextType:(nullable NSString *)contextType;

/**
 *  Send a collection loaded event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID Unique identifier of the recommendation.
 *  @param items Array of strings (identifiers for items)
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 */
+ (void)sendCollectionLoadedWithID:(NSString *)collectionID
                             items:(NSArray<NSString *> *)items
                      experimentID:(nullable NSString *)experimentID
               experimentComponent:(nullable NSString *)experimentComponent
                      appSectionID:(nullable NSString *)appSectionID
                            source:(nullable NSString *)source
                         component:(nullable PeachCollectorContextComponent *)component;
/**
 *  Send a collection loaded event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param collectionID Unique identifier of the recommendation.
 *  @param items Array of strings (identifiers for items)
 *  @param experimentID Experiment identifier (default value is "default")
 *  @param experimentComponent Component of the experiment (default value is "main")
 *  @param appSectionID Unique identifier of app section where the recommendation is displayed
 *  @param source Identifier of the element in which the recommendation is displayed (the module, view or popup)
 *  @param component Description of the element in which the recommendation is displayed
 *  @param contextID Identifier for the context
 *  @param contextType Context type
 */
+ (void)sendCollectionLoadedWithID:(NSString *)collectionID
                             items:(NSArray<NSString *> *)items
                      experimentID:(nullable NSString *)experimentID
               experimentComponent:(nullable NSString *)experimentComponent
                      appSectionID:(nullable NSString *)appSectionID
                            source:(nullable NSString *)source
                         component:(nullable PeachCollectorContextComponent *)component
                         contextID:(nullable NSString *)contextID
                       contextType:(nullable NSString *)contextType;

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
 *  Send a media heartbeat event to a specific publisher. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 *  @param publisherName The name of the publisher
 */
+ (void)sendMediaHeartbeatWithID:(NSString *)mediaID
                      properties:(nullable PeachCollectorProperties *)properties
                         context:(nullable PeachCollectorContext *)context
                        metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata
                     toPublisher:(nullable NSString *)publisherName;

/**
 *  Send a media playlist add event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  Properties should contain the playlist ID to which it is added
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaPlaylistAddWithID:(NSString *)mediaID
                        properties:(nullable PeachCollectorProperties *)properties
                           context:(nullable PeachCollectorContext *)context
                          metadata:(nullable NSDictionary<NSString *, id<NSCopying>> *)metadata;

/**
 *  Send a media playlist remove event. Event will be added to the queue and sent accordingly to publishers' configurations.
 *  Properties should contain the playlist ID from which it is removed
 *  @param mediaID Unique identifier of the media
 *  @param properties Properties of the media and it's current state
 *  @param context Context of the media (e. g. view where it's displayed, component used to play the media...)
 *  @param metadata Metadatas (should be kept as small as possible)
 */
+ (void)sendMediaPlaylistRemoveWithID:(NSString *)mediaID
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
