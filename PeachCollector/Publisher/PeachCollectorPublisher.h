//
//  PeachCollectorPublisher.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorEvent.h"

NS_ASSUME_NONNULL_BEGIN



@interface PeachCollectorPublisher : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic) NSInteger interval;
@property (nonatomic) NSInteger maxEvents;
@property (nonatomic) PCPublisherGotBackOnlinePolicy gotBackPolicy;

- (id)initWithServiceURL:(NSString *)serviceURL
                interval:(NSInteger)interval
               maxEvents:(NSInteger)maxEvents
     gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackPolicy;

- (void)sendEvents:(NSArray<PeachCollectorEvent *> *)events withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;


/**
 *  Return `YES` if the the publisher can process the event. This is used when an event is added to the queue to check
 *  if said event should be added to the publisher's queue.
 *
 *  @param event    The event to be queued.
 *
 *  @return `YES` if the the publisher can process the event, `NO` otherwise.
 */
- (BOOL)shouldProcessEvent:(PeachCollectorEvent *)event;

@end

NS_ASSUME_NONNULL_END
