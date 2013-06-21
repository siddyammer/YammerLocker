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

// On Clicking the Add Categories button, create and update the categories
- (IBAction)addCategories:(id)sender {
    
    [self.addCategoriesTxtFld resignFirstResponder];
    [self createCategoriesUpdateUI:self.addCategoriesTxtFld.text];
}

// On hitting enter, the new categories text field should dismiss the keyboard
// and also create and update categories
- (BOOL)textFieldShouldReturn:(UITextField *)aTxtFld {
    
    if (aTxtFld == self.addCategoriesTxtFld) {
        [aTxtFld resignFirstResponder];
        [self createCategoriesUpdateUI:self.addCategoriesTxtFld.text];
    }
    return YES;
}

// Create the new categories from the categories comma separated string entered
// by the user. Associate the message with the categories and update the UI.
- (void) createCategoriesUpdateUI:(NSString *)categoriesStr {
    
    [self.existingCategoriesLbl setText:categoriesStr];
    
}

@end
