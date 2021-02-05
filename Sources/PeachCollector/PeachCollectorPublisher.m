//
//  PeachCollectorPublisher.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorPublisher.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "PeachCollectorDataFormat.h"
#import "PeachCollector.h"

@interface PeachCollectorPublisher ()

@property (nonatomic, copy) NSDictionary *clientInfo;

@end

@implementation PeachCollectorPublisher


- (id)initWithServiceURL:(NSString *)serviceURL
{
    self = [super init];
    if (self) {
        self.serviceURL = serviceURL;
        self.interval = PeachCollectorDefaultPublisherInterval;
        self.maxEventsPerBatch = PeachCollectorDefaultPublisherMaxEventsPerBatch;
        self.maxEventsPerBatchAfterOfflineSession = PeachCollectorDefaultPublisherMaxEventsPerBatchAfterOfflineSession;
        self.gotBackPolicy = PeachCollectorDefaultPublisherPolicy;
    }
    return self;
}

- (id)initWithSiteKey:(NSString *)siteKey
{
    NSAssert(siteKey != nil && ![siteKey isEqualToString:@""], @"SiteKey is not valid");
    return [self initWithServiceURL:[NSString stringWithFormat:@"https://pipe-collect.ebu.io/v3/collect?s=%@", siteKey]];
}

- (void)processEvents:(NSArray<PeachCollectorEvent *> *)events withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:@"1.0.3" forKey:PCPeachSchemaVersionKey];
    [data setObject:[PeachCollector version] forKey:PCPeachFrameworkVersionKey];
    if ([PeachCollector implementationVersion]) {
        [data setObject:[PeachCollector implementationVersion] forKey:PCPeachImplementationVersionKey];
    }
    [data setObject:@((NSInteger)([[NSDate date] timeIntervalSince1970] * 1000)) forKey:PCSentTimestampKey];
    [data setObject:self.clientInfo forKey:PCClientKey];
    
    NSMutableArray *eventsData = [NSMutableArray new];
    for (PeachCollectorEvent *event in events) {
        NSDictionary *eventDict = [event dictionaryRepresentation];
        if (eventDict) {
            [eventsData addObject:eventDict];
        }
    }
    [data setObject:eventsData forKey:PCEventsKey];
    if (PeachCollector.userID) [data setObject:PeachCollector.userID forKey:PCUserIDKey];
    [data setObject:@(PeachCollector.sessionStartTimestamp) forKey:PCSessionStartTimestampKey];
    
    [self publishData:[data copy] withCompletionHandler:completionHandler];
}


- (NSData *)jsonFromDictionary:(NSDictionary *)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error) {
        return nil;
    }
    return jsonData;
}


- (void)publishData:(NSDictionary *)data withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSData *jsonData = [self jsonFromDictionary:data];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[self serviceURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    if ([[PeachCollector sharedCollector] isUnitTesting]) {
        [NSNotificationCenter.defaultCenter postNotificationName:PeachCollectorNotification object:nil userInfo:@{PeachCollectorNotificationPayloadKey : jsonData}];
    }
    
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
        NSString *clientAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *clientAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *deviceID = PeachCollector.deviceID;
        
        if (PeachCollector.appID) clientBundleIdentifier = PeachCollector.appID;
        if (clientBundleIdentifier == nil) clientBundleIdentifier = @"unknown";
        if (clientAppName == nil) clientAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];;
        if (clientAppName == nil) clientAppName = @"unknown";
        if (clientAppVersion == nil) clientAppVersion = @"unknown";
        if (deviceID == nil) deviceID = PeachCollectorDefaultDeviceID;
        
        self.clientInfo = @{PCClientIDKey : deviceID,
                            PCClientTypeKey : @"mobileapp",
                            PCClientAppIDKey : clientBundleIdentifier,
                            PCClientAppNameKey : clientAppName,
                            PCClientAppVersionKey : clientAppVersion,
                            PCClientIsLoggedInKey: [NSNumber numberWithBool:[PeachCollector userIsLoggedIn]]
        };
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
             PCClientDeviceTimezoneKey:@(currentGMTOffset/3600.f)};
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

- (BOOL)shouldProcessEvent:(PeachCollectorEvent *)event
{
    return YES;
}

@end
