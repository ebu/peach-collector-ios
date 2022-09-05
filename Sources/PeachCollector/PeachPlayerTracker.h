//
//  PeachPlayerTracker.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 10.07.22.
//  Copyright © 2022 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollector.h"
#import "PeachCollectorEvent.h"
#import "PeachCollectorContext.h"
#import "PeachCollectorProperties.h"
#import "PeachCollectorDataFormat.h"

NS_ASSUME_NONNULL_BEGIN

@class AVPlayerItem, AVPlayer;

@interface PeachPlayerTracker : NSObject

+ (void)setPlayer:(AVPlayer *)player;
+ (void)trackItemWithID:(NSString *)itemID context:(nullable PeachCollectorContext *)context props:(nullable PeachCollectorProperties *)props metadata:(nullable PeachCollectorMetadata *)metadata;
+ (void)clearCurrentItem;

@end

NS_ASSUME_NONNULL_END
