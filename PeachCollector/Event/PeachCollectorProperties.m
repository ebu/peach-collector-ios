//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@implementation PeachCollectorProperties

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.timeSpent != nil) {
        [representation setObject:self.timeSpent forKey:PCMediaTimeSpentKey];
    }
    if (self.playbackPosition != nil) {
        [representation setObject:self.playbackPosition forKey:PCMediaPlaybackPositionKey];
    }
    if (self.previousPlaybackPosition != nil) {
        [representation setObject:self.previousPlaybackPosition forKey:PCMediaPreviousPlaybackPositionKey];
    }
    if (self.videoMode) {
        [representation setObject:self.videoMode forKey:PCMediaVideoModeKey];
    }
    if (self.audioMode) {
        [representation setObject:self.audioMode forKey:PCMediaAudioModeKey];
    }
    if (self.startMode) {
        [representation setObject:self.startMode forKey:PCMediaStartModeKey];
    }
    if (self.previousMediaID) {
        [representation setObject:self.previousMediaID forKey:PCMediaPreviousIDKey];
    }
    if (self.playbackRate != nil) {
        [representation setObject:self.playbackRate forKey:PCMediaPlaybackRateKey];
    }
    if (self.volume != nil) {
        [representation setObject:self.volume forKey:PCMediaVolumeKey];
    }
    
    if ([representation count] == 0) return nil;
    return [representation copy];
}


@end
