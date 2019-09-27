//
//  PeachCollectorDynamicProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 26.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorDynamicProperties.h"

@implementation PeachCollectorDynamicProperties


- (instancetype)initWithTimeSpentBlock:(nullable NSNumber *(^)(void))timeSpentBlock
                 playbackPositionBlock:(nullable NSNumber *(^)(void))playbackPositionBlock
         previousPlaybackPositionBlock:(nullable NSNumber *(^)(void))previousPlaybackPositionBlock
                        videoModeBlock:(nullable PCMediaVideoMode(^)(void))videoModeBlock
                        audioModeBlock:(nullable PCMediaAudioMode(^)(void))audioModeBlock
                        startModeBlock:(nullable PCMediaStartMode(^)(void))startModeBlock
                  previousMediaIDBlock:(nullable NSString *(^)(void))previousMediaIDBlock
                     playbackRateBlock:(nullable NSNumber *(^)(void))playbackRateBlock
                           volumeBlock:(nullable NSNumber *(^)(void))volumeBlock
{
    self = [super init];
    if (self) {
        _timeSpentBlock = timeSpentBlock;
        _playbackPositionBlock = playbackPositionBlock;
        _previousPlaybackPositionBlock = previousPlaybackPositionBlock;
        _videoModeBlock = videoModeBlock;
        _audioModeBlock = audioModeBlock;
        _startModeBlock = startModeBlock;
        _previousMediaIDBlock = previousMediaIDBlock;
        _playbackRateBlock = playbackRateBlock;
        _volumeBlock = volumeBlock;
    }
    return self;
}


- (NSDictionary *)dictionaryDescription
{
    NSMutableDictionary *mutableDescription = [NSMutableDictionary new];
    
    if (self.playbackPositionBlock) {
        NSNumber *playbackPosition = self.playbackPositionBlock();
        if (playbackPosition) {
            [mutableDescription setObject:playbackPosition forKey:PCMediaPlaybackPositionKey];
        }
    }
    if (self.previousPlaybackPositionBlock) {
        NSNumber *previousPlaybackPosition = self.previousPlaybackPositionBlock();
        if (previousPlaybackPosition) {
            [mutableDescription setObject:previousPlaybackPosition forKey:PCMediaPreviousPlaybackPositionKey];
        }
    }
    if (self.videoModeBlock) {
        PCMediaVideoMode videoMode = self.videoModeBlock();
        if (videoMode) {
            [mutableDescription setObject:videoMode forKey:PCMediaVideoModeKey];
        }
    }
    if (self.audioModeBlock) {
        PCMediaAudioMode audioMode = self.audioModeBlock();
        if (audioMode) {
            [mutableDescription setObject:audioMode forKey:PCMediaAudioModeKey];
        }
    }
    if (self.startModeBlock) {
        PCMediaAudioMode startMode = self.startModeBlock();
        if (startMode) {
            [mutableDescription setObject:startMode forKey:PCMediaStartModeKey];
        }
    }
    if (self.previousMediaIDBlock) {
        NSString *previousMediaID = self.previousMediaIDBlock();
        if (previousMediaID) {
            [mutableDescription setObject:previousMediaID forKey:PCMediaPreviousIDKey];
        }
    }
    if (self.playbackRateBlock) {
        NSNumber *playbackRate = self.playbackRateBlock();
        if (playbackRate) {
            [mutableDescription setObject:playbackRate forKey:PCMediaPlaybackRateKey];
        }
    }
    if (self.volumeBlock) {
        NSNumber *volume = self.volumeBlock();
        if (volume) {
            [mutableDescription setObject:volume forKey:PCMediaVolumeKey];
        }
    }
    
    if ([mutableDescription count] == 0) return nil;
    return [mutableDescription copy];
}

@end
