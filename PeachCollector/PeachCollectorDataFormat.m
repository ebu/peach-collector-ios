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

NSString * const PCMediaPlaybackPositionKey = @"playback_position_s";
NSString * const PCMediaPreviousPlaybackPositionKey = @"previous_playback_position_s";
NSString * const PCMediaVideoModeKey = @"video_mode";
NSString * const PCMediaAudioModeKey = @"audio_mode";
NSString * const PCMediaStartModeKey = @"start_mode";
NSString * const PCMediaPreviousIDKey = @"previous_id";
NSString * const PCMediaPlaybackRateKey = @"playback_rate";
NSString * const PCMediaVolumeKey = @"volume";

NSString * const PCContextIDKey = @"id";
NSString * const PCContextItemsKey = @"items";
NSString * const PCContextItemsDisplayedKey = @"items_displayed";
NSString * const PCContextHitIndexKey = @"hit_index";
NSString * const PCContextPageURIKey = @"page_uri";
NSString * const PCContextSourceKey = @"source";
NSString * const PCContextComponentKey = @"component";
NSString * const PCContextComponentTypeKey = @"type";
NSString * const PCContextComponentNameKey = @"name";
NSString * const PCContextComponentVersionKey = @"version";

NSString * const PCPeachSchemaVersionKey = @"peach_schema_version";
NSString * const PCPeachImplementationVersionKey = @"peach_implementation_version";
NSString * const PCSentTimestampKey = @"sent_timestamp";

NSString * const PCEventsKey = @"events";
NSString * const PCEventTypeKey = @"type";
NSString * const PCEventIDKey = @"id";
NSString * const PCEventTimestampKey = @"event_timestamp";
NSString * const PCEventContextKey = @"context";
NSString * const PCEventPropertiesKey = @"props";
NSString * const PCEventMetadataKey = @"metadata";

NSString * const PCClientKey = @"client";
NSString * const PCClientIDKey = @"id";
NSString * const PCClientTypeKey = @"type";
NSString * const PCClientAppIDKey = @"app_id";
NSString * const PCClientAppNameKey = @"name";
NSString * const PCClientAppVersionKey = @"version";
NSString * const PCClientDeviceKey = @"device";
NSString * const PCClientDeviceTypeKey = @"type";
NSString * const PCClientDeviceVendorKey = @"vendor";
NSString * const PCClientDeviceModelKey = @"model";
NSString * const PCClientDeviceScreenSizeKey = @"screen_size";
NSString * const PCClientDeviceLanguageKey = @"language";
NSString * const PCClientDeviceTimezoneKey = @"timezone";
NSString * const PCClientOSKey = @"os";
NSString * const PCClientOSNameKey = @"name";
NSString * const PCClientOSVersionKey = @"version";

NSString * const PCClientUserIDKey = @"user_id";


NSString * const PeachCollectorDefaultPublisherName = @"Peach Publisher";
NSInteger const PeachCollectorDefaultPublisherMaxEvents = 20;
NSInteger const PeachCollectorDefaultPublisherInterval = 30;
PCPublisherGotBackOnlinePolicy const PeachCollectorDefaultPublisherPolicy = PCPublisherGotBackOnlinePolicySendAll;
NSInteger const PeachCollectorDefaultPublisherHeartbeatInterval = 5;

@implementation PeachCollectorDataFormat

@end