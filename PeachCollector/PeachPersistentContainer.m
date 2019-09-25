//
//  PeachPersistentContainer.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachPersistentContainer.h"

@implementation PeachPersistentContainer

+ (NSURL *)defaultDirectoryURL
{
    return [[super defaultDirectoryURL] URLByAppendingPathComponent:@"PeachCollector"];
}

@end
