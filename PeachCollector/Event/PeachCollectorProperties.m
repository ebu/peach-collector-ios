//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@implementation PeachCollectorProperties

- (instancetype)initWithPlaybackPosition:(nullable NSNumber *)playbackPosition
                previousPlaybackPosition:(nullable NSNumber *)previousPlaybackPosition
                               videoMode:(nullable PCMediaVideoMode)videoMode
                               audioMode:(nullable PCMediaAudioMode)audioMode
                              start_mode:(nullable PCMediaStartMode)startMode
                         previousMediaID:(nullable NSString *)previousMediaID
                            playbackRate:(nullable NSNumber *)playbackRate
                                  volume:(nullable NSNumber *)volume
{
    self = [super init];
    if (self) {
        _playbackPosition = playbackPosition;
        _previousPlaybackPosition = previousPlaybackPosition;
        _videoMode = videoMode;
        _audioMode = audioMode;
        _startMode = startMode;
        _previousMediaID = previousMediaID;
        _playbackRate = playbackRate;
        _volume = volume;
    }
    return self;
}

- (NSDictionary *)dictionaryDescription
{
    NSMutableDictionary *mutableDescription = [NSMutableDictionary new];
    
    if (self.playbackPosition) {
        [mutableDescription setObject:self.playbackPosition forKey:@"playback_position_s"];
    }
    if (self.previousPlaybackPosition) {
        [mutableDescription setObject:self.previousPlaybackPosition forKey:@"previous_playback_position_s"];
    }
    if (self.videoMode) {
        [mutableDescription setObject:self.videoMode forKey:@"video_mode"];
    }
    if (self.audioMode) {
        [mutableDescription setObject:self.audioMode forKey:@"audio_mode"];
    }
    if (self.startMode) {
        [mutableDescription setObject:self.startMode forKey:@"start_mode"];
    }
    if (self.previousMediaID) {
        [mutableDescription setObject:self.startMode forKey:@"previous_id"];
    }
    if (self.playbackRate) {
        [mutableDescription setObject:self.startMode forKey:@"playback_rate"];
    }
    if (self.volume) {
        [mutableDescription setObject:self.volume forKey:@"volume"];
    }
    
    if ([mutableDescription count] == 0) return nil;
    return [mutableDescription copy];
}

@end
