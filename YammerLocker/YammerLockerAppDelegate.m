//
//  YammerLockerAppDelegate.m
//  YammerLocker
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "YammerLockerAppDelegate.h"
#import "NXOAuth2.h"
#import "YammerLockerDataController.h"

@interface YammerLockerAppDelegate ()

// Check to see if the user has already logged in and has a token
//- (BOOL)checkForExistingToken;

// Configure view controller based on name
- (void) configViewControllerWithName:(NSString *)controllerStoryboardId;

// Clear all existing Oauth tokens from Oauth account store.
//- (void)clearExistingTokens;

@end

@implementation YammerLockerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[NXOAuth2AccountStore sharedStore] setClientID:@"Mfv8iyzg7HGztsZsq9egaA"
                                             secret:@"9YWNP0CRUQPUdvmJxavVwFkTp1d78uAj77p7nUYGSI"
                                   authorizationURL:[NSURL URLWithString:@"https://www.yammer.com/dialog/oauth"]
                                           tokenURL:[NSURL URLWithString:@"https://www.yammer.com/oauth2/access_token.json"]
                                        redirectURL:[NSURL URLWithString:@"yammer://localhost:3000/auth/yammer/callback"]
                                     forAccountType:@"yammerOAuthService"];
    
    // Get a data controller that you will use later to check if user is logged in
    self.yamUserDataController = [YammerLockerDataController sharedDataController];
    
    // Show the initial view controller which, if the user has not logged in, is YammerLockerViewController
    if (![self.yamUserDataController checkForExistingAuthToken]) {
        [self configViewControllerWithName:@"YammerLockerViewController"];
        NSLog(@"Entered user has not logged in state");
    }
    // If the user is already logged in, the initial view controller is the messages navigation controller
    else {
        [self configViewControllerWithName:@"YammerLockerNavController"];
        NSLog(@"Entered user has logged in state");
    }
    
    return YES;
}

// Handle the URL scheme registered for this app. Currently set to yammer://...
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // Log the URL parts for information purposes
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    
    // Handle the Redirect URL in the Oauth2 client. Basically grab the code returned by the server
    // and request for a token.
    BOOL handled = [[NXOAuth2AccountStore sharedStore] handleRedirectURL:url];
    if (!handled) {
        NSLog(@"The URL (%@) could not be handled. Maybe you want to do something with it.", url);
    }
    
    return handled;
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

// Check to see if the user has already logged in and has a token
/*- (BOOL)checkForExistingToken
{
    if ([[NXOAuth2AccountStore sharedStore] accounts].count > 0) {
        NSInteger tokenCount = 0;
        for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
            ++tokenCount;
            NXOAuth2Client *client =     [account oauthClient];
            NXOAuth2AccessToken *tokenData = [client accessToken];
            NSString * clientAccessToken = [tokenData accessToken];
            NSLog(@"Existing tokens found, number %d and token %@", tokenCount,clientAccessToken);
        } return YES;}
    else
        return NO;
} */


// Clear all existing Oauth tokens from Oauth account store.
/*- (void)clearExistingTokens
{
    NSInteger tokenCountDeleted = 0;
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        ++tokenCountDeleted;
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    }
} */


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
