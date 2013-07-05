//
//  YammerMessagesViewController.m
//  YammerLocker
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "YammerMessagesViewController.h"
#import "YammerLockerDataController.h"
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

// Get a data controller that you will use later. Should this be done in awakeFromNib?
// Start getting messages for display from the Yammer API.
// Register a listener for changes to the message store in core data.
// Register a listener for changes to the category store in core data.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a data controller that you will use later
    self.yamMsgDataController = [YammerLockerDataController sharedDataController];
    
    // Start getting messages for display from the Yammer API
    [self.yamMsgDataController getMessages];
    
    // Set the title of the currently selected messages navigation item to be the default which
    // is currently "All"
    self.currentNavItemTitle = [NSString stringWithFormat:@"All"];
    
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
    else {
        // If the messages navigation item is the default "All"
        if ([self.currentNavItemTitle isEqualToString:@"All"]) {
            return [self.yamMsgDataController noOfAllMessages];
        }
        // If not
        else {
            return [self.yamMsgDataController noOfMessagesWithCategory:self.currentNavItemTitle];
        }
    }
    
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
        Message *messageAtIndex;
        // If the messages navigation item is the default "All"
        if ([self.currentNavItemTitle isEqualToString:@"All"]) {
            messageAtIndex = [self.yamMsgDataController getMessageAtPositionFromAll:indexPath.row];
        }
        // If not
        else {
            messageAtIndex = [self.yamMsgDataController getMessageAtPosition:indexPath.row category:self.currentNavItemTitle];
        }
        
        // Construct and display the message information label e.g. Sidd Singh
        NSString *msgLabel = [[NSString alloc] initWithFormat:@"%@",messageAtIndex.from];
        [[cell textLabel] setText:msgLabel];
        
        // Display the message content
        [[cell detailTextLabel] setText:messageAtIndex.content];
    
        return cell;
    }
}

// When a row is selected on the messages navigation table, update the messages table
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // If its the navigation table
    if(tableView == self.messagesNavTable){
        
        // Set the title of the currently selected navigation item
        self.currentNavItemTitle = [self.messagesNavTable cellForRowAtIndexPath:indexPath].textLabel.text;
        
        // Reload the messages table, logic in the reload triggered methods take care of populating the messages
        // with the category selected
        [self.messagesTable reloadData];
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
        
        Message *messageAtIndex;
        // If the messages navigation item is the default "All"
        if ([self.currentNavItemTitle isEqualToString:@"All"]) {
            messageAtIndex = [self.yamMsgDataController getMessageAtPositionFromAll:[self.messagesTable indexPathForSelectedRow].row];
        }
        // If not
        else {
            messageAtIndex = [self.yamMsgDataController getMessageAtPosition:[self.messagesTable indexPathForSelectedRow].row category:self.currentNavItemTitle];
        }
        detailViewController.message = messageAtIndex;
    }
}

@end
