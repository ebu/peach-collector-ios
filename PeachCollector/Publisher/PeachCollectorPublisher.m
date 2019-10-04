//
//  PeachCollectorPublisher.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorPublisher.h"
@import AdSupport;
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "PeachCollectorDataFormat.h"
#import "PeachCollector.h"

#import "NSDictionary+Peach.h"

@interface PeachCollectorPublisher ()

@property (nonatomic, copy) NSDictionary *clientInfo;

@end

@implementation PeachCollectorPublisher

- (id)initWithServiceURL:(NSString *)serviceURL
                interval:(NSInteger)interval
               maxEvents:(NSInteger)maxEvents
     gotBackOnlinePolicy:(PCPublisherGotBackOnlinePolicy)gotBackPolicy
{
    self = [super init];
    if (self) {
        self.serviceURL = serviceURL;
        self.interval = interval;
        self.maxEvents = maxEvents;
        self.gotBackPolicy = gotBackPolicy;
    }
    return self;
}


- (void)sendEvents:(NSArray<PeachCollectorPublisherEventStatus *> *)eventsStatuses withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSMutableArray *events = [NSMutableArray new];
    for (PeachCollectorPublisherEventStatus *status in eventsStatuses) {
        [events addObject:status.event];
    }
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:@"1.0.3" forKey:PCPeachSchemaVersionKey];
    [data setObject:@"A.B.3" forKey:PCPeachImplementationVersionKey];
    [data setObject:@((int)[[NSDate date] timeIntervalSince1970]) forKey:PCSentTimestampKey];
    
    [data setObject:self.clientInfo forKey:PCClientKey];
    
    NSMutableArray *eventsData = [NSMutableArray new];
    for (PeachCollectorEvent *event in events) {
        NSMutableDictionary *eventDescription = [NSMutableDictionary new];
        [eventDescription setObject:event.type forKey:PCEventTypeKey];
        [eventDescription setObject:event.eventID forKey:PCEventIDKey];
        [eventDescription setObject:@((int)[event.creationDate timeIntervalSince1970]) forKey:PCEventTimestampKey];
        
        if (event.context) [eventDescription setObject:event.context forKey:PCEventContextKey];
        if (event.props) [eventDescription setObject:event.props forKey:PCEventPropertiesKey];
        if (event.metadata) [eventDescription setObject:event.metadata forKey:PCEventMetadataKey];
        
        [eventsData addObject:eventDescription];
    }
    
    [data setObject:eventsData forKey:PCEventsKey];
    
    for (PeachCollectorPublisherEventStatus *eventStatus in eventsStatuses) {
        eventStatus.status = PCEventStatusSentToEndPoint;
    }
    
    NSError *contextError = nil;
    if ([[PeachCollector managedObjectContext] save:&contextError] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [contextError localizedDescription], [contextError userInfo]);
    }
    NSString *publisherName = [[eventsStatuses objectAtIndex:0] publisherName];
    [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification
                                                      object:nil
                                                    userInfo:@{ PeachCollectorNotificationLogKey : [NSString stringWithFormat:@"%@ : Processed %d events", publisherName, (int)eventsData.count] }];
    
    [self publishData:[data copy] withCompletionHandler:completionHandler];
}


- (void)publishData:(NSDictionary*)data withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSString *jsonData = [data jsonStringFormatted:NO];
    NSData *requestData = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[self serviceURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    // Create the NSURLSessionDataTask post task object.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionHandler(error);
    }];
    
    // Execute the task
    [task resume];
}


- (NSDictionary *)clientInfo
{
    if (_clientInfo == nil) {
        [self updateClientInfo];
    }
    return _clientInfo;
}

- (void)updateClientInfo
{
    if (_clientInfo == nil) {
        NSString *clientBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *clientAppName = @"PeachTest"; //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *clientAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        ASIdentifierManager *asi = [ASIdentifierManager sharedManager];
        
        self.clientInfo = @{PCClientIDKey : [[asi advertisingIdentifier] UUIDString],
                            PCClientTypeKey : @"mobileapp",
                            PCClientAppIDKey : clientBundleIdentifier,
                            PCClientAppNameKey : clientAppName,
                            PCClientAppVersionKey : clientAppVersion};
    }
    
    NSMutableDictionary *mutableClientInfo = [self.clientInfo mutableCopy];
    [mutableClientInfo addEntriesFromDictionary:@{PCClientDeviceKey : [self deviceInfo],
                                                  PCClientOSKey : [self osInfo]}];
    
    self.clientInfo = [mutableClientInfo copy];
}

- (NSDictionary *)deviceInfo
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *clientDeviceType = ([[device model] containsString:@"iPad"]) ? PCClientDeviceTypeTablet : PCClientDeviceTypePhone;
    NSString *clientDeviceVendor = @"Apple";
    NSString *clientDeviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]; //device.model
    
    UIUserInterfaceIdiom idiom = device.userInterfaceIdiom;
    if (idiom == UIUserInterfaceIdiomPad) {
        clientDeviceType = PCClientDeviceTypeTablet;
    }
    else if (idiom == UIUserInterfaceIdiomTV) {
        clientDeviceType = PCClientDeviceTypeTVBox;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int screenWidth = (int)screenSize.width;
    int screenHeight = (int)screenSize.height;
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:[NSDate date]];
    
    NSString* languageCode = [NSLocale currentLocale].localeIdentifier;
    languageCode = [languageCode stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    
    return @{PCClientDeviceTypeKey:clientDeviceType,
             PCClientDeviceVendorKey:clientDeviceVendor,
             PCClientDeviceModelKey:clientDeviceModel,
             PCClientDeviceScreenSizeKey:[NSString stringWithFormat:@"%dx%d", screenWidth, screenHeight],
             PCClientDeviceLanguageKey:languageCode,
             PCClientDeviceTimezoneKey:@(currentGMTOffset/60)};
}

//TODO: add setter for language
// language should be defined by the developer during the lifecycle of the application
// as it could be changed (in app) by the user during navigation

- (NSDictionary *)osInfo
{
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *clientOSName = device.systemName;
    NSString *clientOSVersion = device.systemVersion;
    
    return @{PCClientOSNameKey:clientOSName, PCClientOSVersionKey:clientOSVersion};
}

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    
    NSMutableDictionary *mutableClientInfo = [self.clientInfo mutableCopy];
    [mutableClientInfo setObject:userID forKey:PCClientUserIDKey];
    
    self.clientInfo = [mutableClientInfo copy];
}


- (BOOL)shouldProcessEvent:(PeachCollectorEvent *)event
{
    return YES;
}

@end
