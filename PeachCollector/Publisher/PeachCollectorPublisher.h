//
//  PeachCollectorPublisher.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorEvent.h"

NS_ASSUME_NONNULL_BEGIN



@interface PeachCollectorPublisher : NSObject

/**
 *  End point of the publisher, where all requests should be sent
 */
@property (nonatomic, copy) NSString *serviceURL;

/**
 * The interval in seconds at which events are sent to the server.
 * 0 means no buffering, every event is sent as soon as it is queued.
 * Default value is 20 seconds.
 */
@property (nonatomic) NSInteger interval;

/**
 *  Number of events queued that triggers the publishing process even if the desired interval hasn't been reached.
 *  1 means no buffering, every event is sent as soon as it is queued.
 *  Default value is 20 events.
 */
@property (nonatomic) NSInteger recommendedLimitPerBatch;

/**
 *  Maximum number of events that can be sent in a single batch.
 *  Default value is 1000 events.
 */
@property (nonatomic) NSInteger maximumLimitPerBatch;

/**
 *  How the publisher should behave after an offline period
 *  Default is PCPublisherGotBackOnlinePolicySendAll
 */
@property (nonatomic) PCPublisherGotBackOnlinePolicy gotBackPolicy;


/**
 *  Create a collector configuration.
 *  @param serviceURL The service url string to the Peach end point.
 */
- (instancetype)initWithServiceURL:(NSString *)serviceURL;

/**
 *  Create a collector configuration with a default publisher linked to the default service URL.
 *  @param siteKey The site key used to recognize this app on the Peach server.
 */
- (instancetype)initWithSiteKey:(NSString *)siteKey;

/**
 *  Send event to the configured service URL
 *  @param events the events to send
 *  @param completionHandler the block that is called when the process is finished, eventually with an error
 */
- (void)sendEvents:(NSArray<PeachCollectorEvent *> *)events withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;

/**
 *  Return `YES` if the the publisher can process the event. This is used when an event is added to the queue to check
 *  if said event should be added to the publisher's queue.
 *  @param event    The event to be queued.
 *  @return `YES` if the the publisher can process the event, `NO` otherwise.
 */
- (BOOL)shouldProcessEvent:(PeachCollectorEvent *)event;

/**
 *  Method called by the collector when the user ID is set or changed
 *  @param userID the user unique identifier
 */
- (void)userIDHasBeenUpdated:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
