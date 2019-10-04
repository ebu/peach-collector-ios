//
//  PeachCollector.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <PeachCollector/PeachCollectorConfiguration.h>
#import <PeachCollector/PeachCollectorDynamicProperties.h>
#import <PeachCollector/PeachCollectorEvent.h>
#import <PeachCollector/PeachCollectorPublisher.h>
#import <PeachCollector/PeachCollectorPublisherEventStatus.h>
#import <PeachCollector/PeachCollectorProperties.h>
#import <PeachCollector/PeachCollectorContext.h>
#import <PeachCollector/PeachCollectorDataFormat.h>
#import <PeachCollector/PeachCollectorQueue.h>

//! Project version number for PeachCollector.
FOUNDATION_EXPORT double PeachCollectorVersionNumber;

//! Project version string for PeachCollector.
FOUNDATION_EXPORT const unsigned char PeachCollectorVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollector : NSObject

/**
 *  The collector singleton.
 *  Singleton is automatically created at the launch of the application
 */
@property (class, nonatomic, readonly) PeachCollector *sharedCollector;

/**
 *  List of publishers referenced by a unique ID
 */
@property (nonatomic, readonly) NSDictionary<NSString *, PeachCollectorPublisher *>  *publishers;

/**
 *  Retrieves a Publisher by its name
 *  @param publisherName The name of the publisher.
 */
+ (PeachCollectorPublisher *)publisherNamed:(NSString *)publisherName;

/**
 *  Adds a publisher to the list of publishers linked to the queue
 *  A custom Publisher can send the events to another end point, potentially in a different format.
 *  @param publisher The publisher to add.
 *  @param publisherName The unique name of the publisher.
 */
+ (void)setPublisher:(PeachCollectorPublisher *)publisher withUniqueName:(NSString *)publisherName;

@property (nonatomic, copy) NSString *userID;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
+ (NSManagedObjectContext *)managedObjectContext;

/**
 *  Add an event to be queued. Event will be added to the queue and sent accordingly to publisher's configuration.
 *
 *  @param event    The event to send.
 */
+ (void)addEventToQueue:(PeachCollectorEvent *)event;

/**
 *  List type of events that should force the queue to be flushed if added while in background state
 */
@property (nonatomic, readonly) NSArray<NSString *> *flushableEventTypes;

/**
 *  Add an event type to list of events that force the queue to be flushed when in background state
 *
 *  @param eventType The event type to add to the list.
 */
+ (void)addFlushableEventType:(NSString *)eventType;

@end

NS_ASSUME_NONNULL_END
