//
//  AppDelegate.h
//  PeachCollectorDemo
//
//  Created by Rayan Arnaout on 25.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

