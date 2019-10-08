
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## About

The **Peach Collector** framework for iOS provides simple functionalities to facilitate the collect of events. `PeachCollector` helps you by managing a queue of events serialized until they are successfully published.

## Compatibility

The library is suitable for applications running on iOS 10 and above. The project is meant to be opened with the latest Xcode version (currently Xcode 11).

## Installation

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PeachCollector into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "https://git.ebu.io/peach/peach-collector-ios.git"
```

Run `carthage` to build the framework and drag the built `PeachCollector.framework` into your Xcode project.



## Usage

When you want to use classes or functions provided by the library in your code, you must import it from your source files first.

### Framework integration
Import the global header file in your `AppDelegate` using:
#### Objective-C
```objectivec
@import PeachCollector;
```
#### Swift
```swift
import PeachCollector
```


### Initializing the collector
`PeachCollector` is automatically initialized at the launch of the app. You just need a `PeachCollectorPublisher` to start sending the queued events.
You can either provide a __SiteKey__ or a full __URL address__ in order to configure the publisher.
Optionally, you can define an implementation version by setting a PeachCollector property

#### Objective-C
```objectivec
PeachCollector.implementationVersion = @"1";
PeachCollectorPublisher *publisher = [[PeachCollectorPublisher alloc] initWithSiteKey:@"zzebu00000000017"];
[PeachCollector setPublisher:publisher withUniqueName:@"MyPublisher"];
```
#### Swift
```swift
PeachCollector.implementationVersion = "1";
let publisher = PeachCollectorPublisher.init(siteKey: "zzebu00000000017")
PeachCollector.setPublisher(publisher, withUniqueName: "My Publisher")
```


### Recording an event


#### Objective-C
```objectivec
  [PeachCollectorEvent sendRecommendationHitWithID:@"reco01"
					     items:@[@"reco00", @"reco01", @"reco02"]
                                    itemsDisplayed:3
                                          hitIndex:2
                                      appSectionID:@"news/videos"
                                            source:nil
                                         component:carouselComponent];
```
#### Swift
```swift
PeachCollectorEvent.sendRecommendationHit(withID: "reco00",
					   items: ["reco00", "reco01", "reco02"],
				  itemsDisplayed: 3,
					     hit: 1,
				    appSectionID: "news/videos",
					  source: nil,
				       component: carouselComponent)
```


## Demo projects

To see examples of how the framework works, two demo projects (in Objective-C and Swift) are available in the Xcode project.
