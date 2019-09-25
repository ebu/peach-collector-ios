//
//  PeachCollectorContext.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorContextComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorContext : NSObject

@property (nonatomic, copy) NSString *contextID;
@property (nonatomic, copy) NSArray<NSString *> *items;
@property (nonatomic, copy) NSNumber *itemsDisplayedCount;
@property (nonatomic, copy) NSString *appSectionID;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) PeachCollectorContextComponent *component;

- (instancetype)initRecommendationContextWithitems:(NSArray<NSString *> *)items
                               itemsDisplayedCount:(NSInteger)itemsDisplayedCount
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component;

- (instancetype)initMediaContextWithID:(NSString *)contextID
                             component:(PeachCollectorContextComponent *)component
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source;

- (NSDictionary *)dictionaryDescription;

@end

NS_ASSUME_NONNULL_END
