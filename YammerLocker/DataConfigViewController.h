//
//  DataConfigViewController.h
//  YammerLocker
//
//  Class that shows the default mechanism to get yammer messages into the locker. Eventually
//  will allow for defining custom mechanisms to do this.
//
//  Created by Sidd Singh on 7/8/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataController;

@interface DataConfigViewController : UIViewController

// Show Yammer Messages when button is clicked
- (IBAction)showMessages:(id)sender;

// Button for showing messages
@property (weak, nonatomic) IBOutlet UIButton *showMessagesButton;

// Show to the user, the custom topic that they can use to add messages to Locker
@property (weak, nonatomic) IBOutlet UITextField *messageTopicTxtFld;

// Data Controller for getting current user string.
@property (strong,nonatomic) DataController *currUserDataController;

// Signout the user, meaning they have to login again
- (IBAction)signoutUser:(id)sender;

@end
