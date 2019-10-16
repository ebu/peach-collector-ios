//
//  PeachCollectorOperation.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 15.10.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorOperation : NSObject

@property (nonatomic, copy, nullable) void (^operationBlock)(void);
@property (nonatomic, copy, nullable) void (^completionBlock)(NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END
