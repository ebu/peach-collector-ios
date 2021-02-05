//
//  PeachCollector.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "PeachCollectorNotifications.h"
#import "PeachCollectorEvent.h"
#import "PeachCollectorPublisher.h"
#import "PeachCollectorPublisherEventStatus.h"
#import "PeachCollectorProperties.h"
#import "PeachCollectorDynamicProperties.h"
#import "PeachCollectorContext.h"
#import "PeachCollectorDataFormat.h"
#import "PeachCollectorQueue.h"
#import "PeachCollectorDataStore.h"

//! Project version number for PeachCollector.
FOUNDATION_EXPORT double PeachCollectorVersionNumber;

//! Project version string for PeachCollector.
FOUNDATION_EXPORT const unsigned char PeachCollectorVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollector : NSObject

/**
 *  PeachCollector marketing version followed by build number (for example: "1.1.1-25")
 */
@property (class, nonatomic, copy, readonly) NSString *version;

/**
 *  Implementation version of the framework
 *  Value is null by default, it will not be sent unless set
 */
@property (class, nonatomic, copy, nullable) NSString *implementationVersion;

/**
 *  Timestamp of the start of the session
 */
@property (class, nonatomic, readonly) NSInteger sessionStartTimestamp;

/**
 *  Minimum duration (in seconds) of inactivity that will cause sessionStartTimestamp to be reset when app becomes active
 *  Default is 1800 seconds (30 minutes)
 */
@property (class, nonatomic) NSInteger inactivityInterval;

@property (class, nonatomic) NSInteger maximumStorageDays;
@property (class, nonatomic) NSInteger maximumStoredEvents;

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

/**
 *  Device unique identifier (advertising identifier when ad tracking is not limited, "Anonymous" otherwise)
 */
@property (class, nonatomic, readonly) NSString *deviceID;

/**
 *  User unique identifier when logged in
 */
@property (class, nonatomic, copy, nullable) NSString *userID;

/**
 *  Optionnal App ID that will be sent in the `client` payload. The default value is the bundle ID of the app.
 */
@property (class, nonatomic, copy, nullable) NSString *appID;


/**
 *  A userID can be generated automatically for anonymous user. You can use this flag to define if the user is logged in or not when there is a userID.
 */
@property (class, nonatomic, assign) BOOL userIsLoggedIn;


/**
 *  Add an event to be queued. Event will be added to the queue and sent accordingly to publisher's configuration.
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


/**
 *  The Device ID used by the framework is the Advertising ID provided by Apple.
 *  This Id can be reseted or event null. If the Advertising Id is null and the user is not logged in,
 *  collecting of the events should be stopped unless if it is needed for anonymous analytics.
 *  When set to `YES`, collection will work even if there is no Device ID and User ID
 *  Default value is `NO`.
 */
@property (nonatomic) BOOL shouldCollectAnonymousEvents;

/**
 *  Returns `YES` if a `userID` has been defined or if an advertising ID is available.
 *  If not, it will return the value of `shouldCollectAnonymousEvents`
*/
+ (BOOL)shouldCollectEvents;


/**
 *  When set to `YES`, notifications will be emitted when events are recorded and when they are sent
 *  @see PeachColletorNotifications.h
 *  Default value is `NO`.
 */
@property (nonatomic) BOOL isUnitTesting;

/**
 *  CodeData Stack accessor with tools to avoid concurency problems
 */
@property (class, readonly) PeachCollectorDataStore *dataStore;

/**
 *  Flush the queue for all publishers (tries to send everything that is queued)
 */
+ (void)flush;

/**
 *  Remove all previously queued events
 */
+ (void)clean;

@end

NS_ASSUME_NONNULL_END
