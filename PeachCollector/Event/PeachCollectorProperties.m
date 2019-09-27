//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@implementation PeachCollectorProperties

- (instancetype)initWithTimeSpent:(nullable NSNumber *)timeSpent
                 playbackPosition:(nullable NSNumber *)playbackPosition
         previousPlaybackPosition:(nullable NSNumber *)previousPlaybackPosition
                  previousMediaID:(nullable NSString *)previousMediaID
                     playbackRate:(nullable NSNumber *)playbackRate
                           volume:(nullable NSNumber *)volume
                        videoMode:(nullable PCMediaVideoMode)videoMode
                        audioMode:(nullable PCMediaAudioMode)audioMode
                        startMode:(nullable PCMediaStartMode)startMode
{
    self = [super init];
    if (self) {
        _timeSpent = timeSpent;
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
        [mutableDescription setObject:self.playbackPosition forKey:PCMediaPlaybackPositionKey];
    }
    if (self.previousPlaybackPosition) {
        [mutableDescription setObject:self.previousPlaybackPosition forKey:PCMediaPreviousPlaybackPositionKey];
    }
    if (self.videoMode) {
        [mutableDescription setObject:self.videoMode forKey:PCMediaVideoModeKey];
    }
    if (self.audioMode) {
        [mutableDescription setObject:self.audioMode forKey:PCMediaAudioModeKey];
    }
    if (self.startMode) {
        [mutableDescription setObject:self.startMode forKey:PCMediaStartModeKey];
    }
    if (self.previousMediaID) {
        [mutableDescription setObject:self.previousMediaID forKey:PCMediaPreviousIDKey];
    }
    if (self.playbackRate) {
        [mutableDescription setObject:self.playbackRate forKey:PCMediaPlaybackRateKey];
    }
    if (self.volume) {
        [mutableDescription setObject:self.volume forKey:PCMediaVolumeKey];
    }
    
    if ([mutableDescription count] == 0) return nil;
    return [mutableDescription copy];
}


@end
