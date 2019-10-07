//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@implementation PeachCollectorProperties

- (nullable NSDictionary *)dictionaryDescription
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
