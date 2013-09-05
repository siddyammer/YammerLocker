//
//  AppDelegate.m
//  YammerLocker
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "AppDelegate.h"
#import "DataController.h"
#import "LoginController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// Do initial setup after the app has been launched by the OS
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Change the user agent for all requests from the app to be locker/1.0. This prevents the get mobile app
    // interstitial (which asks the user if they had like to install the ipad app) from showing, when the user
    // views message details
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"locker/1.0", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    // Get a login Controller for setting up the parameters for the Yammer OAuth login service
    self.yamOauthLoginController = [LoginController sharedController];
    
    // Setup the login service
    [self.yamOauthLoginController setLoginServiceWithName:@"Yammer" initURL:@"https://www.yammer.com/dialog/oauth" redirectURL:@"movetolocker://a.custom.uri" clientId:@"Mfv8iyzg7HGztsZsq9egaA" clientSecret:@"9YWNP0CRUQPUdvmJxavVwFkTp1d78uAj77p7nUYGSI" tokenURL:@"https://www.yammer.com/oauth2/access_token.json"];
    
    // Get a data controller that you will use later to check if user is logged in
    self.yamUserDataController = [DataController sharedController];
    
    // Show the initial view controller which, if the user has not logged in, is AuthViewController
    if ([self.yamUserDataController getUserAccessToken] == nil) {
        [self configViewControllerWithName:@"AuthViewController"];
    }
    
    // If the user is already logged in, the initial view controller is the messages navigation controller
    else {
        [self configViewControllerWithName:@"YammerLockerNavController"];
    }
    
    return YES;
}

// Handle the URL scheme registered for this app. Currently set to locker://...
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // Handle the Redirect URL in the Oauth2 client. Grab the code returned by the
    // server and request for a token.
    NSString *authToken = [self.yamOauthLoginController getAuthTokenUsingCodeFrom:url];
    
    NSLog(@"The OAuth token is:%@",authToken);
    
    // Save the Oauth token to the core data store
    [self.yamUserDataController upsertUserWithAuthToken:authToken];
    
    // Transition to the data config view if the user has logged in successfuly.
    if (authToken == nil) {
        NSLog(@"ERROR: No authentication token received from the Oauth handshake.");
        return NO;
    } else {
        [self configViewControllerWithName:@"YammerLockerNavController"];
        return YES;
    } 
}

// Configure view controller based on name
- (void) configViewControllerWithName:(NSString *)controllerStoryboardId
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:controllerStoryboardId];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

/////////////////////////////////////  Unused methods, for future use  /////////////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
