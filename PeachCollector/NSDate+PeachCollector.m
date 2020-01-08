//
//  NSDate.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 08.01.20.
//  Copyright © 2020 European Broadcasting Union. All rights reserved.
//

#import "NSDate+PeachCollector.h"

@implementation NSDate (PeachCollector)

- (NSInteger)gmtMillisecondsTimestamp
{
    return (NSInteger)([self timeIntervalSince1970] * 1000) - ([[NSTimeZone localTimeZone] secondsFromGMTForDate:self] * 1000);
}

@end
