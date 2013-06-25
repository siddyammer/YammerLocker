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
#import "YammerMessageDataController.h"

@interface YammerMessageDetailController ()

- (void) createCategoriesUpdateUI:(NSString *)categoriesStr;

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
        [self.categoryDataController insertCategoryWithTitle:self.addCategoriesTxtFld.text Message:self.message];
        
        // Show the recently added category in the existing categories text field
        self.showCategoriesTxtFld.text = self.addCategoriesTxtFld.text;
    }
    
    return YES;
}

// On Clicking the Add Categories button, The categories entered should be added to the data
// store and associated with the message.
- (IBAction)addCategories:(id)sender {
    
    // Dismiss keyboard from the category entry text field
    [self.addCategoriesTxtFld resignFirstResponder];
    
    // Add category to the data store and associate with message
    [self.categoryDataController insertCategoryWithTitle:self.addCategoriesTxtFld.text Message:self.message];
    
    // Show the recently added category in the existing categories text field
    self.showCategoriesTxtFld.text = self.addCategoriesTxtFld.text;
}

// Create the new categories from the categories comma separated string entered
// by the user. Associate the message with the categories and update the UI.
- (void) createCategoriesUpdateUI:(NSString *)categoriesStr {
    
  //  [self.existingCategoriesLbl setText:categoriesStr];
    
}

@end
