//
//  PeachPersistentContainer.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachPersistentContainer.h"

@implementation PeachPersistentContainer

- (instancetype)initWithName:(NSString *)name{
#if SWIFT_PACKAGE
    if (NSClassFromString(@"XCTest") != nil) {
        return [super initWithName:name];
    }
    if (SWIFTPM_MODULE_BUNDLE) {
        NSBundle* bundle = SWIFTPM_MODULE_BUNDLE;
        NSLog(@"bundle2 : %@", bundle.bundlePath);
        NSURL * modelURL = [bundle URLForResource:@"PeachCollector" withExtension:@"mom"];
        NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        return [super initWithName:name managedObjectModel:model];
    }
#endif
    return [super initWithName:name];
}

+ (NSBundle *)getBundle {
#if SWIFT_PACKAGE
  return SWIFTPM_MODULE_BUNDLE;
#else
  return [NSBundle bundleForClass:[PeachPersistentContainer class]];
#endif
}

+ (NSURL *)defaultDirectoryURL
{
    return [[super defaultDirectoryURL] URLByAppendingPathComponent:@"PeachCollector"];
}


@end
