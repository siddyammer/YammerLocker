//
//  YammerMessagesViewController.h
//  YammerLocker
//
//  Class that manages the table views for showing the navigation options and messages
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YammerLockerDataController;
@class NSFetchedResultsController;

@interface YammerMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Data Controller for displaying messages in this view.
@property (strong,nonatomic) YammerLockerDataController *yamMsgDataController;

// Controller containing results of message queries to Core Data store
@property (strong, nonatomic) NSFetchedResultsController *messagesController;

// Controller containing results of category queries to Core Data store
@property (strong, nonatomic) NSFetchedResultsController *categoriesController;

// Outlet for the messages display table
@property (weak, nonatomic) IBOutlet UITableView *messagesTable;

// Outlet for the messages view navigation table
@property (weak, nonatomic) IBOutlet UITableView *messagesNavTable;

// Store the title of the currently selected messages navigation item
@property (strong,nonatomic) NSString *currentNavItemTitle;

@end
