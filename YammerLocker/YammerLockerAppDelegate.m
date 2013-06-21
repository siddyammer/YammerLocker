//
//  YammerLockerAppDelegate.m
//  YammerLocker
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "YammerLockerAppDelegate.h"
#import "NXOAuth2.h"

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
