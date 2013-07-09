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

@interface YammerDataConfigController : UIViewController

// Show Yammer Messages when Get Messages button is clicked
- (IBAction)getMessages:(id)sender;

@end
