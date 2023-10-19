//
//  PeachPlayerTracker.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 10.07.22.
//  Copyright © 2022 European Broadcasting Union. All rights reserved.
//

#import "PeachPlayerTracker.h"
@import AVFoundation;

@interface PeachPlayerTracker()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) PeachCollectorContext *context;
@property (nonatomic, strong) PeachCollectorProperties *props;
@property (nonatomic, strong) PeachCollectorMetadata *metadata;
@property (nonatomic, strong) NSDate *trackingStartDate;
@property (nonatomic, strong) NSNumber *lastRecordedPlaybackTime;
@property (nonatomic, strong) NSMutableDictionary *lastHeartbeatDates;

@property (nonatomic, strong) NSString *currentState;

@property (class, nonatomic, readonly) PeachPlayerTracker *sharedTracker;

@end

@implementation PeachPlayerTracker

+ (instancetype)sharedTracker
{
    static PeachPlayerTracker *s_sharedInstance = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_sharedInstance = [[PeachPlayerTracker alloc] init];
    });
    return s_sharedInstance;
}

+ (void)setPlayer:(AVPlayer *)player{
    PeachPlayerTracker.sharedTracker.player = player;
    [PeachPlayerTracker.sharedTracker.player addObserver:PeachPlayerTracker.sharedTracker forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [PeachPlayerTracker.sharedTracker.player addObserver:PeachPlayerTracker.sharedTracker forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak AVPlayer *periodicPlayer = PeachPlayerTracker.sharedTracker.player;
    __weak PeachPlayerTracker *tracker = PeachPlayerTracker.sharedTracker;
    [PeachPlayerTracker.sharedTracker.player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
        if (periodicPlayer == nil || isnan(CMTimeGetSeconds(periodicPlayer.currentTime))) return;
        [tracker updateLastRecordedPlaybackTime:CMTimeGetSeconds(periodicPlayer.currentTime)];
    }];
}

+ (void)trackItemWithID:(NSString *)itemID context:(nullable PeachCollectorContext *)context props:(nullable PeachCollectorProperties *)props metadata:(nullable PeachCollectorMetadata *)metadata {
    PeachPlayerTracker.sharedTracker.itemID = itemID;
    PeachPlayerTracker.sharedTracker.context = context;
    PeachPlayerTracker.sharedTracker.props = props;
    PeachPlayerTracker.sharedTracker.metadata = metadata;
    PeachPlayerTracker.sharedTracker.lastRecordedPlaybackTime = [NSNumber numberWithFloat:0.f];
    
    if (PeachPlayerTracker.sharedTracker.props == nil) {
        PeachPlayerTracker.sharedTracker.props = [[PeachCollectorProperties alloc] init];
    }
    [PeachPlayerTracker.sharedTracker.props setPlaybackRate:@(1.0)];
    [PeachPlayerTracker.sharedTracker.props setPlaybackPosition:@(0.0)];
    [PeachPlayerTracker.sharedTracker.props setTimeSpent:@(0.0)];
}

+ (void)clearCurrentItem{
    PeachPlayerTracker.sharedTracker.itemID = nil;
    PeachPlayerTracker.sharedTracker.context = nil;
    PeachPlayerTracker.sharedTracker.props = nil;
    PeachPlayerTracker.sharedTracker.metadata = nil;
    PeachPlayerTracker.sharedTracker.lastRecordedPlaybackTime = nil;
    PeachPlayerTracker.sharedTracker.trackingStartDate = nil;
    PeachPlayerTracker.sharedTracker.lastHeartbeatDates = nil;
}


- (void)updateLastRecordedPlaybackTime:(CGFloat)value {
    [self updateTimeSpent];
    [self.props setPlaybackPosition:@(value)];
    if (fabs(value - [self.lastRecordedPlaybackTime floatValue]) > 0.6) {
        [PeachCollectorEvent sendMediaSeekWithID:self.itemID
                                     properties:self.props
                                        context:self.context
                                       metadata:self.metadata];
    }
    self.lastRecordedPlaybackTime = [NSNumber numberWithFloat:value];
    [self checkHeartbeat];
}

- (void)checkHeartbeat {
    [self updateTimeSpent];
    if(self.player.rate != 0.0) {
        if (self.lastHeartbeatDates == nil) self.lastHeartbeatDates = [[NSMutableDictionary alloc] init];
        for (NSString *publisherName in [[[PeachCollector sharedCollector] publishers] allKeys]) {
            PeachCollectorPublisher *publisher = [[[PeachCollector sharedCollector] publishers] objectForKey:publisherName];
            NSInteger heartbeatInterval = publisher.playerTrackerHeartbeatInterval;
            if ([self.lastHeartbeatDates objectForKey:publisherName] == nil ||
                [[NSDate date] timeIntervalSinceDate:[self.lastHeartbeatDates objectForKey:publisherName]] >= heartbeatInterval) {
                
                [self.lastHeartbeatDates setObject:[NSDate date] forKey:publisherName];
                
                [PeachCollectorEvent sendMediaHeartbeatWithID:self.itemID
                                                   properties:self.props
                                                      context:self.context
                                                     metadata:self.metadata
                                                  toPublisher:publisherName];
            }
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {

    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        [self updateTimeSpent];
        if (self.player.status == AVPlayerStatusFailed) {
            self.currentState = @"failed";
        } else if (self.player.status == AVPlayerStatusReadyToPlay) {
            self.currentState = @"ready";
        } else if (self.player.status == AVPlayerItemStatusUnknown) {
            self.currentState = @"unknown";
        }
    }
        
    if (object == self.player && [keyPath isEqualToString:@"rate"]) {
        [self updateTimeSpent];
        if (self.player.error != nil) {
            self.currentState = @"failed";
        }
        else if (self.player.currentItem != nil && CMTimeCompare(self.player.currentItem.duration, kCMTimeIndefinite) != 0 &&
                 CMTimeGetSeconds(self.player.currentTime) >= CMTimeGetSeconds(self.player.currentItem.duration)) {
            self.currentState = @"ended";
            [PeachCollectorEvent sendMediaEndWithID:self.itemID
                                         properties:self.props
                                            context:self.context
                                           metadata:self.metadata];
        }
        else if (!self.player.currentItem.playbackLikelyToKeepUp) {
            self.currentState = @"buffering";
        }
        else {
            if (self.player.rate == 0.0) {
                self.currentState = @"paused";
                [PeachCollectorEvent sendMediaPauseWithID:self.itemID
                                               properties:self.props
                                                  context:self.context
                                                 metadata:self.metadata];
            }
            else {
                if (self.props != nil) {
                    [self.props setPlaybackRate:[NSNumber numberWithFloat:self.player.rate]];
                }
                if (self.currentState == nil || ![self.currentState isEqualToString:@"playing"]) {
                    [self updateTimeSpent];
                    self.currentState = @"playing";
                    [PeachCollectorEvent sendMediaPlayWithID:self.itemID
                                                   properties:self.props
                                                      context:self.context
                                                     metadata:self.metadata];
                }
            }
        }
    }
}

- (void)updateTimeSpent{
    if (self.props != nil){
        if (self.trackingStartDate == nil) {
            self.trackingStartDate = [NSDate date];
        }
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:self.trackingStartDate];
        [self.props setTimeSpent:@(secondsBetween)];
    }
}


@end
