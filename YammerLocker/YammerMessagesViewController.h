//
//  YammerMessagesViewController.h
//  YammerLocker
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerMessageDataController;

@interface YammerMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Data Controller for displaying messages in this view.
@property (strong,nonatomic) YammerMessageDataController *yamMsgDataController;

// Outlet for the messages display table
@property (weak, nonatomic) IBOutlet UITableView *messagesTable;

// Outlet for the messages view navigation table
@property (weak, nonatomic) IBOutlet UITableView *messagesNavTable;

// Store the title of the currently selected messages navigation item
@property (strong,nonatomic) NSString *currentNavItemTitle;

@end
