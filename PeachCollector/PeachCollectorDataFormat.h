//
//  PeachCollectorDataFormat.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NSString * PCClientDeviceType NS_TYPED_ENUM;
OBJC_EXPORT PCClientDeviceType const PCClientDeviceTypePhone;
OBJC_EXPORT PCClientDeviceType const PCClientDeviceTypeTablet;
OBJC_EXPORT PCClientDeviceType const PCClientDeviceTypeDesktop;
OBJC_EXPORT PCClientDeviceType const PCClientDeviceTypeTVBox;
OBJC_EXPORT PCClientDeviceType const PCClientDeviceTypeWearable;

typedef NSString * PCMediaVideoMode NS_TYPED_ENUM;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeBar;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeMini;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeNormal;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeWide;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModePip;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeFullScreen;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModeCast;
OBJC_EXPORT PCMediaVideoMode const PCMediaVideoModePreview;

typedef NSString * PCMediaAudioMode NS_TYPED_ENUM;
OBJC_EXPORT PCMediaAudioMode const PCMediaAudioModeNormal;
OBJC_EXPORT PCMediaAudioMode const PCMediaAudioModeBackground;
OBJC_EXPORT PCMediaAudioMode const PCMediaAudioModeMuted;

typedef NSString * PCMediaStartMode NS_TYPED_ENUM;
OBJC_EXPORT PCMediaStartMode const PCMediaStartModeNormal;
OBJC_EXPORT PCMediaStartMode const PCMediaStartModeAutoPlay;
OBJC_EXPORT PCMediaStartMode const PCMediaStartModeAutoContinue;

typedef NSString * PCMediaMetadataType NS_TYPED_ENUM;
OBJC_EXPORT PCMediaMetadataType const PCMediaMetadataTypeAudio;
OBJC_EXPORT PCMediaMetadataType const PCMediaMetadataTypeVideo;
OBJC_EXPORT PCMediaMetadataType const PCMediaMetadataTypeArticle;
OBJC_EXPORT PCMediaMetadataType const PCMediaMetadataTypePage;

typedef NSString * PCMediaMetadataFormat NS_TYPED_ENUM;
OBJC_EXPORT PCMediaMetadataFormat const PCMediaMetadataFormatOnDemand;
OBJC_EXPORT PCMediaMetadataFormat const PCMediaMetadataFormatLive;
OBJC_EXPORT PCMediaMetadataFormat const PCMediaMetadataFormatDVR;

typedef NSString * PCEventType NS_TYPED_ENUM;
OBJC_EXPORT PCEventType const PCEventTypeMediaPlay;
OBJC_EXPORT PCEventType const PCEventTypeMediaPause;
OBJC_EXPORT PCEventType const PCEventTypeMediaStop;
OBJC_EXPORT PCEventType const PCEventTypeMediaSeek;
OBJC_EXPORT PCEventType const PCEventTypeMediaVideoModeChanged;
OBJC_EXPORT PCEventType const PCEventTypeMediaAudioChanged;
OBJC_EXPORT PCEventType const PCEventTypeMediaHeartbeat;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationLoaded;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationHit;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationDisplayed;
OBJC_EXPORT PCEventType const PCEventTypeArticleStart;
OBJC_EXPORT PCEventType const PCEventTypeArticleEnd;
OBJC_EXPORT PCEventType const PCEventTypeReadMore;

typedef NS_ENUM(NSInteger, PCEventStatus) {
    PCEventStatusQueued = 0,
    PCEventStatusSentToPublisher = 1,
    PCEventStatusPublished = 2
};

typedef NSDictionary<NSString *, id<NSCopying>> PeachCollectorMetadata;

OBJC_EXPORT NSString * const PeachCollectorDefaultPublisherName;

#pragma mark - Payload known keys

OBJC_EXPORT NSString * const PCMediaPlaybackPositionKey;
OBJC_EXPORT NSString * const PCMediaPreviousPlaybackPositionKey;
OBJC_EXPORT NSString * const PCMediaVideoModeKey;
OBJC_EXPORT NSString * const PCMediaAudioModeKey;
OBJC_EXPORT NSString * const PCMediaStartModeKey;
OBJC_EXPORT NSString * const PCMediaPreviousIDKey;
OBJC_EXPORT NSString * const PCMediaPlaybackRateKey;
OBJC_EXPORT NSString * const PCMediaVolumeKey;
OBJC_EXPORT NSString * const PCContextIDKey;
OBJC_EXPORT NSString * const PCContextItemsKey;
OBJC_EXPORT NSString * const PCContextItemsDisplayedKey;
OBJC_EXPORT NSString * const PCContextHitIndexKey;
OBJC_EXPORT NSString * const PCContextPageURIKey;
OBJC_EXPORT NSString * const PCContextSourceKey;
OBJC_EXPORT NSString * const PCContextComponentKey;
OBJC_EXPORT NSString * const PCContextComponentTypeKey;
OBJC_EXPORT NSString * const PCContextComponentNameKey;
OBJC_EXPORT NSString * const PCContextComponentVersionKey;

OBJC_EXPORT NSString * const PCPeachSchemaVersionKey;
OBJC_EXPORT NSString * const PCPeachFrameworkVersionKey;
OBJC_EXPORT NSString * const PCPeachImplementationVersionKey;
OBJC_EXPORT NSString * const PCSentTimestampKey;

OBJC_EXPORT NSString * const PCEventsKey;
OBJC_EXPORT NSString * const PCEventTypeKey;
OBJC_EXPORT NSString * const PCEventIDKey;
OBJC_EXPORT NSString * const PCEventTimestampKey;
OBJC_EXPORT NSString * const PCEventContextKey;
OBJC_EXPORT NSString * const PCEventPropertiesKey;
OBJC_EXPORT NSString * const PCEventMetadataKey;

OBJC_EXPORT NSString * const PCClientKey;
OBJC_EXPORT NSString * const PCClientKey;
OBJC_EXPORT NSString * const PCClientIDKey;
OBJC_EXPORT NSString * const PCClientTypeKey;
OBJC_EXPORT NSString * const PCClientAppIDKey;
OBJC_EXPORT NSString * const PCClientAppNameKey;
OBJC_EXPORT NSString * const PCClientAppVersionKey;
OBJC_EXPORT NSString * const PCClientDeviceKey;
OBJC_EXPORT NSString * const PCClientDeviceTypeKey;
OBJC_EXPORT NSString * const PCClientDeviceVendorKey;
OBJC_EXPORT NSString * const PCClientDeviceModelKey;
OBJC_EXPORT NSString * const PCClientDeviceScreenSizeKey;
OBJC_EXPORT NSString * const PCClientDeviceLanguageKey;
OBJC_EXPORT NSString * const PCClientDeviceTimezoneKey;
OBJC_EXPORT NSString * const PCClientOSKey;
OBJC_EXPORT NSString * const PCClientOSNameKey;
OBJC_EXPORT NSString * const PCClientOSVersionKey;
OBJC_EXPORT NSString * const PCClientUserIDKey;

#pragma mark - Publisher related constants

typedef NS_ENUM(NSInteger, PCPublisherGotBackOnlinePolicy) {
    PCPublisherGotBackOnlinePolicySendAll,
    PCPublisherGotBackOnlinePolicySendBatchesRandomly,
    PCPublisherGotBackOnlinePolicySendAllAfterRandomDelay
};

OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherMaxEvents;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherInterval;
OBJC_EXPORT PCPublisherGotBackOnlinePolicy const PeachCollectorDefaultPublisherPolicy;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherHeartbeatInterval;

NS_ASSUME_NONNULL_END
