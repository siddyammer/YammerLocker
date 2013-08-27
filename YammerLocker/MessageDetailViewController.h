//
//  MessageDetailViewController.h
//  YammerLocker
//
//  Class shows details of a Yammer message and lets
//  you perform actions on it.
//
//  Created by Sidd Singh on 4/12/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message;
@class Category;
@class DataController;

@interface MessageDetailViewController : UIViewController

// Web view that loads the message thread
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;

// Spinner to indicate page is loading
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

// Label to show loading message
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

// Message being loaded
@property (strong, nonatomic) Message *message;

// Data Controller to add/access categories in the data store
@property (strong, nonatomic) DataController *categoryDataController;

// Display for the categories this message belongs to
@property (weak, nonatomic) IBOutlet UILabel *existingCategoriesLbl;

// Specify new categories
@property (weak, nonatomic) IBOutlet UITextField *addCategoriesTxtFld;

// Create new categories
- (IBAction)addCategories:(id)sender;

// Display the existing categories
@property (weak, nonatomic) IBOutlet UITextField *showCategoriesTxtFld;

@end
