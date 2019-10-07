//
//  PeachCollectorDynamicProperties.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 26.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollector.h"
#import "PeachCollectorProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorDynamicProperties : PeachCollectorProperties

@property (nonatomic, copy, nullable) NSNumber *(^timeSpentBlock)(void);
@property (nonatomic, copy, nullable) NSNumber *(^playbackPositionBlock)(void);
@property (nonatomic, copy, nullable) NSNumber *(^previousPlaybackPositionBlock)(void);
@property (nonatomic, copy, nullable) NSString *(^previousMediaIDBlock)(void);
@property (nonatomic, copy, nullable) NSNumber *(^playbackRateBlock)(void);
@property (nonatomic, copy, nullable) NSNumber *(^volumeBlock)(void);
@property (nonatomic, copy, nullable) PCMediaVideoMode(^videoModeBlock)(void);
@property (nonatomic, copy, nullable) PCMediaAudioMode(^audioModeBlock)(void);
@property (nonatomic, copy, nullable) PCMediaStartMode(^startModeBlock)(void);

@end

NS_ASSUME_NONNULL_END
