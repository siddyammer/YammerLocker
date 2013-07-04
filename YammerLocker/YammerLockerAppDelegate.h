//
//  YammerLockerAppDelegate.h
//  YammerLocker
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerLockerDataController;

@interface YammerLockerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Handle the URL scheme registered for this app.
// Currently set to enterpriselocker://...
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

// Data Controller for user authorization status.
@property (strong,nonatomic) YammerLockerDataController *yamUserDataController;

@end
