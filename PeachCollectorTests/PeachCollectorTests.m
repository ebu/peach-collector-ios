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
    [PeachCollector.sharedCollector setUnitTesting:YES];
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
    XCTAssertNotNil(PeachCollector.managedObjectContext, "PeachCollector CoreData stack is not initialized");
    XCTAssertNotNil(PeachCollector.sharedCollector.flushableEventTypes, "PeachCollector flushable types are not initialized");
    XCTAssertNotNil(PeachCollector.sharedCollector.publishers, "PeachCollector publishers not initialized");
    XCTAssertNotNil([PeachCollector publisherNamed:PUBLISHER_NAME], "PeachCollector publisher was not added");
}

- (void)testPublisherConfiguration {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.interval = 2;
    publisher.maxEventsPerBatch = 2;
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published events"];
    
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        //XCTAssertTrue([logString isEqualToString:@"+ Event (page_view)"]);
        if ([logString containsString:@"Published"]){
            [expectation fulfill];
            XCTAssertTrue([logString containsString:@"2 events"], @"Publisher has published the right amount of events");
        }
        return YES;
    }];
    
    for (int i=0; i<5; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil];
    }
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
}


/**
 *  Test failing URL with 1000 events and check that everything is sent when URL is changed
 */
- (void)testFailingPublisherConfiguration {
    
    PeachCollectorPublisher *publisher = [PeachCollector publisherNamed:PUBLISHER_NAME];
    publisher.serviceURL = @"";
    publisher.interval = 1;
    publisher.maxEventsPerBatch = 20;
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Publisher has published events"];
    __weak XCTestExpectation *expectationFailed = [self expectationWithDescription:@"Publisher has failed publishing"];
    [self expectationForNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        //XCTAssertTrue([logString isEqualToString:@"+ Event (page_view)"]);
        if ([logString containsString:@"Failed"]){
            [expectationFailed fulfill];
        }
        if ([logString containsString:@"Published"]){
            [expectation fulfill];
            XCTAssertTrue([logString containsString:@"1000 events"], @"Publisher has published the right amount of events");
        }
        return YES;
    }];
    
    for (int i=0; i<1000; i++) {
        [PeachCollectorEvent sendPageViewWithID:[NSString stringWithFormat:@"test%d/news", i] referrer:nil];
    }
    
    publisher.serviceURL = @"https://pipe-collect.ebu.io/v3/collect?s=zzebu00000000017";
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRecommendationHitEvent {

    NSDate *now = [NSDate date];
    
    PeachCollectorContextComponent *carouselComponent = [PeachCollectorContextComponent new];
    carouselComponent.type = @"Carousel";
    carouselComponent.name = @"recoCarousel";
    carouselComponent.version = @"1.0";
    
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];;
    event.type = PCEventTypeRecommendationHit;
    event.eventID = @"reco00";
    event.creationDate = now;
    NSArray *items = @[@"reco00", @"reco01", @"reco02", @"reco03"];
    PeachCollectorContext *context = [[PeachCollectorContext alloc] initRecommendationContextWithitems:items
                                                                                   itemsDisplayedCount:3
                                                                                          appSectionID:@"news/videos"
                                                                                                source:nil
                                                                                             component:carouselComponent hitIndex:0];
    event.context = [context dictionaryRepresentation];
    
    XCTAssertTrue([[[event context] objectForKey:PCContextItemsKey] isEqual:items], @"Items are added to the context");
    XCTAssertTrue([[[event context] objectForKey:PCContextItemsDisplayedKey] isEqual:@(3)], @"Items display count is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentTypeKey], @"Carousel", @"Component Type is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentNameKey], @"recoCarousel", @"Component Name is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentVersionKey], @"1.0", @"Component Version is added to the context");
    
    NSDictionary *eventDict = [event dictionaryRepresentation];
    
    XCTAssertEqual([eventDict objectForKey:PCEventTypeKey], PCEventTypeRecommendationHit);
    XCTAssertEqual([eventDict objectForKey:PCEventIDKey], @"reco00");
    XCTAssertEqual([eventDict objectForKey:PCEventTimestampKey], @((int)[now timeIntervalSince1970]));
    XCTAssertEqual([eventDict objectForKey:PCEventContextKey], event.context);
    
}

- (void)testMediaStartEvent {

    NSDate *now = [NSDate date];
    
    PeachCollectorContextComponent *component = [PeachCollectorContextComponent new];
    component.type = @"player";
    component.name = @"AudioPlayer";
    component.version = @"1.0";
    
    PeachCollectorEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"PeachCollectorEvent" inManagedObjectContext:[PeachCollector managedObjectContext]];;
    event.type = PCEventTypeRecommendationHit;
    event.eventID = @"media00";
    event.creationDate = now;
    PeachCollectorContext *context = [[PeachCollectorContext alloc] initMediaContextWithID:@"reco00" component:component appSectionID:nil source:nil];
    event.context = [context dictionaryRepresentation];
    
    XCTAssertTrue([[[event context] objectForKey:PCContextItemsDisplayedKey] isEqual:@(3)], @"Items display count is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentTypeKey], @"Carousel", @"Component Type is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentNameKey], @"recoCarousel", @"Component Name is added to the context");
    XCTAssertEqual([[[event context] objectForKey:PCContextComponentKey] objectForKey:PCContextComponentVersionKey], @"1.0", @"Component Version is added to the context");
    
    NSDictionary *eventDict = [event dictionaryRepresentation];
    
    XCTAssertEqual([eventDict objectForKey:PCEventTypeKey], PCEventTypeRecommendationHit);
    XCTAssertEqual([eventDict objectForKey:PCEventIDKey], @"reco00");
    XCTAssertEqual([eventDict objectForKey:PCEventTimestampKey], @((int)[now timeIntervalSince1970]));
    XCTAssertEqual([eventDict objectForKey:PCEventContextKey], event.context);
    
}




- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (XCTestExpectation *)expectationForSingleNotification:(NSNotificationName)notificationName object:(id)objectToObserve handler:(XCNotificationExpectationHandler)handler
{
    /*XCTestExpectation * notifExpectation = [self expectationForSingleNotification:PeachCollectorNotification object:nil handler:^BOOL(NSNotification * _Nonnull notification) {
        NSString *logString = notification.userInfo[PeachCollectorNotificationLogKey];
        XCTAssertTrue([logString isEqualToString:@"+ Event (page_view)"]);
        return YES;
    }];
    */
    
    NSString *description = [NSString stringWithFormat:@"Expectation for notification '%@' from object %@", notificationName, objectToObserve];
    __weak XCTestExpectation *expectation = [self expectationWithDescription:description];
    __block id observer = [NSNotificationCenter.defaultCenter addObserverForName:notificationName object:objectToObserve queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        void (^fulfill)(void) = ^{
            [expectation fulfill];
            [NSNotificationCenter.defaultCenter removeObserver:observer];
            observer = nil;
        };
        
        if (handler) {
            if (handler(notification)) {
                fulfill();
            }
        }
        else {
            fulfill();
        }
    }];
    return expectation;
}




@end
