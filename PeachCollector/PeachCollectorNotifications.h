//
//  PeachCollectorNotifications.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 07.10.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The following notifications can be used if you need to track when events are recorded and when they are sent, for unit testing purposes.
 *  These notifications are only emitted when enabling the `unitTesting` tracker flag
 *  @see `PeachCollector.h`.
 *  @note Notifications may be received on background threads.
*/

OBJC_EXPORT NSString * const PeachCollectorNotification;
OBJC_EXPORT NSString * const PeachCollectorNotificationLogKey;
OBJC_EXPORT NSString * const PeachCollectorNotificationQueuedEventsKey;

OBJC_EXPORT NSString * const PeachCollectorReachabilityChangedNotification;

NS_ASSUME_NONNULL_END
