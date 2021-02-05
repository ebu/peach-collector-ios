//
//  PeachCollectorTests.m
//  PeachCollectorTests
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <XCTest/XCTest.h>
@import PeachCollector;

#define PUBLISHER_NAME @"MyPublisher"

@interface PeachCollectorTests : XCTestCase

@end

@implementation PeachCollectorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [PeachCollector clean];
    [PeachCollector sharedCollector].isUnitTesting = YES;
    [PeachCollector sharedCollector].shouldCollectAnonymousEvents = YES;
    PeachCollectorPublisher *publisher = [[PeachCollectorPublisher alloc] initWithSiteKey:@"zzebu00000000017"];
    publisher.maxEventsPerBatch = 2;
    [PeachCollector setPublisher:publisher withUniqueName:PUBLISHER_NAME];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testFrameworkInitialization {
    XCTAssertNotNil(PeachCollector.sharedCollector, "PeachCollector is not initialized");
    XCTAssertNotEqual(PeachCollector.sessionStartTimestamp, 0, "PeachCollector start timestamp not set");
    XCTAssertNotNil(PeachCollector.dataStore, "PeachCollector CoreData stack is not initialized");
    XCTAssertNotNil(PeachCollector.sharedCollector.flushableEventTypes, "PeachCollector flushable types are not initialized");
    XCTAssertNotNil(PeachCollector.sharedCollector.publishers, "PeachCollector publishers not initialized");
    XCTAssertNotNil(PeachCollector.deviceID, "PeachCollector deviceID not initialized");
    XCTAssertNotNil([PeachCollector publisherNamed:PUBLISHER_NAME], "PeachCollector publisher was not added");
}

- (void)testPublisherConfiguration {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 2;
    publisher.maxEventsPerBatch = 3;
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published events"];
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        if ([logString containsString:@"Published"]){
            [expectation fulfill];
            XCTAssertTrue([logString containsString:@"3 events"], @"Publisher has published the right amount of events");
        }
        return YES;
    }];
    
    for (int i=0; i<3; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil recommendationID:nil];
    }
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testUserLoggedIn {
    //userIsLoggedIn
    [PeachCollector setUserIsLoggedIn:YES];
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            
            NSDictionary* client = [json objectForKey:PCClientKey];
            XCTAssertTrue([[client objectForKey:PCClientIsLoggedInKey] boolValue], @"User Logged in Flag not set properly");
           
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendPageViewWithID:@"testPage" referrer:nil recommendationID:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}


