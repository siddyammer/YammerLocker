//
//  AuthViewController.m
//  YammerLocker
//
//  Class that manages the authentication screen UI
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "AuthViewController.h"
#import "DataController.h"
#import "LoginController.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

// Do any additional setup after loading the view. 
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a login Controller that you will use later for logging user in with Yammer OAuth
    self.yamLoginController = [LoginController sharedController];
}

// Establish connection with Yammer using Oauth.
- (IBAction)establishConnection:(id)sender
{
    // Initiate the Oauth handshake in a web view    
    [self.yamLoginController startWebViewLoginFromParentView: self.view];
}

/////////////////////////////////////  Unused methods, for future use  /////////////////////////////////////

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
