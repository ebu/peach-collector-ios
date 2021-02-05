

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

# About

The **Peach Collector** framework for iOS provides simple functionalities to facilitate the collect of events. `PeachCollector` helps you by managing a queue of events serialized until they are successfully published.

# Compatibility

The library is suitable for applications running on iOS 12 and above or tvOS 12 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 12).

# Installation

## Install via Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PeachCollector into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ebu/peach-collector-ios"
```

Run `carthage update` to build the framework and drag the built `PeachCollector.framework` into your Xcode project.

## Install via Swift Package Manager

SPM integration is available since version 1.2.0

- In XCode menu, click on `File` > `Swift Packages` > `Add Package Dependency...`
- Enter the project url: `https://github.com/ebu/peach-collector-ios.git` and click on the `Next` button.
- Select the `master` branch and click on the `Next` button.
- Click on the `Finish` button.


# Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first.

## Framework integration
Import the global header file in your `AppDelegate` using:
#### Objective-C
```objectivec
@import PeachCollector;
```
#### Swift
```swift
import PeachCollector
```


## Initializing the collector
`PeachCollector` is automatically initialized at the launch of the app. You just need a `PeachCollectorPublisher` to start sending the queued events.
You can either provide a __SiteKey__ or a full __URL address__ in order to configure the publisher.


#### Objective-C
```objectivec
PeachCollectorPublisher *publisher = [[PeachCollectorPublisher alloc] initWithSiteKey:@"zzebu00000000017"];
[PeachCollector setPublisher:publisher withUniqueName:@"My Publisher"];
```
#### Swift
```swift
let publisher = PeachCollectorPublisher.init(siteKey: "zzebu00000000017")
PeachCollector.setPublisher(publisher, withUniqueName: "My Publisher")
```

## Configuring the collector

- A user ID can be defined using the **`userID`** PeachCollector property.
- If userIDs are generated automatically for anonymous user. You can use the `userIsLoggedIn` flag to define if the user is logged in or not
- For debugging purpose, a **`isUnitTesting`** flag is available. If true, notifications will be sent by the collector (see `PeachColletorNotifications.h`)
- The collector retrieves the *identifierForVendor* to set as the *device ID* in order to track users that do not have user IDs. People can choose to limit tracking on their devices and this ID will not be sent to Peach. In this case, if there is no **`userID`** defined, no events will be recorder or sent. Unless you set the **`shouldCollectAnonymousEvents`** flag to *true*. Default is *false*.
- Optionally, you can define an **`implementationVersion`** by setting a PeachCollector property.
- **`maximumStorageDays`** is the maximum number of days an event should be kept in the queue (if it could not be sent).
- **`maximumStoredEvents`** is the maximum number of events that should be kept in the queue. 
- An **`appID`** can be defined if you don't want to use the default value (which is the bundle ID of the app).

#### Objective-C
```objectivec
PeachCollector.userID = @"123e4567-e89b-12d3-a456-426655440000";
[PeachCollector sharedCollector].isUnitTesting = YES;
[PeachCollector sharedCollector].shouldCollectAnonymousEvents = YES;
PeachCollector.implementationVersion = @"1";
PeachCollector.maximumStorageDays = 5;
PeachCollector.maximumStoredEvents = 1000;
```

#### Swift
```swift
PeachCollector.userID = "123e4567-e89b-12d3-a456-426655440000";
PeachCollector.shared.isUnitTesting = true;
PeachCollector.shared.shouldCollectAnonymousEvents = true;
PeachCollector.implementationVersion = "1";

```

### Configuring a Publisher
A publisher needs to be initialized with a __SiteKey__ or a full __URL address__ as seen previously.
But it has 4 others properties that are worth mentioning :

**`interval`**: The interval in seconds at which events are sent to the server (interval starts after the first event is queued). Default is 20 seconds.

**`maxEventsPerBatch`**: Number of events queued that triggers the publishing process even if the desired interval hasn't been reached. Default is 20 events.

**`maxEventsPerBatchAfterOfflineSession`**: Maximum number of events that can be sent in a single batch. Especially useful after a long offline session. Default is 1000 events.

**`gotBackPolicy`**: How the publisher should behave after an offline period. Available options are `SendAll` (sends requests with **`maxEventsPerBatchAfterOfflineSession`** continuously), `SendBatchesRandomly` (separates requests by a random delay between 0 and 60 seconds).

### Flushing and Cleaning

**`Flush`** is called when the application is about to go to background, or if a special type of event is sent while in background (events that will potentially push the application into an inactive state). It will try to send all the queued events (even if the maximum number of events hasn't been reached)

**`Clean`** will simply remove all current queued events. It is never called in the life cycle of the framework.

`Flush` and `Clean` can be called manually.

#### Objective-C
```objectivec
[PeachCollector flush];
[PeachCollector clean];
```
#### Swift
```swift
PeachCollector.flush();
PeachCollector.clean()
```

## Special type of events
Some events can be queued when the app is in background but still active. For example, when playing an audio media and controlling the playback directly on the device's lock screen. Some of those events that can occur during a playback will trigger a flush of all queued events. This mechanism is implemented to make sure events are published before the app becomes totally inactive.

For now, events that trigger this flush are `media_pause` and `media_stop` events.
You can add another type of event to this list:
#### Objective-C
```objectivec
[PeachCollector addFlushableEventType:@"media_error"]
```
#### Swift
```swift
PeachCollector.addFlushableEventType("media_error")
```

### Recording an Event

#### Objective-C
```objectivec
[PeachCollectorEvent sendRecommendationHitWithID:@"reco01"
					  itemID:@"media01"
                                        hitIndex:1
                                    appSectionID:@"news/videos"
                                          source:nil
                                       component:nil];
```
#### Swift
```swift
PeachCollectorEvent.sendRecommendationHit(withID: "reco00",
					  itemID: "media01",
					     hit: 1,
				    appSectionID: "news/videos",
					  source: nil,
				       component: nil)
```





## Demo projects

To see examples of how the framework works, two demo projects (in Objective-C and Swift) for iOS and one demo for tvOS are available in the Xcode project.