- (void)testAppID {
    //userIsLoggedIn
    [PeachCollector setAppID:@"testAppID"];
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            
            NSDictionary* client = [json objectForKey:PCClientKey];
            XCTAssertNotNil([client objectForKey:PCClientAppIDKey], @"App ID empty");
            XCTAssertTrue([[client objectForKey:PCClientAppIDKey] isEqualToString:@"testAppID"], @"App ID not set properly");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendPageViewWithID:@"testPage" referrer:nil recommendationID:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testWorkingPublisherWith1000Events {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 2;
    
    __block int publishedEventsCount = 0;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published the right amount of events"];
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        if ([logString containsString:@"Published"]){
            NSScanner *scanner = [NSScanner scannerWithString:logString];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            int number;
            [scanner scanInt:&number];
            publishedEventsCount = publishedEventsCount + number;
        }
        if (publishedEventsCount == 1000){
            [expectation fulfill];
        }
        return YES;
    }];
    
    for (int i=0; i<1000; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil recommendationID:nil];
    }
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)testFailingPublisherWith1000Events {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.serviceURL = @"";
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 2;
    
    __block int publishedEventsCount = 0;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published the right amount of events"];

    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];

        if ([logString containsString:@"Published"]){
            NSScanner *scanner = [NSScanner scannerWithString:logString];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            int number;
            [scanner scanInt:&number];
            publishedEventsCount = publishedEventsCount + number;
            
            if (publishedEventsCount == 3000){
                [expectation fulfill];
            }
        }
        
        return YES;
    }];
    
    for (int i=0; i<3000; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil recommendationID:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        publisher.serviceURL = @"https://pipe-collect.ebu.io/v3/collect?s=zzebu00000000017";
        [[NSNotificationCenter defaultCenter] postNotificationName: PeachCollectorReachabilityChangedNotification object:nil];
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)test3PublishersWith1000Events {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 2;
    
    PeachCollectorPublisher *publisher2 = [[PeachCollectorPublisher alloc] initWithSiteKey:@"zzebu00000000017"];
    publisher2.interval = 5;
    publisher2.maxEventsPerBatch = 5;
    [PeachCollector setPublisher:publisher2 withUniqueName:@"PublisherB"];
    
    PeachCollectorPublisher *publisher3 = [[PeachCollectorPublisher alloc] initWithSiteKey:@"zzebu00000000017"];
    publisher3.interval = 50;
    publisher3.maxEventsPerBatch = 1000;
    [PeachCollector setPublisher:publisher3 withUniqueName:@"PublisherC"];
    
    __block int publishedEventsCountPublisher1 = 0;
    __block int publishedEventsCountPublisher2 = 0;
    __block int publishedEventsCountPublisher3 = 0;
    __weak XCTestExpectation *expectation1 = [self expectationWithDescription:@"Publisher has published the right amount of events"];
    __weak XCTestExpectation *expectation2 = [self expectationWithDescription:@"PublisherB has published the right amount of events"];
    __weak XCTestExpectation *expectation3 = [self expectationWithDescription:@"PublisherC has published the right amount of events"];
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        if ([logString containsString:@"Published"]){
            NSScanner *scanner = [NSScanner scannerWithString:logString];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            int number;
            [scanner scanInt:&number];
            
            if ([logString containsString:@"PublisherC"]) {
                publishedEventsCountPublisher3 = publishedEventsCountPublisher3 + number;
                if (publishedEventsCountPublisher3 == 1000){
                    [expectation3 fulfill];
                }
            }
            else if ([logString containsString:@"PublisherB"]) {
                publishedEventsCountPublisher2 = publishedEventsCountPublisher2 + number;
                if (publishedEventsCountPublisher2 == 1000){
                    [expectation2 fulfill];
                }
            }
            else {
                publishedEventsCountPublisher1 = publishedEventsCountPublisher1 + number;
                if (publishedEventsCountPublisher1 == 1000){
                    [expectation1 fulfill];
                }
            }
        }
        
        return YES;
    }];
    
    for (int i=0; i<1000; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil recommendationID:nil];
    }
    
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testRecommendationHitEvent {

    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    PeachCollectorContextComponent *carouselComponent = [PeachCollectorContextComponent new];
    carouselComponent.type = @"Carousel";
    carouselComponent.name = @"recoCarousel";
    carouselComponent.version = @"1.0";
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            
            NSDictionary* context = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventContextKey];
            XCTAssertTrue([[context objectForKey:PCContextItemIDKey] isEqualToString:@"media001"], @"ItemID was added to the context");
            XCTAssertTrue([[context objectForKey:PCContextHitIndexKey] isEqualToNumber:@(2)], @"Hit index was added to the context");
            XCTAssertTrue([[context objectForKey:PCContextPageURIKey] isEqualToString:@"newsSection01"], @"AppSectionID was added to the context");
            XCTAssertTrue([[context objectForKey:PCContextSourceKey] isEqualToString:@"homePage"], @"Source was added to the context");
            
            NSDictionary *component = [context objectForKey:PCContextComponentKey];
            XCTAssertTrue([[component objectForKey:PCContextComponentTypeKey] isEqualToString:carouselComponent.type], @"Component Type is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentNameKey] isEqualToString:carouselComponent.name], @"Component Name is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentVersionKey] isEqualToString:carouselComponent.version], @"Component Version is added to the context");
            
            NSDictionary* client = [json objectForKey:PCClientKey];
            XCTAssertTrue(![[client objectForKey:PCClientIsLoggedInKey] boolValue], @"User Logged in Flag not set properly");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendRecommendationHitWithID:@"reco000000" itemID:@"media001" hitIndex:2 appSectionID:@"newsSection01" source:@"homePage" component:carouselComponent];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRecommendationDisplayedEvent {

    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    PeachCollectorContextComponent *carouselComponent = [PeachCollectorContextComponent new];
    carouselComponent.type = @"Carousel";
    carouselComponent.name = @"recoCarousel";
    carouselComponent.version = @"1.0";
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            
            NSDictionary* context = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventContextKey];
            NSArray *itemsDisplayed = @[@"media001", @"media002"];
            XCTAssertTrue([[context objectForKey:PCContextItemsKey] isEqualToArray:itemsDisplayed], @"Hit index was added to the context");
            XCTAssertTrue([[context objectForKey:PCContextPageURIKey] isEqualToString:@"newsSection01"], @"AppSectionID was added to the context");
            XCTAssertTrue([[context objectForKey:PCContextSourceKey] isEqualToString:@"homePage"], @"Source was added to the context");
            
            NSDictionary *component = [context objectForKey:PCContextComponentKey];
            XCTAssertTrue([[component objectForKey:PCContextComponentTypeKey] isEqualToString:carouselComponent.type], @"Component Type is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentNameKey] isEqualToString:carouselComponent.name], @"Component Name is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentVersionKey] isEqualToString:carouselComponent.version], @"Component Version is added to the context");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendRecommendationDisplayedWithID:@"reco000000" itemsDisplayed:@[@"media001", @"media002"] appSectionID:@"newsSection01" source:@"homePage" component:carouselComponent];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRecommendationLoadedEvent {

    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    PeachCollectorContextComponent *carouselComponent = [PeachCollectorContextComponent new];
    carouselComponent.type = @"Carousel";
    carouselComponent.name = @"recoCarousel";
    carouselComponent.version = @"1.0";
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            NSLog(@"%@",json);
            
            NSDictionary* context = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventContextKey];
            NSArray *items = @[@"media000", @"media001", @"media002"];
            XCTAssertTrue([[context objectForKey:PCContextItemsKey] isEqualToArray:items], @"ItemID was added to the context");
            
            NSDictionary *component = [context objectForKey:PCContextComponentKey];
            XCTAssertTrue([[component objectForKey:PCContextComponentTypeKey] isEqualToString:carouselComponent.type], @"Component Type is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentNameKey] isEqualToString:carouselComponent.name], @"Component Name is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentVersionKey] isEqualToString:carouselComponent.version], @"Component Version is added to the context");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendRecommendationLoadedWithID:@"reco000000" items:@[@"media000", @"media001", @"media002"] appSectionID:nil source:nil component:carouselComponent];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}




