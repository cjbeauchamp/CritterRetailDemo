//
//  AppDelegate.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 9/30/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CartItem+CoreDataProperties.h"

#define BASE_URL        @"https://aqueous-springs-2444.herokuapp.com"
//#define BASE_URL        @"http://127.0.0.1:8000"

@class ShopViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) ShopViewController *shopVC;

+ (AppDelegate*) sharedDelegate;
- (void)saveContext;

@end

