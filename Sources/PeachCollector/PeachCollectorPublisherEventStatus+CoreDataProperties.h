//
//  PeachCollectorPublisherEventStatus+CoreDataProperties.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 04.08.20.
//
//

#import "PeachCollectorPublisherEventStatus+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorPublisherEventStatus (CoreDataProperties)

+ (NSFetchRequest<PeachCollectorPublisherEventStatus *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *publisherName;
@property (nonatomic) int16_t status;
@property (nullable, nonatomic, retain) PeachCollectorEvent *event;

@end

NS_ASSUME_NONNULL_END
