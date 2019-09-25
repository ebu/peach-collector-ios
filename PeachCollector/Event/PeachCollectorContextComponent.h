//
//  PeachCollectorContextComponent.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorContextComponent : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;

- (instancetype)initWithType:(nullable NSString *)type
                        name:(nullable NSString *)name
                     version:(nullable NSString *)version;

- (NSDictionary *)dictionaryDescription;

@end

NS_ASSUME_NONNULL_END
