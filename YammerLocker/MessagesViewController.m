//
//  MessagesViewController.m
//  YammerLocker
//
//  Class that manages the table views for showing the navigation options and messages
//
//  Created by Sidd Singh on 6/13/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "MessagesViewController.h"
#import "DataController.h"
#import "Message.h"
#import "Category.h"
#import "MessageDetailViewController.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

// Do a set of actions like getting messages from the Yammer API after the view has loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a data controller that you will use later
    self.yamMsgDataController = [DataController sharedController];
    
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
    
    NSInteger noOfSections = 1;
    
    // If its the navigation table, 2 sections
    if(tableView == self.messagesNavTable) {
        noOfSections = 2;
    }

    return noOfSections;
}

// Set the headers for the table views to special table cells that serve as headers.
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UITableViewCell *headerView = nil;
    
    // If its the navigation table
    if(tableView == self.messagesNavTable) {
        
       headerView = [tableView dequeueReusableCellWithIdentifier:@"NavTableSectionHeader"];
        
        // If its the messages section of the nav table
        if (section == 0) {
            [[headerView textLabel] setText:@"MESSAGES"];
        }
        
        // If it's the categories section
        else {
            [[headerView textLabel] setText:@"CATEGORIES"];
        }
    }
    // If its the messages table
    else {
        headerView = [tableView dequeueReusableCellWithIdentifier:@"MessagesTableSectionHeader"];
        [[headerView textLabel] setText:self.currentNavItemTitle];
    }
    
    return headerView;
}

// Specify the number of rows in the table views
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If its the navigation table
    if(tableView == self.messagesNavTable) {
        // If its the messages section of the nav table, there's only 1 row for now: All
        if (section == 0) {
            return 1;
        }
        // Else no of categories
        else {
            self.categoriesController = [self.yamMsgDataController getAllCategories];
            id navSection = [[self.categoriesController sections] objectAtIndex:(section-1)];
            return [navSection numberOfObjects];
        }
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
        
        
        // If it's the messages section, display the "All" navigation item
        if (indexPath.section == 0) {
            [[cell textLabel] setText:@"All"];
        }
        // If it's the categories section, display all the categories
        else {
            Category *categoryAtIndex = [[self.categoriesController fetchedObjects] objectAtIndex:(indexPath.row)];
            // Construct and display the categorye label e.g. Presentations with category icon
            // cell.imageView.image = [UIImage imageNamed:@"YammerBlueColorSliver_folder.png"];
            NSString *categoryLabel = [[NSString alloc] initWithFormat:@"%@",categoryAtIndex.title];
            [[cell textLabel] setText:categoryLabel];
        }
        // Configure the first cell to display the "All" navigation item
  /*      if (indexPath.row == 0) {
            [[cell textLabel] setText:@"All"];
        }
        else {
            Category *categoryAtIndex = [[self.categoriesController fetchedObjects] objectAtIndex:(indexPath.row)-1];
            // Construct and display the categorye label e.g. Presentations with category icon
            // cell.imageView.image = [UIImage imageNamed:@"YammerBlueColorSliver_folder.png"];
            NSString *categoryLabel = [[NSString alloc] initWithFormat:@"%@",categoryAtIndex.title];
            [[cell textLabel] setText:categoryLabel];
        } */
            
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
        [[cell detailTextLabel] setNumberOfLines:2];
        [[cell detailTextLabel] setText:messageAtIndex.content];
        
        // Get the user images from mugshot url and display it asynchronously
        // if the mugshot url indicates there is a photo. If not then set to default user image
        if ([messageAtIndex.fromMugshotUrl isEqualToString:@"https://mug0.assets-yammer.com/mugshot/images/48x48/no_photo.png"]) {
            cell.imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
        } else {
            NSArray * userImageObjects = [NSArray arrayWithObjects:messageAtIndex.fromMugshotUrl, [cell imageView], nil];
            [self.yamMsgDataController performSelectorInBackground:@selector(getImageFromUrl:) withObject:userImageObjects];
        }
    
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
        MessageDetailViewController *detailViewController = [segue destinationViewController];
        
        Message *messageAtIndex;
        messageAtIndex = [self.messagesController objectAtIndexPath:[self.messagesTable indexPathForSelectedRow]];
        
        detailViewController.message = messageAtIndex;
    }
}

// Refresh by getting new messages from the service API
- (IBAction)refreshMessages:(id)sender
{
    [self.yamMsgDataController performSelectorInBackground:@selector(getNewMessagesFromApi) withObject:nil];
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

// Set the section headers on the table views
/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 NSString *headerText = nil;
 
 // If its the navigation table
 if(tableView == self.messagesNavTable) {
 // If its the messages section of the nav table
 if (section == 0) {
 headerText = @"Messages";
 //  self.sectionHeaderLabel.text = @"Messages";
 }
 // If it's the categories section
 else {
 headerText = @"Categories";
 //  self.sectionHeaderLabel2.text = @"Categories";
 }
 }
 
 return headerText;
 } */


@end
