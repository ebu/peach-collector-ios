//
//  PeachCollectorConfiguration.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorConfiguration.h"


@implementation PeachCollectorConfiguration

- (instancetype)initWithServiceURL:(NSString *)serviceURL
{
    return [self initWithServiceURL:serviceURL
         recommendedSendingInterval:PeachCollectorDefaultPublisherInterval
        recommendedMaxSendingEvents:PeachCollectorDefaultPublisherMaxEvents
                gotBackOnlinePolicy:PeachCollectorDefaultPublisherPolicy];
}

- (instancetype)initWithServiceURL:(NSString *)serviceURL
        recommendedSendingInterval:(NSInteger)interval
       recommendedMaxSendingEvents:(NSInteger)maxEvents
               gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
{
    self = [super init];
    if (self) {
        self.serviceURL = serviceURL;
        self.recommendedMaxSendingEvents = maxEvents;
        self.recommendedSendingInterval = interval;
    }
    return self;
}

- (instancetype)initWithSiteKey:(NSString *)siteKey
{
    return [self initWithSiteKey:siteKey
      recommendedSendingInterval:PeachCollectorDefaultPublisherInterval recommendedMaxSendingEvents:PeachCollectorDefaultPublisherMaxEvents
             gotBackOnlinePolicy:PeachCollectorDefaultPublisherPolicy];
}

- (instancetype)initWithSiteKey:(NSString *)siteKey
     recommendedSendingInterval:(NSInteger)interval
    recommendedMaxSendingEvents:(NSInteger)maxEvents
            gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
{
    return [self initWithServiceURL:[NSString stringWithFormat:@"https://pipe-collect.ebu.io/v3/collect?s=%@", siteKey]
         recommendedSendingInterval:interval
        recommendedMaxSendingEvents:maxEvents
                gotBackOnlinePolicy:gotBackOnlinePolicy];
}





@end
