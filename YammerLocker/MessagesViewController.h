//
//  MessagesViewController.h
//  YammerLocker
//
//  Class that manages the table views for showing the navigation options and messages
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataController;
@class NSFetchedResultsController;

@interface MessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

// Data Controller for displaying messages in this view.
@property (strong,nonatomic) DataController *yamMsgDataController;

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

// Outlet for the messages search bar
@property (weak, nonatomic) IBOutlet UISearchBar *messagesSearchBar;

// Refresh by getting new messages from the service API
- (IBAction)refreshMessages:(id)sender;

@end
