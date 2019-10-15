//
//  PeachCollectorQueue.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorPublisher.h"
#import "PeachCollectorEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorQueue : NSObject

/**
 *  Reset all statuses for queued events to 'queued'. Should be called at launch
 */
- (void)resetStatuses;

/**
 *  Add an event to the queue.
 *  @param event the event to add.
 */
- (void)addEvent:(PeachCollectorEvent *)event;

/**
 *  Flush the queue for all publishers (tries to send everything that is queued)
 */
- (void)flush;

/**
 *  Check queue state for each publisher:
 *  If a publisher has enough events in queue, they are sent for processing.
 *  If there are events but no timer, start the timer with the needed interval
 */
- (void)checkPublishers;

/**
 *  Check queue state for given publisher
 *  If the publisher has enough events in queue, they are sent for processing.
 *  If there are events but no timer, a timer is started with the needed interval
 *  @param publisherName The name of the publisher
 */
- (void)checkPublisherNamed:(NSString *)publisherName;

- (void)cleanTimers;

@end

NS_ASSUME_NONNULL_END
