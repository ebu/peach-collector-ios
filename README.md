

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
You need a `PeachCollectorConfiguration` to initialize the `PeachCollector`.
You either have to provide a __SiteKey__ or a full __URL address__ in order to configure the default publisher that will be created alongside the collector.

#### Objective-C
```objectivec
[PeachCollector startWithConfiguration:
[[PeachCollectorConfiguration alloc] initWithSiteKey:@"zzebu00000000017"]];
```
#### Swift
```swift
 PeachCollector.start(with: PeachCollectorConfiguration.init(siteKey: "zzebu00000000017"))
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
