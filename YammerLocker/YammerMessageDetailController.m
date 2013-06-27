//
//  YammerMessageDetailController.m
//  YammerLocker
//
//  Class shows details of a Yammer message and lets you
//  perform actions on it.
//
//  Created by Sidd Singh on 4/12/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "YammerMessageDetailController.h"
#import "Message.h"
#import "Category.h"
#import "YammerMessageDataController.h"

@interface YammerMessageDetailController ()

// Show the categories associated with the message in the categories text field
- (void) showCategories;

// Send a notification that the list of categories has changed (updated)
- (void)sendCategoriesChangeNotification;

@end

@implementation YammerMessageDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    // Start the web view with the message thread URL
    NSURL *messageURL = [NSURL URLWithString:self.message.webUrl];
    NSURLRequest *messageRequest = [NSURLRequest requestWithURL:messageURL];
    [self.detailWebView loadRequest:messageRequest];
    
    // Display the existing categories associated with the message
    [self showCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Add Categories text field should dismiss the keyboard on hitting return. The
// categories entered should be added to the data store and associated with the message.
// TO DO: Add empty, same text as guidance text and other validation here.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.addCategoriesTxtFld) {
        // Dismiss keyboard
        [self.addCategoriesTxtFld resignFirstResponder];
        
        // Add category to the data store and associate with message
        [self.categoryDataController upsertCategoryWithTitle:self.addCategoriesTxtFld.text Message:self.message];
        
        // Show the recently added category in the existing categories text field
        self.showCategoriesTxtFld.text = [NSString stringWithFormat:@"%@,  %@", self.addCategoriesTxtFld.text, self.showCategoriesTxtFld.text];
        
        // Fire the list of categories changed notification
        [self sendCategoriesChangeNotification];
    }
    
    return YES;
}

// On Clicking the Add Categories button, The categories entered should be added to the data
// store and associated with the message.
- (IBAction)addCategories:(id)sender {
    
    // Dismiss keyboard from the category entry text field
    [self.addCategoriesTxtFld resignFirstResponder];
    
    // Add category to the data store and associate with message
    [self.categoryDataController upsertCategoryWithTitle:self.addCategoriesTxtFld.text Message:self.message];
    
    // Show the recently added category in the existing categories text field
    self.showCategoriesTxtFld.text = [NSString stringWithFormat:@"%@,  %@", self.addCategoriesTxtFld.text, self.showCategoriesTxtFld.text];
    
    // Fire the list of categories changed notification
    [self sendCategoriesChangeNotification];
    

}

// Show the categories associated with the message in the categories text field
- (void) showCategories {
    
    NSMutableString* categoryString = [NSMutableString string];
    
    NSSet* categories = self.message.categories;
    NSInteger categoryIndex = (categories.count - 1);
    
    for(Category* category in categories) {
        // Add a comma after each category except the last one, for display formatting
        if (categoryIndex != 0) {
            [categoryString appendFormat:@"%@,  ", category.title];
        } else {
            [categoryString appendFormat:@"%@", category.title];
        }
        -- categoryIndex;
    }
    
    // Update the categories text field
    self.showCategoriesTxtFld.text = categoryString;
}

// Send a notification that the list of categories has changed (updated)
- (void)sendCategoriesChangeNotification {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CategoryStoreUpdated" object:self];
}

@end
