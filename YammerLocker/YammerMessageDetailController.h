//
//  YammerMessageDetailController.h
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

@interface YammerMessageDetailController : UIViewController

// Web view that loads the message thread
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;

// Message being loaded
@property (strong, nonatomic) Message *message;

// Display for the categories this message belongs to
@property (weak, nonatomic) IBOutlet UILabel *existingCategoriesLbl;

// Specify new categories
@property (weak, nonatomic) IBOutlet UITextField *addCategoriesTxtFld;

// Create new categories
- (IBAction)addCategories:(id)sender;

@end
