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

+ (NSArray<PeachCollectorPublisherEventStatus *> *)eventsStatusesForPublisherNamed:(NSString *)publisherName withStatus:(NSInteger)status inContext:(NSManagedObjectContext *)context;
+ (NSArray<PeachCollectorPublisherEventStatus *> *)pendingEventsStatusesForPublisherNamed:(NSString *)publisherName inContext:(NSManagedObjectContext *)context;
+ (NSArray<PeachCollectorPublisherEventStatus *> *)allEventsStatusesInContext:(NSManagedObjectContext *)context;
@end

NS_ASSUME_NONNULL_END
