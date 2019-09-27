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
         recommandedSendingInterval:PeachCollectorDefaultPublisherInterval
        recommandedMaxSendingEvents:PeachCollectorDefaultPublisherMaxEvents
                gotBackOnlinePolicy:PeachCollectorDefaultPublisherPolicy];
}

- (instancetype)initWithServiceURL:(NSString *)serviceURL
        recommandedSendingInterval:(NSInteger)interval
       recommandedMaxSendingEvents:(NSInteger)maxEvents
               gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
{
    self = [super init];
    if (self) {
        self.serviceURL = serviceURL;
        self.recommandedMaxSendingEvents = maxEvents;
        self.recommandedSendingInterval = interval;
    }
    return self;
}

- (instancetype)initWithSiteKey:(NSString *)siteKey
{
    return [self initWithSiteKey:siteKey
      recommandedSendingInterval:PeachCollectorDefaultPublisherInterval recommandedMaxSendingEvents:PeachCollectorDefaultPublisherMaxEvents
             gotBackOnlinePolicy:PeachCollectorDefaultPublisherPolicy];
}

- (instancetype)initWithSiteKey:(NSString *)siteKey
     recommandedSendingInterval:(NSInteger)interval
    recommandedMaxSendingEvents:(NSInteger)maxEvents
            gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackOnlinePolicy
{
    return [self initWithServiceURL:[NSString stringWithFormat:@"https://pipe-collect.ebu.io/v3/collect?s=%@", siteKey]
         recommandedSendingInterval:interval
        recommandedMaxSendingEvents:maxEvents
                gotBackOnlinePolicy:gotBackOnlinePolicy];
}





@end
