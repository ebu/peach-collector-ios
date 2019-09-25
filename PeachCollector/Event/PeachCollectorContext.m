//
//  PeachCollectorContext.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorContext.h"

@implementation PeachCollectorContext

- (instancetype)initRecommendationContextWithitems:(NSArray<NSString *> *)items
                               itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component
{
    self = [super init];
    if (self) {
        _items = items;
        _itemsDisplayedCount = @(itemsDisplayedCount);
        _appSectionID = appSectionID;
        _source = source;
        _component = component;
    }
    return self;
}

- (instancetype)initMediaContextWithID:(NSString *)contextID
                             component:(PeachCollectorContextComponent *)component
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


- (NSDictionary *)dictionaryDescription
{
    NSMutableDictionary *mutableDescription = [NSMutableDictionary new];
    
    if (self.contextID) [mutableDescription setObject:self.contextID forKey:@"id"];
    if (self.items) [mutableDescription setObject:self.items forKey:@"items"];
    if (self.itemsDisplayedCount) [mutableDescription setObject:self.itemsDisplayedCount forKey:@"items_displayed"];
    if (self.appSectionID) [mutableDescription setObject:self.appSectionID forKey:@"page_uri"];
    if (self.source) [mutableDescription setObject:self.source forKey:@"source"];
    if (self.component) [mutableDescription setObject:[self.component dictionaryDescription] forKey:@"component"];
    if ([mutableDescription count] == 0) return nil;
    return [mutableDescription copy];
}

@end
