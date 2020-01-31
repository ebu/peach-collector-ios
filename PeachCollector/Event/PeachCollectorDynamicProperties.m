//
//  PeachCollectorDynamicProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 26.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorDynamicProperties.h"

@implementation PeachCollectorDynamicProperties

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDescription = [NSMutableDictionary new];
    
    if (self.playlistIDBlock) {
        NSString *playlistID = self.playlistIDBlock();
        if (playlistID != nil) {
            [mutableDescription setObject:playlistID forKey:PCMediaPlaylistIDKey];
        }
    }
    if (self.insertPositionBlock) {
        NSString *insertPosition = self.insertPositionBlock();
        if (insertPosition != nil) {
            [mutableDescription setObject:insertPosition forKey:PCMediaInsertPositionKey];
        }
    }
    if (self.timeSpentBlock) {
        NSNumber *timeSpent = self.timeSpentBlock();
        if (timeSpent != nil) {
            [mutableDescription setObject:timeSpent forKey:PCMediaTimeSpentKey];
        }
    }
    if (self.playbackPositionBlock) {
        NSNumber *playbackPosition = self.playbackPositionBlock();
        if (playbackPosition != nil) {
            [mutableDescription setObject:playbackPosition forKey:PCMediaPlaybackPositionKey];
        }
    }
    if (self.previousPlaybackPositionBlock) {
        NSNumber *previousPlaybackPosition = self.previousPlaybackPositionBlock();
        if (previousPlaybackPosition != nil) {
            [mutableDescription setObject:previousPlaybackPosition forKey:PCMediaPreviousPlaybackPositionKey];
        }
    }
    if (self.isPlayingBlock) {
        NSNumber *isPlaying = self.isPlayingBlock();
        if (isPlaying != nil) {
            [mutableDescription setObject:isPlaying forKey:PCMediaIsPlayingKey];
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
        if (playbackRate != nil) {
            [mutableDescription setObject:playbackRate forKey:PCMediaPlaybackRateKey];
        }
    }
    if (self.volumeBlock) {
        NSNumber *volume = self.volumeBlock();
        if (volume != nil) {
            [mutableDescription setObject:volume forKey:PCMediaVolumeKey];
        }
    }
    
    if ([mutableDescription count] == 0) return nil;
    return [mutableDescription copy];
}

@end
