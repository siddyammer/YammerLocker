//
//  YammerMessagesViewController.m
//  YammerLocker
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "YammerMessagesViewController.h"
#import "YammerMessageDataController.h"
#import "Message.h"
#import "Category.h"
#import "YammerMessageDetailController.h"

@interface YammerMessagesViewController ()

@end

@implementation YammerMessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Initialize the yamMsgDataController object that you declared. Should this be done in awakeFromNib?
// Register a listener for changes to the message store in core data.
// Register a listener for changes to the category store in core data.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize yamMsgDataController
    self.yamMsgDataController = [[YammerMessageDataController alloc] init];
    
    // Register the messages change listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageStoreChanged:)
                                                 name:@"MessageStoreUpdated" object:nil];
    
    // Register the categories change listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(categoryStoreChanged:)
                                                 name:@"CategoryStoreUpdated" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// Implementing methods needed by the messages and navigation table views, since the table views use this view controller.
/// If you need to implement additional methods look at those available with UITableViewController.

// Get the number of sections in the table views
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Specify the number of rows.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If its the navigation table
    if(tableView == self.messagesNavTable)
        return ([self.yamMsgDataController noOfAllCategories]+1);
    
    // If its the messages table
    else
    return [self.yamMsgDataController noOfAllMessages];
}

// Configure cell to display a Navigation item or a Yammer message depending on the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If its the navigation table
    if(tableView == self.messagesNavTable) {
        static NSString *CellIdentifier = @"YammerMessageNavCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the first cell to display the "All" navigation item
        if (indexPath.row == 0) {
            [[cell textLabel] setText:@"All"];
        }
        else {
            Category *categoryAtIndex = [self.yamMsgDataController getCategoryAtPositionFromAll:(indexPath.row)-1];
            // Construct and display the categorye label e.g. Presentations
            NSString *categoryLabel = [[NSString alloc] initWithFormat:@"%@",categoryAtIndex.title];
            [[cell textLabel] setText:categoryLabel];
        }
            
        return cell;
    }
    
    // If its the messages table
    else {
        static NSString *CellIdentifier = @"YammerMessageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        // Configure cell to display a Yammer Message
        Message *messageAtIndex = [self.yamMsgDataController getMessageAtPositionFromAll:indexPath.row];
        // Construct and display the message information label e.g. Sidd Singh
        NSString *msgLabel = [[NSString alloc] initWithFormat:@"%@",messageAtIndex.from];
        [[cell textLabel] setText:msgLabel];
        // Display the message content
        [[cell detailTextLabel] setText:messageAtIndex.content];
    
        return cell;
    }
}

// Refresh the messages table when the message store for the table has changed
- (void)messageStoreChanged:(NSNotification *)notification {
    
    [self.messagesTable reloadData];
}

// Refresh the navigation table when the category store for the table has changed
- (void)categoryStoreChanged:(NSNotification *)notification {
    
    [self.messagesNavTable reloadData];
}

// Transition to message detail view, when a row (message) in table is clicked.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMessageDetails"]) {
        YammerMessageDetailController *detailViewController = [segue destinationViewController];
        
        detailViewController.message = [self.yamMsgDataController getMessageAtPositionFromAll:[self.messagesTable indexPathForSelectedRow].row];
        
        detailViewController.categoryDataController = self.yamMsgDataController;
    }
}

@end
