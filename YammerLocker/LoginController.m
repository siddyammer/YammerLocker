//
//  YammerLoginController.m
//  YammerLocker
//
//  Class that manages the authentication services
//
//  Created by Sidd Singh on 7/16/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()

// Get each query string param from a URL populated into a dictionary for easier access
- (NSMutableDictionary *)getQueryParmsFromUrl:(NSURL *)url;

// Utility method to convert from a URL format to a string format
- (NSString *)stringByDecodingURLFormat:(NSString *)urlPart;

// Parse out and return the auth token from the current user data.
- (NSString *)parseAddUserString:(NSData *)response;

@end

@implementation LoginController

static LoginController *sharedInstance;

// Implement as a Singleton.
+ (void)initialize
{
    static BOOL exists = NO;
    
    // If a login controller doesn't already exist
    if(!exists)
    {
        exists = YES;
        sharedInstance= [[LoginController alloc] init];
    }
}

// Create and/or Return the single shared Login controller
+ (LoginController *)sharedController {
    
    return sharedInstance;
}

// Set the current login service along with it's autorization parameters.
// Always call this before calling the login specific methods.
- (void)setLoginServiceWithName:(NSString *)name initURL:(NSString *)initURL redirectURL:(NSString *)redirectURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret tokenURL:(NSString *)tokenURL {
    
    self.loginServiceName = name;
    self.oAuthInitURL = initURL;
    self.redirectURL = redirectURL;
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    self.oAuthTokenURL = tokenURL;
}

// Initiate the OAuth login in a web view
- (void)startWebViewLoginFromParentView:(UIView *)parentView {
    
    // Construct the OAuth initiation call URL
    NSMutableString *oAuthCallURL = [NSMutableString stringWithFormat:@""];
    [oAuthCallURL appendFormat:@"%@?client_id=%@&redirect_uri=%@", self.oAuthInitURL, self.clientId, self.redirectURL];
    
    // Open a web view or similar to start the Oauth handshake
    UIWebView *webView = [[UIWebView alloc] initWithFrame:parentView.bounds];
    [webView setScalesPageToFit:TRUE];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: oAuthCallURL]]];
    [parentView addSubview:webView];
}

// Finish the login by getting an OAuth token from the token URL
- (NSString *)getAuthTokenUsingCodeFrom:(NSURL *)redirectURLWithCode {
    
    NSString *authToken = nil;
    
    // Make sure redirect URL with code has correct prefix
    if ([redirectURLWithCode.absoluteString hasPrefix:self.redirectURL])
    {
        NSMutableDictionary *queryParamsDictionary = [self getQueryParmsFromUrl: redirectURLWithCode];
        
        // TO DO: Hardcoded, change to a constants file
        NSString *code = [queryParamsDictionary objectForKey:@"code"];
        NSString *error = [queryParamsDictionary objectForKey:@"error"];
        NSString *error_reason = [queryParamsDictionary objectForKey:@"error_reason"];
        NSString *error_description = [queryParamsDictionary objectForKey:@"error_description"];
        
        if (error) {
            NSString *errorString = error;
            if ( error_reason ) {
                errorString = [errorString stringByAppendingString:[NSString stringWithFormat:@", %@", error_reason]];
            }
            if ( error_description ) {
                errorString = [errorString stringByAppendingString:[NSString stringWithFormat:@", %@", error_description]];
            }
            
            // Error Handling
            NSLog(@"ERROR: Error getting code after Oauth dialog redirects back: %@", errorString);
        }
        
        else if (code) {
            authToken = [self getAuthTokenFromServer:code];
        }
    }
    
    return authToken;
}

// Get each query string param from a URL populated into a dictionary for easier access
- (NSMutableDictionary *)getQueryParmsFromUrl:(NSURL *)url {
    
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    NSArray *params = [url.query componentsSeparatedByString:@"&"];
    
    if (params) {
        
        for (NSString *param in params) {
            
            NSArray *paramParts = [param componentsSeparatedByString:@"="];
            
            if (paramParts && paramParts.count == 2) {
                
                NSString *paramName = [self stringByDecodingURLFormat: [paramParts objectAtIndex:0]];
                NSString *paramValue = [self stringByDecodingURLFormat: [paramParts objectAtIndex:1]];
                [queryDict setValue:paramValue forKey:paramName];
            }
        }
    }
    return queryDict;
}

// Utility method to convert from a URL format to a string format
- (NSString *)stringByDecodingURLFormat:(NSString *)urlPart
{
    NSString *result = [urlPart stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

// Get each query string param from a URL populated into a dictionary for easier access
- (NSString *)getAuthTokenFromServer:(NSString *)code {
    
    // Construct the auth token call URL
    NSMutableString *oAuthTokenURL = [NSMutableString stringWithFormat:@""];
    [oAuthTokenURL appendFormat:@"%@?client_id=%@&client_secret=%@&code=%@", self.oAuthTokenURL, self.clientId, self.clientSecret, code];
    
    // Make the call synchronously
    NSError * error = nil;
    NSURLResponse *oAuthTokenResponse = nil;
    
    NSURLRequest *oAuthTokenRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:oAuthTokenURL]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:oAuthTokenRequest returningResponse:&oAuthTokenResponse
                                                             error:&error];
    
    // Process the response
    if (error == nil)
    {
        // Process the response
        return [self parseAddUserString:responseData];
    } else {
        return nil;
    }
}

// Parse out and return the auth token from the current user data.
- (NSString *)parseAddUserString:(NSData *)response {
    
    NSError *error;
    
    // The auth token string is under the access_token object which is at the highest level of the API response
    // {
    //  access_token: {
    //       "token":"abc",
    //   ......
    
    // Get the response into a parsed object
    NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                   options:kNilOptions
                                                                     error:&error];
    NSDictionary *access_token = [parsedResponse objectForKey:@"access_token"];
    
    // Return the Auth token
    return [access_token objectForKey:@"token"];
}

@end
