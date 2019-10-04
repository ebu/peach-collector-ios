//
//  PeachCollectorPublisherEventStatus.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorPublisherEventStatus+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorPublisherEventStatus (Peach)

+ (NSArray<PeachCollectorPublisherEventStatus *> *)eventsStatusesForPublisherNamed:(NSString *)publisherName withStatus:(NSInteger)status;
+ (NSArray<PeachCollectorPublisherEventStatus *> *)pendingEventsStatusesForPublisherNamed:(NSString *)publisherName;
@end

NS_ASSUME_NONNULL_END
