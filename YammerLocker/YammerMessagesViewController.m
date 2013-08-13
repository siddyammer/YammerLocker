//
//  YammerMessagesViewController.m
//  YammerLocker
//
//  Class that manages the table views for showing the navigation options and messages
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

// Do a set of actions like getting messages from the Yammer API after the view has loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a data controller that you will use later
    self.yamMsgDataController = [YammerLockerDataController sharedController];
    
    // Asynchronously, start getting messages for display from the Yammer API
    [self.yamMsgDataController performSelectorInBackground:@selector(getMessages) withObject:nil];
    
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

//////////  Implementing methods needed by the messages and navigation table views, since the table views
//////////  use this view controller. If you need to implement additional methods look at those available
//////////  with UITableViewController.

// Get the number of sections in the table views
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Specify the number of rows in the table views
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If its the navigation table
    if(tableView == self.messagesNavTable) {
        //return ([self.yamMsgDataController noOfAllCategories]+1);
        self.categoriesController = [self.yamMsgDataController getAllCategories];
        id navSection = [[self.categoriesController sections] objectAtIndex:section];
        return ([navSection numberOfObjects]+1);
    }
    // If its the messages table
    else {
        // If the messages navigation item is the default "All"
        if ([self.currentNavItemTitle isEqualToString:@"All"]) {
            self.messagesController = [self.yamMsgDataController getAllMessages];
            id messageSection = [[self.messagesController sections] objectAtIndex:section];
            return [messageSection numberOfObjects];
        }
        // If not
        else {
            // return [self.yamMsgDataController noOfMessagesWithCategory:self.currentNavItemTitle];
            self.messagesController = [self.yamMsgDataController getAllMessagesInCategory:self.currentNavItemTitle];
            id messageSection = [[self.messagesController sections] objectAtIndex:section];
            return [messageSection numberOfObjects];
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
            Category *categoryAtIndex = [[self.categoriesController fetchedObjects] objectAtIndex:(indexPath.row)-1];
            // Construct and display the categorye label e.g. Presentations
            cell.imageView.image = [UIImage imageNamed:@"YammerBlueColorSliver_folder.png"];
            NSString *categoryLabel = [[NSString alloc] initWithFormat:@"%@",categoryAtIndex.title];
            [[cell textLabel] setText:categoryLabel];
        }
            
        return cell;
    }
    
    // If its the messages table
    else {
        // Configure cell to display a Yammer Message
        static NSString *CellIdentifier = @"YammerMessageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        Message *messageAtIndex;
        messageAtIndex = [self.messagesController objectAtIndexPath:indexPath];
    
        // Construct and display the message information label e.g. Sidd Singh
        NSString *msgLabel = [[NSString alloc] initWithFormat:@"%@",messageAtIndex.from];
        [[cell textLabel] setText:msgLabel];
        
        // Display the message content
        [[cell detailTextLabel] setText:messageAtIndex.content];
    
        return cell;
    }
}

// When a row is selected on the messages navigation table, update the messages table
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        messageAtIndex = [self.messagesController objectAtIndexPath:[self.messagesTable indexPathForSelectedRow]];
        
        detailViewController.message = messageAtIndex;
    }
}

/////////////////////////////////////  Unused methods, for future use  /////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
