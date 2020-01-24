//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@implementation PeachCollectorProperties

- (id)copyWithZone:(NSZone*)zone
{
    PeachCollectorProperties *copyObject = [PeachCollectorProperties new];
    copyObject.playlistID = [self.playlistID copyWithZone:zone];
    copyObject.timeSpent = [self.timeSpent copyWithZone:zone];
    copyObject.playbackPosition = [self.playbackPosition copyWithZone:zone];
    copyObject.previousPlaybackPosition = [self.previousPlaybackPosition copyWithZone:zone];
    copyObject.videoMode = [self.videoMode copyWithZone:zone];
    copyObject.audioMode = [self.audioMode copyWithZone:zone];
    copyObject.startMode = [self.startMode copyWithZone:zone];
    copyObject.previousMediaID = [self.previousMediaID copyWithZone:zone];
    copyObject.playbackRate = [self.playbackRate copyWithZone:zone];
    copyObject.volume = [self.volume copyWithZone:zone];
    return copyObject;
}

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.playlistID != nil) {
        [representation setObject:self.playlistID forKey:PCMediaPlaylistIDKey];
    }
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