- (void)testMediaStartEvent {

    NSDate *now = [NSDate date];
    
    PeachCollectorContextComponent *component = [PeachCollectorContextComponent new];
    component.type = @"player";
    component.name = @"AudioPlayer";
    component.version = @"1.0";
    
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector.dataStore managedObjectContext]];;
    event.type = PCEventTypeMediaPlay;
    event.eventID = @"media00";
    event.creationDate = now;
    
    PeachCollectorProperties *props = [PeachCollectorProperties new];
    props.audioMode = PCMediaAudioModeNormal;
    props.startMode = PCMediaStartModeNormal;
    
    PeachCollectorContext *context = [[PeachCollectorContext alloc] initMediaContextWithID:@"recoA"
                                                                                 component:component
                                                                              appSectionID:@"Demo/AudioPlayer"
                                                                                    source:@"Demo.reco"];
    event.context = [context dictionaryRepresentation];
    event.props = [props dictionaryRepresentation];
    
    
    XCTAssertTrue([[[event context] objectForKey:PCContextIDKey] isEqualToString:@"recoA"], @"Context ID is added to the context");
    XCTAssertTrue([[[event context] objectForKey:PCContextPageURIKey] isEqualToString:@"Demo/AudioPlayer"], @"Context App Section ID is added to the context");
    XCTAssertTrue([[[event context] objectForKey:PCContextSourceKey] isEqualToString:@"Demo.reco"], @"Context Source is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentTypeKey], @"player", @"Component Type is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentNameKey], @"AudioPlayer", @"Component Name is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentVersionKey], @"1.0", @"Component Version is added to the context");
    
    NSDictionary *eventDict = [event dictionaryRepresentation];
    
    XCTAssertEqual([eventDict objectForKey:PCEventTypeKey], PCEventTypeMediaPlay);
    XCTAssertEqual([eventDict objectForKey:PCEventIDKey], @"media00");
    XCTAssertEqual([eventDict objectForKey:PCEventTimestampKey], @((NSInteger)([now timeIntervalSince1970] * 1000)));
    XCTAssertEqual([eventDict objectForKey:PCEventContextKey], event.context);
    
}

