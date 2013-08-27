//
//  DataConfigViewController.m
//  YammerLocker
//
//  Class that shows the default mechanism to get yammer messages into the locker. Eventually
//  will allow for defining custom mechanisms to do this.
//
//  Created by Sidd Singh on 7/8/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "DataConfigViewController.h"
#import "DataController.h"
#import "AppDelegate.h"

@interface DataConfigViewController ()

@end

@implementation DataConfigViewController

// Do additional setup after loading the view. 
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register the user string data obtained listener
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userStringObtained:)
                                                 name:@"UserStringObtained" object:nil];
    
    // Get a data controller that you will use later for getting current user string
    self.currUserDataController = [DataController sharedController];

    // If the current user string doesn't already exist in the core data store
    if ([self.currUserDataController getUserString] == nil) {
        // Asynchronously, get the current user string FROM THE YAMMER API and save it to the core data store
        [self.currUserDataController performSelectorInBackground:@selector(getCurrentUserData) withObject:nil];
    }
    // If it does exist
    else {
        // Show to the user, the custom topic that they can use to add messages to Locker.
        // TO DO: locker is hardcoded. Change that.
        self.messageTopicTxtFld.text = [NSString stringWithFormat:@"%@%@%@",@"#",[self.currUserDataController getUserString],@"locker"];
        
        // Enable the button to show messages
        self.showMessagesButton.userInteractionEnabled = YES;
        
        // Asynchronously, start getting messages for display on the next screen from the Yammer API
        // If the initial data fetch for this user has been done, get new messages
        if ([self.currUserDataController getInitialDataState] == YES) {
            [self.currUserDataController performSelectorInBackground:@selector(getNewMessagesFromApi) withObject:nil];
            // Else get all messages
        } else {
            [self.currUserDataController performSelectorInBackground:@selector(getAllMessagesFromApi) withObject:nil];
        }
    }
    
    // Asynchronously issue an http call to decline the mobile interstitial which asks the user if they had
    // like to install the ipad app
    [self.currUserDataController performSelectorInBackground:@selector(declineMobileInterstitial) withObject:nil];
}

// Show Yammer Messages view when Next button is clicked
- (IBAction)showMessages:(id)sender {
    
    // Update the UI by segueing to show messages.
    [self performSegueWithIdentifier:@"ShowMessages" sender:self];
}

// Show to the user, the custom topic that they can use to add messages to Locker.
// Custom topic is constructed from user string data obtained from the Yammer API.
- (void)userStringObtained:(NSNotification *)notification {
    
    // Construct the topic based on user string data
    // TO DO: locker is hardcoded. Change that.
    self.messageTopicTxtFld.text = [NSString stringWithFormat:@"%@%@%@",@"#",[self.currUserDataController getUserString],@"locker"];
    
    // Enable the button to show messages
    self.showMessagesButton.userInteractionEnabled = YES;
    
    // Asynchronously, start getting messages for display on the next screen from the Yammer API
    // If the initial data fetch for this user has been done, get new messages
    if ([self.currUserDataController getInitialDataState] == YES) {
        [self.currUserDataController performSelectorInBackground:@selector(getNewMessagesFromApi) withObject:nil];
        // Else get all messages
    } else {
        [self.currUserDataController performSelectorInBackground:@selector(getAllMessagesFromApi) withObject:nil];
    }
}

// Signout the user, meaning they have to login again
- (IBAction)signoutUser:(id)sender {
    
    // Clear the existing user Oauth token by setting it to nil
    [self.currUserDataController upsertUserWithAuthToken:nil];
    
    // Clear the user's cookies for the locker app
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    } 
    
    // Update the UI by segueing to show the login page controller.
    [self performSegueWithIdentifier:@"ShowLoginView" sender:self];
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
