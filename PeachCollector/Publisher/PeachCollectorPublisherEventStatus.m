//
//  PeachCollectorPublisherEventStatus.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorPublisherEventStatus.h"
#import "PeachCollector.h"

@implementation PeachCollectorPublisherEventStatus (Peach)

+ (NSArray<PeachCollectorPublisherEventStatus *> *)eventsStatusesForPublisherNamed:(NSString *)publisherName withStatus:(NSInteger)status
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PeachCollectorPublisherEventStatus"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"publisherName == %@ AND status == %d", publisherName, (int)status]];
    
    NSError *error = nil;
    NSArray *results = [[PeachCollector managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
        return [NSArray array];
    }
    return results;
}

+ (NSArray<PeachCollectorPublisherEventStatus *> *)pendingEventsStatusesForPublisherNamed:(NSString *)publisherName
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PeachCollectorPublisherEventStatus"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"publisherName == %@ AND status < %d", publisherName, PCEventStatusPublished]];
    
    NSError *error = nil;
    NSArray *results = [[PeachCollector managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
        return [NSArray array];
    }
    return results;
}

@end
