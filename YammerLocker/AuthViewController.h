//
//  AuthViewController.h
//  YammerLocker
//
//  Class that manages the authentication screen UI
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataController;
@class LoginController;

@interface AuthViewController : UIViewController <UITextFieldDelegate>

// Establish Connection with Yammer
- (IBAction)establishConnection:(id)sender;

// Login Controller for logging user in with Yammer OAuth.
@property (strong,nonatomic) LoginController *yamLoginController;

@end
