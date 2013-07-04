//
//  YammerLockerViewController.h
//  YammerLocker
//
//  Class that manages the authentication screen UI
//
//  Created by Sidd Singh on 11/7/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerLockerDataController;

@interface YammerLockerViewController : UIViewController <UITextFieldDelegate>

// Establish Connection with Yammer
- (IBAction)establishConnection:(id)sender;

// Data Controller for saving user authorization token.
@property (strong,nonatomic) YammerLockerDataController *yamAuthDataController;
@end