- (void)testMediaSeekEventWithCustomFields {

    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    PeachCollectorContextComponent *playerComponent = [PeachCollectorContextComponent new];
    playerComponent.type = @"player";
    playerComponent.name = @"AudioPlayer";
    playerComponent.version = @"1.0";
    
    PeachCollectorProperties *props = [PeachCollectorProperties new];
    props.audioMode = PCMediaAudioModeNormal;
    props.playbackPosition = @(10);
    props.previousPlaybackPosition = @(5);
    props.startMode = PCMediaStartModeNormal;
    props.isPlaying = @NO;
    [props addString:@"top" forKey:@"insert_position"];
    
    PeachCollectorContext *playerContext = [[PeachCollectorContext alloc] initMediaContextWithID:@"recoA"
                                                                                            type:@"recommendation"
                                                                                       component:playerComponent
                                                                                    appSectionID:@"Demo/AudioPlayer"
                                                                                          source:@"Demo.reco"];
    
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            NSLog(@"%@",json);
            
            NSDictionary* properties = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventPropertiesKey];
            XCTAssertTrue([[properties objectForKey:PCMediaPreviousPlaybackPositionKey] isEqualToNumber:@(5)], @"Previous playback position was added to the context");
            XCTAssertTrue([[properties objectForKey:@"insert_position"] isEqualToString:@"top"], @"insertPosition was added to the context");
            XCTAssertTrue([[properties objectForKey:@"is_playing"] isEqualToNumber:@(NO)], @"isPlaying was added to the context");
            
            NSDictionary* context = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventContextKey];
            XCTAssertTrue([[context objectForKey:PCContextTypeKey] isEqualToString:@"recommendation"], @"Context Type is added to the context");
            NSDictionary *component = [context objectForKey:PCContextComponentKey];
            XCTAssertTrue([[component objectForKey:PCContextComponentTypeKey] isEqualToString:playerComponent.type], @"Component Type is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentNameKey] isEqualToString:playerComponent.name], @"Component Name is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentVersionKey] isEqualToString:playerComponent.version], @"Component Version is added to the context");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendMediaSeekWithID:@"media01" properties:props context:playerContext metadata:@{}];
    props.previousPlaybackPosition = nil;
    
    [props removeCustomField:@"insert_position"];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
}


- (void)testMediaSeekEvent {

    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1;
    
    PeachCollectorContextComponent *playerComponent = [PeachCollectorContextComponent new];
    playerComponent.type = @"player";
    playerComponent.name = @"AudioPlayer";
    playerComponent.version = @"1.0";
    
    PeachCollectorProperties *props = [PeachCollectorProperties new];
    props.audioMode = PCMediaAudioModeNormal;
    props.playbackPosition = @(10);
    props.previousPlaybackPosition = @(5);
    props.startMode = PCMediaStartModeNormal;
    
    PeachCollectorContext *playerContext = [[PeachCollectorContext alloc] initMediaContextWithID:@"recoA"
                                                                                       component:playerComponent
                                                                                    appSectionID:@"Demo/AudioPlayer"
                                                                                          source:@"Demo.reco"];
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSData *payload = notification.userInfo[PeachCollectorNotificationPayloadKey];
        
        if (payload != nil) {
            id json = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
            NSLog(@"%@",json);
            
            NSDictionary* properties = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventPropertiesKey];
            XCTAssertTrue([[properties objectForKey:PCMediaPreviousPlaybackPositionKey] isEqualToNumber:@(5)], @"Previous playback position was added to the context");
            
            NSDictionary* context = [[[json objectForKey:PCEventsKey] objectAtIndex:0] objectForKey:PCEventContextKey];
            NSDictionary *component = [context objectForKey:PCContextComponentKey];
            XCTAssertTrue([[component objectForKey:PCContextComponentTypeKey] isEqualToString:playerComponent.type], @"Component Type is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentNameKey] isEqualToString:playerComponent.name], @"Component Name is added to the context");
            XCTAssertTrue([[component objectForKey:PCContextComponentVersionKey] isEqualToString:playerComponent.version], @"Component Version is added to the context");
            
            return YES;
        }
        return NO;
    }];
    
    [PeachCollectorEvent sendMediaSeekWithID:@"media01" properties:props context:playerContext metadata:@{}];
    props.previousPlaybackPosition = nil;
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}


- (void)testMaxEventsStored {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.serviceURL = @"";
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 1000;
    
    __block int publishedEventsCount = 0;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published the right amount of events"];

    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        
        if ([logString containsString:@"Published"]){
            NSScanner *scanner = [NSScanner scannerWithString:logString];
            NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
            int number;
            [scanner scanInt:&number];
            publishedEventsCount = publishedEventsCount + number;
            
            if (publishedEventsCount == 500){
                [expectation fulfill];
            }
        }
        
        return YES;
    }];
    
    for (int i=0; i<1000; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil recommendationID:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PeachCollectorEvent sendPageViewWithID:@"testRetarded/news" referrer:nil recommendationID:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PeachCollector.maximumStorageDays = 5;
        PeachCollector.maximumStoredEvents = 500;
        publisher.serviceURL = @"https://pipe-collect.ebu.io/v3/collect?s=zzebu00000000017";
        [[NSNotificationCenter defaultCenter] postNotificationName: PeachCollectorReachabilityChangedNotification object:nil];
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}




@end
