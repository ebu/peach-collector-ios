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

- (instancetype)initMediaContextWithID:(NSString *)contextID
                                  type:(NSString *)type
                             component:(nullable PeachCollectorContextComponent *)component
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source
{
    self = [self initMediaContextWithID:contextID component:component appSectionID:appSectionID source:source];
    if (self) {
        _type = type;
    }
    return self;
}


- (id)copyWithZone:(NSZone*)zone
{
    PeachCollectorContext *copyObject = [PeachCollectorContext new];
    copyObject.contextID = [self.contextID copyWithZone:zone];
    copyObject.type = [self.type copyWithZone:zone];
    copyObject.appSectionID = [self.appSectionID copyWithZone:zone];
    copyObject.source = [self.source copyWithZone:zone];
    copyObject.component = [self.component copyWithZone:zone];
    return copyObject;
}

}

- (nullable NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.contextID) [representation setObject:self.contextID forKey:PCContextIDKey];
    if (self.type) [representation setObject:self.type forKey:PCContextTypeKey];
    if (self.appSectionID) [representation setObject:self.appSectionID forKey:PCContextPageURIKey];
    if (self.source) [representation setObject:self.source forKey:PCContextSourceKey];
    if (self.component && [self.component dictionaryRepresentation]) [representation setObject:[self.component dictionaryRepresentation] forKey:PCContextComponentKey];
    if ([representation count] == 0) return nil;
    return [representation copy];
}

@end
