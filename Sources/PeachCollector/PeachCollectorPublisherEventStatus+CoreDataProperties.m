//
//  PeachCollectorPublisherEventStatus+CoreDataProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 04.08.20.
//
//

#import "PeachCollectorPublisherEventStatus+CoreDataProperties.h"

@implementation PeachCollectorPublisherEventStatus (CoreDataProperties)

+ (NSFetchRequest<PeachCollectorPublisherEventStatus *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PeachCollectorPublisherEventStatus"];
}

@dynamic publisherName;
@dynamic status;
@dynamic event;

@end
