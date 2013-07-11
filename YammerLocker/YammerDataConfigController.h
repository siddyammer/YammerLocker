//
//  YammerDataConfigController.h
//  YammerLocker
//
//  Shows the default mechanism to get yammer messages into the locker. Eventually
//  will allow for defining custom mechanisms to do this.
//
//  Created by Sidd Singh on 7/8/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerLockerDataController;

@interface YammerDataConfigController : UIViewController

// Show Yammer Messages when Get Messages button is clicked
- (IBAction)getMessages:(id)sender;

// Show the custom, to the user, topic that they can use to add messages to Locker
@property (weak, nonatomic) IBOutlet UITextField *messageTopicTxtFld;

// Data Controller for getting current user string.
@property (strong,nonatomic) YammerLockerDataController *currUserDataController;

@end
