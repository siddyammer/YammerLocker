//
//  YammerLockerViewController.m
//  YammerLocker
//
//  Class that manages the authentication screen UI
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "YammerLockerViewController.h"
#import "NXOAuth2.h"

@interface YammerLockerViewController ()

- (void)clearExistingTokens;

@end

@implementation YammerLockerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    
    // Clear the user's existing Oauth tokens since the user will only see the
    // login screen if he doesn't have a valid token.
    [self clearExistingTokens];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Establish connection with Yammer using Oauth.
- (IBAction)establishConnection:(id)sender {
        
    // Register to get notifications of Oauth success. On success segue to show messages.
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      NSInteger tokenCount = 0;
                                                      for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
                                                          ++tokenCount;
                                                          NXOAuth2Client *client =     [account oauthClient];
                                                          NXOAuth2AccessToken *tokenData = [client accessToken];
                                                          NSString * clientAccessToken = [tokenData accessToken];
                                                          NSLog(@"Oauth Success with token number %d and token %@", tokenCount,clientAccessToken);
                                                      }
                                                      
                                                      // Update the UI by segueing to show messages.
                                                      [self performSegueWithIdentifier:@"ShowMessages" sender:self];
                                                      
                                                  }];
    
    // Register to get notifications of Oauth failure
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      NSLog(@"Oauth Failure!");
                                                  }];
    
    // Initiate the Oauth handshake in an external browser
    //[[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"yammerOAuthService"];
    
    // Initiate the Oauth handshake in a web view
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"yammerOAuthService"
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
                                       // Open a web view or similar
                                       NSLog(@"Hit the url handler code with preparedURL of %@",[preparedURL relativeString]);
                                       UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];  //Change self.view.bounds to a smaller CGRect if you don't want it to take up the whole screen
                                       [webView setScalesPageToFit:TRUE];
                                       //webView.scalesPageToFit = YES;
                                       [webView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                       [self.view addSubview:webView];
                                   }];
    
}

// Clear all existing Oauth tokens from Oauth account store.
- (void)clearExistingTokens
{
    NSInteger tokenCountDeleted = 0;
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        ++tokenCountDeleted;
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
        NSLog(@"Deleted token %d",tokenCountDeleted);
    }
}

@end
