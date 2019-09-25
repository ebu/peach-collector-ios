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

- (void)addEvent:(PeachCollectorEvent *)event;
- (void)flush;
- (void)empty;
- (void)checkPublishers;

@end

NS_ASSUME_NONNULL_END
