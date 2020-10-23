//
//  PeachCollectorEvent+CoreDataProperties.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 04.08.20.
//
//

#import "PeachCollectorEvent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorEvent (CoreDataProperties)

+ (NSFetchRequest<PeachCollectorEvent *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSDictionary *context;
@property (nullable, nonatomic, copy) NSDate *creationDate;
@property (nullable, nonatomic, copy) NSString *eventID;
@property (nullable, nonatomic, retain) NSDictionary *metadata;
@property (nullable, nonatomic, copy) NSDate *pageStartDate;
@property (nullable, nonatomic, retain) NSDictionary *props;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, retain) NSSet<PeachCollectorPublisherEventStatus *> *eventStatuses;

@end

@interface PeachCollectorEvent (CoreDataGeneratedAccessors)

- (void)addEventStatusesObject:(PeachCollectorPublisherEventStatus *)value;
- (void)removeEventStatusesObject:(PeachCollectorPublisherEventStatus *)value;
- (void)addEventStatuses:(NSSet<PeachCollectorPublisherEventStatus *> *)values;
- (void)removeEventStatuses:(NSSet<PeachCollectorPublisherEventStatus *> *)values;

@end

NS_ASSUME_NONNULL_END
