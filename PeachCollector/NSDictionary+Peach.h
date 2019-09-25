//
//  NSDictionary.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Peach)

- (NSString *)jsonStringFormatted:(BOOL)formatted;

@end

NS_ASSUME_NONNULL_END
