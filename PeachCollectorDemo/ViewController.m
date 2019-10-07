//
//  ViewController.m
//  PeachCollectorDemo
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "ViewController.h"
@import PeachCollector;
@import AVFoundation;
@import MediaPlayer;

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *playAudioButton;

@property (nonatomic) BOOL audioInitialized;
@property (nonatomic) BOOL audioPlaying;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) PeachCollectorProperties *audioProperties;
@property (nonatomic, strong) PeachCollectorContext *audioContext;
@property (nonatomic, strong) PeachCollectorMetadata *audioMetadata;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(logNotificationReceived:) name:PeachCollectorNotification object:nil];
    
    
}


- (void)logNotificationReceived:(NSNotification *)notification
{
    NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
    
    NSLog(@"%@", logString);
}

- (IBAction)recommendationHit:(id)sender
{
    NSInteger index = 0;
    PeachCollectorContextComponent *carouselComponent = [PeachCollectorContextComponent new];
    carouselComponent.type = @"Carousel";
    carouselComponent.name = @"recoCarousel";
    carouselComponent.version = @"1.0";
    
    [PeachCollectorEvent sendRecommendationHitWithID:[NSString stringWithFormat:@"reco%02d", (int)index]
                                               items:@[@"reco00", @"reco01", @"reco02", @"reco03"]
                                      itemsDisplayed:3
                                            hitIndex:index
                                        appSectionID:@"news/videos"
                                              source:nil
                                           component:carouselComponent];
    
    
}

- (IBAction)playAudio:(id)sender
{
    if (!self.audioInitialized) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:true error:nil];

        [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] addTarget:self action:@selector(onPlayCommand:)];
        [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] addTarget:self action:@selector(onPauseCommand:)];
        
        NSDictionary *metadata = @{MPMediaItemPropertyTitle: @"Peach Demo Audio"};
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:metadata];
        
        self.audioProperties = [PeachCollectorProperties new];
        self.audioProperties.audioMode = PCMediaAudioModeNormal;
        self.audioProperties.startMode = PCMediaStartModeNormal;
        
        self.audioMetadata = @{@"type": PCMediaMetadataTypeAudio, @"format": PCMediaMetadataFormatLive};
        
        PeachCollectorContextComponent * component = [PeachCollectorContextComponent new];
        component.type = @"player";
        component.name = @"AudioPlayer";
        component.version = @"1.0";
        self.audioContext = [[PeachCollectorContext alloc] initMediaContextWithID:@"recoA"
                                                                   component:component
                                                                appSectionID:@"Demo/AudioPlayer"
                                                                      source:@"Demo.reco"];
    }
    
    if (self.player == nil) {
        NSURL *audioUrl = [NSURL URLWithString:@"https://lyssna-cdn.sr.se/Isidor/EREG/sr_varmland/2019/05/37_rekordmanga_kvinnor_antag_21a9b7f_a192.m4a"];
        AVURLAsset *audioAsset = [AVURLAsset assetWithURL:audioUrl];
        AVPlayerItem *audioPlayerItem = [AVPlayerItem playerItemWithAsset:audioAsset];
        //[audioPlayerItem addObserver:self forKeyPath:@"status" options:0 context:ItemStatusContext];
        self.player = [AVPlayer playerWithPlayerItem:audioPlayerItem];
        //[self.player addObserver:self forKeyPath:@"status" options:0 context:PlayerStatusContext];
    }
    [self play];
}

- (IBAction)pauseAudio:(id)sender
{
    [self pause];
}

- (void)recordAudioPlayEvent
{
    NSInteger audioPosition = self.player.currentTime.value/self.player.currentTime.timescale;
    [self.audioProperties setPlaybackPosition:@(audioPosition)];
    
    [PeachCollectorEvent sendMediaPlayWithID:@"audio0001"
                                  properties:self.audioProperties
                                     context:self.audioContext
                                    metadata:self.audioMetadata];
}

- (void)recordAudioPauseEvent
{
    NSInteger audioPosition = self.player.currentTime.value/self.player.currentTime.timescale;
    [self.audioProperties setPlaybackPosition:@(audioPosition)];
    
    [PeachCollectorEvent sendMediaPauseWithID:@"audio0001"
                                   properties:self.audioProperties
                                      context:self.audioContext
                                     metadata:self.audioMetadata];
}

- (MPRemoteCommandHandlerStatus)onPlayCommand:(MPChangePlaybackPositionCommandEvent *)event
{
    [self play];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)onPauseCommand:(MPChangePlaybackPositionCommandEvent *)event
{
    [self pause];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)play{
    [self.player play];
    [self recordAudioPlayEvent];
    [self.playAudioButton removeTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.playAudioButton addTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.playAudioButton setTitle:@"Pause Background Audio" forState:UIControlStateNormal];
}

- (void)pause{
    [self.player pause];
    [self recordAudioPauseEvent];
    [self.playAudioButton removeTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.playAudioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.playAudioButton setTitle:@"Play Background Audio" forState:UIControlStateNormal];
}

@end
