//
//  PeachCollectorContext.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorContext.h"
#import "PeachCollectorDataFormat.h"

@implementation PeachCollectorContext

- (instancetype)initMediaContextWithID:(NSString *)contextID
                             component:(nullable PeachCollectorContextComponent *)component
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source
{
    self = [super init];
    if (self) {
        _contextID = contextID;
        _appSectionID = appSectionID;
        _source = source;
        _component = component;
    }
    return self;
}


- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.contextID) [representation setObject:self.contextID forKey:PCContextIDKey];
    if (self.appSectionID) [representation setObject:self.appSectionID forKey:PCContextPageURIKey];
    if (self.source) [representation setObject:self.source forKey:PCContextSourceKey];
    if (self.component && [self.component dictionaryRepresentation]) [representation setObject:[self.component dictionaryRepresentation] forKey:PCContextComponentKey];
    if ([representation count] == 0) return nil;
    return [representation copy];
}

@end
