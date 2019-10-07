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

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    if (self.type) [representation setObject:self.type forKey:PCContextComponentTypeKey];
    if (self.name) [representation setObject:self.name forKey:PCContextComponentNameKey];
    if (self.version) [representation setObject:self.version forKey:PCContextComponentVersionKey];
    if ([representation count] == 0) {
        return nil;
    }
    return [representation copy];
}

@end
