//
//  PeachCollectorProperties.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PeachCollectorDataFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorProperties : NSObject

/**
 *  The time spent by the user watching this media
 *
 *  @return time spent in seconds.
 */
@property (nonatomic, copy) NSNumber *timeSpent;

/**
 *  Playback position for the media.
 *  For a live stream 0.0 is the max value. A negative value mean a timeshift in the past
 *
 *  @return playback position in seconds.
 */
@property (nonatomic, copy) NSNumber *playbackPosition;
/**
 *  Previous playback position for the media.
 *  For a live stream 0.0 is the max value. A negative value mean a timeshift in the past
 *  Usually used along a media seek event or after a media pause event
 *
 *  @return previous playback position in seconds.
 */
@property (nonatomic, copy) NSNumber *previousPlaybackPosition;

/**
 *  In case of "auto continue" start mode, previousMediaID should be defined
 *
 *  @return previous media identifier
 */
@property (nonatomic, copy) NSString *previousMediaID;

/**
 *  Speed of playback. Value is relative to normal playback speed
 *  - 0.5 for 2x slow motion
 *  - 1 for normal playback
 *  - 2 for fast forward
 *
 *  @return playback rate
 */
@property (nonatomic, copy) NSNumber *playbackRate;

/**
 *  Volume of playback in percentage.
 *  - 0 means the media is muted.
 *  - 1 is 100% volume level
 *
 *  @return volume of playback
 */
@property (nonatomic, copy) NSNumber *volume;

/**
 *  Mode for a video media : bar, mini, normal, wide, pip, fullscreen, cast, preview
 *
 *  @return media video mode
 */
@property (nonatomic, copy) PCMediaVideoMode videoMode;

/**
 *  Describes how the media is listenned to : normal, in background or if it is muted
 *
 *  @return media audio mode
 */
@property (nonatomic, copy) PCMediaAudioMode audioMode;

/**
 *  How the media was started (normal, by "auto play", or by "auto continue")
 *
 *  @return media start mode
 */
@property (nonatomic, copy) PCMediaStartMode startMode;


- (instancetype)initWithTimeSpent:(nullable NSNumber *)timeSpent
                 playbackPosition:(nullable NSNumber *)playbackPosition
         previousPlaybackPosition:(nullable NSNumber *)previousPlaybackPosition
                  previousMediaID:(nullable NSString *)previousMediaID
                     playbackRate:(nullable NSNumber *)playbackRate
                           volume:(nullable NSNumber *)volume
                        videoMode:(nullable PCMediaVideoMode)videoMode
                        audioMode:(nullable PCMediaAudioMode)audioMode
                        startMode:(nullable PCMediaStartMode)startMode;

- (NSDictionary *)dictionaryDescription;

@end

NS_ASSUME_NONNULL_END
