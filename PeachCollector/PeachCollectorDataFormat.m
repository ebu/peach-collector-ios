//
//  PeachCollectorDataFormat.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorDataFormat.h"

PCClientDeviceType const PCClientDeviceTypePhone = @"phone";
PCClientDeviceType const PCClientDeviceTypeTablet = @"tablet";
PCClientDeviceType const PCClientDeviceTypeDesktop = @"desktop";
PCClientDeviceType const PCClientDeviceTypeTVBox = @"tvbox";
PCClientDeviceType const PCClientDeviceTypeWearable = @"wearable";

PCMediaVideoMode const PCMediaVideoModeBar = @"bar";
PCMediaVideoMode const PCMediaVideoModeMini = @"mini";
PCMediaVideoMode const PCMediaVideoModeNormal = @"normal";
PCMediaVideoMode const PCMediaVideoModeWide = @"wide";
PCMediaVideoMode const PCMediaVideoModePip = @"pip";
PCMediaVideoMode const PCMediaVideoModeFullScreen = @"fullscreen";
PCMediaVideoMode const PCMediaVideoModeCast = @"cast";
PCMediaVideoMode const PCMediaVideoModePreview = @"preview";

PCMediaAudioMode const PCMediaAudioModeNormal = @"normal";
PCMediaAudioMode const PCMediaAudioModeBackground = @"background";
PCMediaAudioMode const PCMediaAudioModeMuted = @"muted";

PCMediaStartMode const PCMediaStartModeNormal = @"normal";
PCMediaStartMode const PCMediaStartModeAutoPlay = @"auto_play";
PCMediaStartMode const PCMediaStartModeAutoContinue = @"auto_continue";

PCMediaMetadataType const PCMediaMetadataTypeAudio = @"audio";
PCMediaMetadataType const PCMediaMetadataTypeVideo = @"video";
PCMediaMetadataType const PCMediaMetadataTypeArticle = @"article";
PCMediaMetadataType const PCMediaMetadataTypePage = @"page";

PCMediaMetadataFormat const PCMediaMetadataFormatOnDemand = @"ondemand";
PCMediaMetadataFormat const PCMediaMetadataFormatLive = @"live";
PCMediaMetadataFormat const PCMediaMetadataFormatDVR = @"dvr";


PCEventType const PCEventTypeMediaPlay = @"media_play"; // MEDIA
PCEventType const PCEventTypeMediaPause = @"media_pause";
PCEventType const PCEventTypeMediaStop = @"media_stop";
PCEventType const PCEventTypeMediaSeek = @"media_seek";
PCEventType const PCEventTypeMediaVideoModeChanged = @"media_video_mode_changed";
PCEventType const PCEventTypeMediaAudioChanged = @"media_audio_changed";
PCEventType const PCEventTypeMediaHeartbeat = @"media_heartbeat";
PCEventType const PCEventTypeRecommendationLoaded = @"recommendation_loaded"; // RECOMMENDATION
PCEventType const PCEventTypeRecommendationHit = @"recommendation_hit";
PCEventType const PCEventTypeRecommendationDisplayed = @"recommendation_displayed";
PCEventType const PCEventTypeArticleStart = @"article_start"; // ARTICLE
PCEventType const PCEventTypeArticleEnd = @"article_end";
PCEventType const PCEventTypeReadMore = @"read_more";

NSString * const PeachCollectorNotification = @"PeachCollectorNotification";
NSString * const PeachCollectorNotificationLogKey = @"PeachCollectorNotificationLogKey";
NSString * const PeachCollectorNotificationQueuedEventsKey = @"PeachCollectorNotificationQueuedEventsKey";

NSString * const PeachCollectorDefaultPublisherName = @"Peach Publisher";

NSString * const PeachCollectorPlaybackPositionKey = @"playback_position_s";


NSInteger const PeachCollectorDefaultPublisherMaxEvents = 20;
NSInteger const PeachCollectorDefaultPublisherInterval = 30;
PCPublisherGotBackOnlinePolicy const PeachCollectorDefaultPublisherPolicy = PCPublisherGotBackOnlinePolicySendAll;
NSInteger const PeachCollectorDefaultPublisherHeartbeatInterval = 5;

@implementation PeachCollectorDataFormat

@end
