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
 */
@property (class, nonatomic, readonly) PeachCollector *sharedCollector;

/**
 *  List of publishers referenced by a unique ID
 *
 *  A default PeachCollector Publisher is created when the Queue is initialized : "Peach Publisher"
 *  A custom Publisher can be added to send the events to another end point in a different format.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, PeachCollectorPublisher *>  *publishers;
@property (class, nonatomic, readonly) PeachCollectorPublisher *defaultPublisher;
+ (PeachCollectorPublisher *)publisherNamed:(NSString *)publisherName;
+ (void)addPublisher:(PeachCollectorPublisher *)publisher withName:(NSString *)publisherName;

@property (nonatomic, copy) NSString *userID;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
+ (NSManagedObjectContext *)managedObjectContext;

/**
 *  Configure the collector. This is required before starting the collector. If not set, collector will not start
 *
 *  @param configuration The configuration to use. This configuration is copied and cannot be changed afterwards.
 */
+ (void)startWithConfiguration:(PeachCollectorConfiguration *)configuration;

/**
 *  Add an event to be queued. Event will be added to the queue and sent accordingly to publisher's configuration.
 *
 *  @param event    The event to send.
 */
+ (void)addEventToQueue:(PeachCollectorEvent *)event;


@end

NS_ASSUME_NONNULL_END
