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

- (instancetype)initRecommendationContextWithitems:(NSArray<NSString *> *)items
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component
                               itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                                          hitIndex:(NSInteger)hitIndex
{
    self = [self initRecommendationContextWithitems:items appSectionID:appSectionID source:appSectionID component:component itemsDisplayedCount:itemsDisplayedCount];
    if (self) {
        _hitIndex = @(hitIndex);
    }
    return self;
}

- (instancetype)initRecommendationContextWithitems:(NSArray<NSString *> *)items
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component
                               itemsDisplayedCount:(NSInteger)itemsDisplayedCount
{
    self = [self initRecommendationContextWithitems:items appSectionID:appSectionID source:appSectionID component:component];
    if (self) {
        _itemsDisplayedCount = @(itemsDisplayedCount);
    }
    return self;
}

- (instancetype)initRecommendationContextWithitems:(NSArray<NSString *> *)items
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component
{
    self = [super init];
    if (self) {
        _items = items;
        _appSectionID = appSectionID;
        _source = source;
        _component = component;
    }
    return self;
}

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
    if (self.items) [representation setObject:self.items forKey:PCContextItemsKey];
    if (self.hitIndex != nil) [representation setObject:self.hitIndex forKey:PCContextHitIndexKey];
    if (self.itemsDisplayedCount != nil) [representation setObject:self.itemsDisplayedCount forKey:PCContextItemsDisplayedKey];
    if (self.appSectionID) [representation setObject:self.appSectionID forKey:PCContextPageURIKey];
    if (self.source) [representation setObject:self.source forKey:PCContextSourceKey];
    if (self.component && [self.component dictionaryRepresentation]) [representation setObject:[self.component dictionaryRepresentation] forKey:PCContextComponentKey];
    if ([representation count] == 0) return nil;
    return [representation copy];
}

@end
