//
//  NSDictionary.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "NSDictionary+Peach.h"

@implementation NSDictionary (Peach)

- (NSString *)jsonStringFormatted:(BOOL)formatted {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)(formatted ? NSJSONWritingPrettyPrinted : 0) error:&error];
    
    if (! jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
