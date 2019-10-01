//
//  PeachCollectorContextComponent.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorContextComponent.h"
#import "PeachCollectorDataFormat.h"

@implementation PeachCollectorContextComponent

- (instancetype)initWithType:(nullable NSString *)type
                        name:(nullable NSString *)name
                     version:(nullable NSString *)version
{
    self = [super init];
    if (self) {
        _type = type;
        _name = name;
        _version = version;
    }
    return self;
}

- (NSDictionary *)dictionaryDescription
{
    NSMutableDictionary *mutableDescription = [NSMutableDictionary new];
    if (self.type) [mutableDescription setObject:self.type forKey:PCContextComponentTypeKey];
    if (self.name) [mutableDescription setObject:self.name forKey:PCContextComponentNameKey];
    if (self.version) [mutableDescription setObject:self.version forKey:PCContextComponentVersionKey];
    if ([mutableDescription count] == 0) {
        return nil;
    }
    return [mutableDescription copy];
}

@end
