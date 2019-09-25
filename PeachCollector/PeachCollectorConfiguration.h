//
//  PeachCollectorConfiguration.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorPublisher.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorConfiguration : NSObject

@property (nonatomic) NSInteger heartbeatInterval;
@property (nonatomic) NSInteger recommandedSendingInterval;
@property (nonatomic) NSInteger recommandedMaxSendingEvents;
@property (nonatomic) PCPublisherGotBackOnlinePolicy gotBackOnlinePolicy;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, copy) NSString *siteKey;

/**
 *  Create a collector configuration.
 *
 *  @param serviceURL The service url string to the Peach end point.
 */
- (instancetype)initWithServiceURL:(NSString *)serviceURL;


/**
 *  Create a collector configuration.
 *
 *  @param serviceURL The service url string to the Peach end point.
 *  @param interval The interval in second at which events are sent to the server. 0 means no caching. Default is 30 seconds.
 *  @param maxEvents  Maximum number of events that can be sent to the server simultaneously. Default is 20 events.
 *  @param gotBackOnlinePolicy How the publisher should behave after an offline period.
 *  @param heartbeatInterval The interval at which heartbeats are sent after a Media Play event. 0 means no heartbeats.
 */
- (instancetype)initWithServiceURL:(NSString *)serviceURL
        recommandedSendingInterval:(NSInteger)interval
       recommandedMaxSendingEvents:(NSInteger)maxEvents
               gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
                 heartbeatInterval:(NSInteger)heartbeatInterval;


/**
 *  Create a collector configuration with a default publisher linked to the default service URL.
 *
 *  @param siteKey The site key used to recognize this app on the Peach server.
 */
- (instancetype)initWithSiteKey:(NSString *)siteKey;

/**
 *  Create a collector configuration with a publisher linked to the default service URL.
 *
 *  @param siteKey The site key used to recognize this app on the Peach server.
 *  @param interval The interval in second at which events are sent to the server. 0 means no caching. Default is 30 seconds.
 *  @param maxEvents  Maximum number of events that can be sent to the server simultaneously. Default is 20 events.
 *  @param gotBackOnlinePolicy How the publisher should behave after an offline period. Default is 'PCPublisherGotBackOnlinePolicySendAll'
 *  @param heartbeatInterval The interval at which heartbeats are sent. 0 means no heartbeats. Default is 5
 */
- (instancetype)initWithSiteKey:(NSString *)siteKey
     recommandedSendingInterval:(NSInteger)interval
    recommandedMaxSendingEvents:(NSInteger)maxEvents
            gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
              heartbeatInterval:(NSInteger)heartbeatInterval;

@end

NS_ASSUME_NONNULL_END
