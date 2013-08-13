//
//  YammerLockerAppDelegate.h
//  YammerLocker
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerLockerDataController;
@class LoginController;

@interface YammerLockerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Handle the URL scheme registered for this app.
// Currently set to locker:/...
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

// Login controller for Yammer OAuth service setup.
@property (strong,nonatomic) LoginController *yamOauthLoginController;

// Data Controller for user authorization status.
@property (strong,nonatomic) YammerLockerDataController *yamUserDataController;

// Configure view controller based on name
- (void) configViewControllerWithName:(NSString *)controllerStoryboardId;

@end
