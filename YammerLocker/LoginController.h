//
//  YammerLoginController.h
//  YammerLocker
//
//  Class that manages the authentication services
//
//  Created by Sidd Singh on 7/16/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginController : NSObject

// Return the single shared Login controller
+ (LoginController *)sharedController;

// The name of the service for login
@property (strong,nonatomic) NSString *loginServiceName;

// The Oauth initiation URL of the login service
@property (strong,nonatomic) NSString *oAuthInitURL;

// The Oauth Redirect URL parameter
@property (strong,nonatomic) NSString *redirectURL;

// The client id of the app calling the login service
@property (strong,nonatomic) NSString *clientId;

// The client secret of the app calling the login service
@property (strong,nonatomic) NSString *clientSecret;

// The Oauth token URL of the login service
@property (strong,nonatomic) NSString *oAuthTokenURL;

// Set the current login service along with it's autorization parameters.
// Always call this before calling the login specific methods.
- (void)setLoginServiceWithName:(NSString *)name initURL:(NSString *)initURL redirectURL:(NSString *)redirectURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret tokenURL:(NSString *)tokenURL;

// Initiate the OAuth login in a web view
- (void)startWebViewLoginFromParentView:(UIView *)parentView;

// Finish the login by getting an OAuth token from the token URL,
// using the code appended to the redirect URL
- (NSString *)getAuthTokenUsingCodeFrom:(NSURL *)redirectURLWithCode;

@end
