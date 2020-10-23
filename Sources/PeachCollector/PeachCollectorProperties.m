//
//  PeachCollectorProperties.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorProperties.h"

@interface PeachCollectorProperties()

@property (nonatomic, strong) NSDictionary *customFields;

@end

@implementation PeachCollectorProperties

- (id)copyWithZone:(NSZone*)zone
{
    PeachCollectorProperties *copyObject = [PeachCollectorProperties new];
    copyObject.playlistID = [self.playlistID copyWithZone:zone];
    copyObject.insertPosition = [self.insertPosition copyWithZone:zone];
    copyObject.timeSpent = [self.timeSpent copyWithZone:zone];
    copyObject.playbackPosition = [self.playbackPosition copyWithZone:zone];
    copyObject.previousPlaybackPosition = [self.previousPlaybackPosition copyWithZone:zone];
    copyObject.isPlaying = [self.isPlaying copyWithZone:zone];
    copyObject.videoMode = [self.videoMode copyWithZone:zone];
    copyObject.audioMode = [self.audioMode copyWithZone:zone];
    copyObject.startMode = [self.startMode copyWithZone:zone];
    copyObject.previousMediaID = [self.previousMediaID copyWithZone:zone];
    copyObject.playbackRate = [self.playbackRate copyWithZone:zone];
    copyObject.volume = [self.volume copyWithZone:zone];
    copyObject.customFields = [self.customFields copyWithZone:zone];
    return copyObject;
}


#pragma mark - Custom fields

- (void)addObject:(id)object forKey:(nonnull NSString *)key
{
    if (object == nil) {
        [self removeCustomField:key];
    }
    else if (self.customFields != nil) {
        NSMutableDictionary *mutableCustomFields = [self.customFields mutableCopy];
        [mutableCustomFields setObject:object forKey:key];
        self.customFields = [mutableCustomFields copy];
    }
    else {
        self.customFields = @{key: object};
    }
}

- (void)addNumber:(NSNumber *)number forKey:(nonnull NSString *)key
{
    [self addObject:number forKey:key];
}

- (void)addString:(NSString *)string forKey:(nonnull NSString *)key
{
    [self addObject:string forKey:key];
}

- (void)removeCustomField:(nonnull NSString *)key
{
    if(self.customFields != nil) {
        if ([[self.customFields allKeys] containsObject:key]) {
            NSMutableDictionary *mutableCustomFields = [self.customFields mutableCopy];
            [mutableCustomFields removeObjectForKey:key];
            self.customFields = [mutableCustomFields copy];
        }
        if (self.customFields.count == 0) {
            self.customFields = nil;
        }
    }
}

- (nullable id)valueForCustomField:(nonnull NSString *)key
{
    if (self.customFields != nil) {
        return [self.customFields valueForKey:key];
    }
    return nil;
}

#pragma mark - JSON Format

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.playlistID != nil) {
        [representation setObject:self.playlistID forKey:PCMediaPlaylistIDKey];
    }
    if (self.insertPosition != nil) {
        [representation setObject:self.insertPosition forKey:PCMediaInsertPositionKey];
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
    if (self.isPlaying != nil) {
        [representation setObject:self.isPlaying forKey:PCMediaIsPlayingKey];
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
    if (self.customFields != nil) {
        for (NSString *key in self.customFields.allKeys) {
            [representation setObject:[self.customFields objectForKey:key] forKey:key];
        }
    }
    
    if ([representation count] == 0) return nil;
    return [representation copy];
}


@end
