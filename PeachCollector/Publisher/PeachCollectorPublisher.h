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

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic) NSInteger interval;
@property (nonatomic) NSInteger maxEvents;
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
 *
 *  @param event    The event to be queued.
 *
 *  @return `YES` if the the publisher can process the event, `NO` otherwise.
 */
- (BOOL)shouldProcessEvent:(PeachCollectorEvent *)event;

@end

NS_ASSUME_NONNULL_END
