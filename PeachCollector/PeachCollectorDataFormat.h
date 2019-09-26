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
    PCEventStatusPlublicationFailed = -1,
    PCEventStatusQueued = 0,
    PCEventStatusSentToPublisher = 1,
    PCEventStatusSentToEndPoint = 2,
    PCEventStatusPublished = 3
};

typedef NSDictionary<NSString *, id<NSCopying>> PeachCollectorMetadata;

OBJC_EXPORT NSString * const PeachCollectorNotification;
OBJC_EXPORT NSString * const PeachCollectorNotificationLogKey;
OBJC_EXPORT NSString * const PeachCollectorNotificationQueuedEventsKey;

OBJC_EXPORT NSString * const PeachCollectorDefaultPublisherName;

OBJC_EXPORT NSString * const PeachCollectorPlaybackPositionKey;

/*
 * Publisher related constants
 */

typedef NS_ENUM(NSInteger, PCPublisherGotBackOnlinePolicy) {
    PCPublisherGotBackOnlinePolicySendAll,
    PCPublisherGotBackOnlinePolicySendBatchesRandomly,
    PCPublisherGotBackOnlinePolicySendAllAfterRandomDelay
};

OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherMaxEvents;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherInterval;
OBJC_EXPORT PCPublisherGotBackOnlinePolicy const PeachCollectorDefaultPublisherPolicy;
OBJC_EXPORT NSInteger const PeachCollectorDefaultPublisherHeartbeatInterval;




@interface PeachCollectorDataFormat : NSObject

@end

NS_ASSUME_NONNULL_END
