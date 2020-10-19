//
//  PeachCollectorEvent+CoreDataProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 04.08.20.
//
//

#import "PeachCollectorEvent+CoreDataProperties.h"

@implementation PeachCollectorEvent (CoreDataProperties)

+ (NSFetchRequest<PeachCollectorEvent *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PeachCollectorEvent"];
}

@dynamic context;
@dynamic creationDate;
@dynamic eventID;
@dynamic metadata;
@dynamic pageStartDate;
@dynamic props;
@dynamic type;
@dynamic eventStatuses;

@end
