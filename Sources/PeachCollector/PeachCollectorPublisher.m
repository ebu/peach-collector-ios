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
@property (nonatomic, copy) NSString *remoteConfigurationURL;
@property (nonatomic, copy) NSDictionary *config;
@property (nonatomic, strong) NSDictionary *clientCustomInfo;

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
        self.playerTrackerHeartbeatInterval = PeachCollectorDefaultPublisherHeartbeatInterval;
    }
    return self;
}

- (id)initWithServiceURL:(NSString *)serviceURL remoteConfiguration:(nonnull NSString *)url
{
    self = [self initWithServiceURL:serviceURL];
    if (self) {
        self.remoteConfigurationURL = url;
        self.config = [[NSUserDefaults standardUserDefaults] dictionaryForKey:url];
        [self checkConfig];
    }
    return self;
}

- (id)initWithSiteKey:(NSString *)siteKey
{
    NSAssert(siteKey != nil && ![siteKey isEqualToString:@""], @"SiteKey is not valid");
    return [self initWithServiceURL:[NSString stringWithFormat:@"https://pipe-collect.ebu.io/v3/collect?s=%@", siteKey]];
}

- (instancetype)initWithSiteKey:(NSString *)siteKey remoteConfiguration:(NSString *)url
{
    NSAssert(siteKey != nil && ![siteKey isEqualToString:@""], @"SiteKey is not valid");
    return [self initWithServiceURL:[NSString stringWithFormat:@"https://pipe-collect.ebu.io/v3/collect?s=%@", siteKey] remoteConfiguration:url];
}

- (void)checkConfig {
    NSString *expiryDateKey = [NSString stringWithFormat:@"%@_date", self.remoteConfigurationURL];
    
    NSDate *expiryDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:expiryDateKey];
    if ([[NSDate date] compare:expiryDate] == NSOrderedDescending) {
        self.config = nil;
    }
    
    if (self.config != nil) {
        NSNumber *intervalNumber = (NSNumber *)[self.config objectForKey:@"flush_interval_sec"];
        NSInteger interval = (intervalNumber != nil) ? [intervalNumber integerValue] : -1;
        self.interval = (interval > -1) ? interval : PeachCollectorDefaultPublisherInterval;
        
        NSNumber *eventBatchSizeNumber = (NSNumber *)[self.config objectForKey:@"max_batch_size"];
        NSInteger eventBatchSize = (eventBatchSizeNumber != nil) ? [eventBatchSizeNumber integerValue] : 0;
        
        self.maxEventsPerBatch = (eventBatchSize > 0) ? eventBatchSize : PeachCollectorDefaultPublisherMaxEventsPerBatch;
        
        NSNumber *eventMaxBatchSizeNumber = (NSNumber *)[self.config objectForKey:@"max_events_per_request"];
        NSInteger eventMaxBatchSize = (eventMaxBatchSizeNumber != nil) ? [eventMaxBatchSizeNumber integerValue] : 0;
        
        self.maxEventsPerBatchAfterOfflineSession = (eventMaxBatchSize > 0) ? eventMaxBatchSize : PeachCollectorDefaultPublisherMaxEventsPerBatchAfterOfflineSession;
        
        NSNumber *heartbeatIntervalNumber = (NSNumber *)[self.config objectForKey:@"heartbeat_frequency_sec"];
        NSInteger heartbeatInterval = (heartbeatIntervalNumber != nil) ? [heartbeatIntervalNumber integerValue] : -1;
        
        self.playerTrackerHeartbeatInterval = (heartbeatInterval > -1) ? heartbeatInterval : PeachCollectorDefaultPublisherHeartbeatInterval;
    }
    else {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:self.remoteConfigurationURL]];
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        self.config = json;
        
        NSNumber *maxCacheNumber = (NSNumber *)[self.config objectForKey:@"max_cache_hours"];
        NSInteger maxCache = (maxCacheNumber != nil) ? [maxCacheNumber integerValue] : 0;
        
        NSDate *expiryDate = [[NSDate date] dateByAddingTimeInterval:(maxCache*60*60)+10];
        [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:expiryDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self checkConfig];
    }
}

- (void)processEvents:(NSArray<PeachCollectorEvent *> *)events withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:@"1.0.4" forKey:PCPeachSchemaVersionKey];
    [data setObject:@"1.5.1-35" forKey:PCPeachFrameworkVersionKey];
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
    if (PeachCollector.sessionID) [data setObject:PeachCollector.sessionID forKey:PCSessionIDKey];
    
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
    if (_clientCustomInfo != nil) {
        NSMutableDictionary* mutableClient = [_clientCustomInfo mutableCopy];
        [mutableClient addEntriesFromDictionary:_clientInfo];
        return [mutableClient copy];
    }
    return _clientInfo;
}

- (void)refreshClientInfo
{
    _clientInfo = nil;
}



+ (NSString *)clientAppVersion
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *buildNumber = [bundle objectForInfoDictionaryKey:(__bridge NSString*)kCFBundleVersionKey];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@-%@", version, buildNumber];
}

- (void)updateClientInfo
{
    if (_clientInfo == nil) {
        NSString *clientBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *clientAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *clientAppVersion = [PeachCollectorPublisher clientAppVersion];
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
    if (self.config != nil && [self.config objectForKey:@"filter"] != nil ) {
        NSArray *events = [self.config objectForKey:@"filter"];
        if ([events containsObject:event.type]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark - Client custom fields management

- (void)addClientObject:(id)object forKey:(nonnull NSString *)key
{
    if (object == nil) {
        [self removeCustomClientField:key];
    }
    else if (self.clientCustomInfo != nil) {
        NSMutableDictionary *mutableCustomFields = [self.clientCustomInfo mutableCopy];
        [mutableCustomFields setObject:object forKey:key];
        self.clientCustomInfo = [mutableCustomFields copy];
    }
    else {
        self.clientCustomInfo = @{key: object};
    }
}

- (void)addCustomClientNumber:(NSNumber *)number forKey:(nonnull NSString *)key
{
    [self addClientObject:number forKey:key];
}

- (void)addCustomClientString:(NSString *)string forKey:(nonnull NSString *)key
{
    [self addClientObject:string forKey:key];
}

- (void)removeCustomClientField:(nonnull NSString *)key
{
    if(self.clientCustomInfo != nil) {
        if ([[self.clientCustomInfo allKeys] containsObject:key]) {
            NSMutableDictionary *mutableCustomFields = [self.clientCustomInfo mutableCopy];
            [mutableCustomFields removeObjectForKey:key];
            self.clientCustomInfo = [mutableCustomFields copy];
        }
        if (self.clientCustomInfo.count == 0) {
            self.clientCustomInfo = nil;
        }
    }
}

- (nullable id)valueForCustomClientField:(nonnull NSString *)key
{
    if (self.clientCustomInfo != nil) {
        return [self.clientCustomInfo valueForKey:key];
    }
    return nil;
}


@end
