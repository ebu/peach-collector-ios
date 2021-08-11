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
OBJC_EXPORT PCEventType const PCEventTypeMediaSeek;
OBJC_EXPORT PCEventType const PCEventTypeMediaStop;
OBJC_EXPORT PCEventType const PCEventTypeMediaEnd;
OBJC_EXPORT PCEventType const PCEventTypeMediaShare;
OBJC_EXPORT PCEventType const PCEventTypeMediaLike;
OBJC_EXPORT PCEventType const PCEventTypeMediaVideoModeChanged;
OBJC_EXPORT PCEventType const PCEventTypeMediaAudioModeChanged;
OBJC_EXPORT PCEventType const PCEventTypeMediaAudioChanged;
OBJC_EXPORT PCEventType const PCEventTypeMediaHeartbeat;
OBJC_EXPORT PCEventType const PCEventTypeMediaPlaylistAdd;
OBJC_EXPORT PCEventType const PCEventTypeMediaPlaylistRemove;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationLoaded;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationHit;
OBJC_EXPORT PCEventType const PCEventTypeRecommendationDisplayed;
OBJC_EXPORT PCEventType const PCEventTypeCollectionLoaded;
OBJC_EXPORT PCEventType const PCEventTypeCollectionHit;
OBJC_EXPORT PCEventType const PCEventTypeCollectionDisplayed;
OBJC_EXPORT PCEventType const PCEventTypeCollectionItemDisplayed;
OBJC_EXPORT PCEventType const PCEventTypeArticleStart;
OBJC_EXPORT PCEventType const PCEventTypeArticleEnd;
OBJC_EXPORT PCEventType const PCEventTypeReadMore;
OBJC_EXPORT PCEventType const PCEventTypePageView;

typedef NS_ENUM(NSInteger, PCEventStatus) {
    PCEventStatusQueued = 0,
    PCEventStatusSentToPublisher = 1,
    PCEventStatusPublished = 2
};

typedef NSDictionary<NSString *, id<NSCopying>> PeachCollectorMetadata;

OBJC_EXPORT NSString * const PeachCollectorSessionStartTimestampKey;
OBJC_EXPORT NSString * const PeachCollectorLastRecordedEventTimestampKey;

#pragma mark - Payload known keys

OBJC_EXPORT NSString * const PCMediaPlaylistIDKey;
OBJC_EXPORT NSString * const PCMediaInsertPositionKey;
OBJC_EXPORT NSString * const PCMediaTimeSpentKey;
OBJC_EXPORT NSString * const PCMediaPlaybackPositionKey;
OBJC_EXPORT NSString * const PCMediaPreviousPlaybackPositionKey;
OBJC_EXPORT NSString * const PCMediaIsPlayingKey;
OBJC_EXPORT NSString * const PCMediaVideoModeKey;
OBJC_EXPORT NSString * const PCMediaAudioModeKey;
OBJC_EXPORT NSString * const PCMediaStartModeKey;
OBJC_EXPORT NSString * const PCMediaPreviousIDKey;
OBJC_EXPORT NSString * const PCMediaPlaybackRateKey;
OBJC_EXPORT NSString * const PCMediaVolumeKey;
OBJC_EXPORT NSString * const PCContextIDKey;
OBJC_EXPORT NSString * const PCContextTypeKey;
OBJC_EXPORT NSString * const PCContextItemsKey;
OBJC_EXPORT NSString * const PCContextItemIDKey;
OBJC_EXPORT NSString * const PCContextHitIndexKey;
OBJC_EXPORT NSString * const PCContextItemIndexKey;
OBJC_EXPORT NSString * const PCContextItemsCountKey;
OBJC_EXPORT NSString * const PCContextPageURIKey;
OBJC_EXPORT NSString * const PCContextSourceKey;
OBJC_EXPORT NSString * const PCContextReferrerKey;
OBJC_EXPORT NSString * const PCContextComponentKey;
OBJC_EXPORT NSString * const PCContextComponentTypeKey;
OBJC_EXPORT NSString * const PCContextComponentNameKey;
OBJC_EXPORT NSString * const PCContextComponentVersionKey;
OBJC_EXPORT NSString * const PCContextExperimentIDKey;
OBJC_EXPORT NSString * const PCContextExperimentComponentKey;

OBJC_EXPORT NSString * const PCPeachSchemaVersionKey;
OBJC_EXPORT NSString * const PCPeachFrameworkVersionKey;
OBJC_EXPORT NSString * const PCPeachImplementationVersionKey;
OBJC_EXPORT NSString * const PCSentTimestampKey;
OBJC_EXPORT NSString * const PCSessionStartTimestampKey;
OBJC_EXPORT NSString * const PCUserIDKey;

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
OBJC_EXPORT NSString * const PCClientIsLoggedInKey;
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

#pragma mark - Publisher related constants

typedef NS_ENUM(NSInteger, PCPublisherGotBackOnlinePolicy) {
    PCPublisherGotBackOnlinePolicySendAll,
    PCPublisherGotBackOnlinePolicySendBatchesRandomly
};

OBJC_EXPORT NSInteger const PeachCollectorDefaultInactiveSessionInterval;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherInterval;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherMaxEventsPerBatch;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherMaxEventsPerBatchAfterOfflineSession;
OBJC_EXPORT PCPublisherGotBackOnlinePolicy const PeachCollectorDefaultPublisherPolicy;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherHeartbeatInterval;

OBJC_EXPORT NSString * const PeachCollectorDefaultDeviceID;

OBJC_EXPORT NSInteger const PeachCollectorDefaultMaxStoredEvents;
OBJC_EXPORT NSInteger const PeachCollectorDefaultMaxStorageDays;

NS_ASSUME_NONNULL_END
