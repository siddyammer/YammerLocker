//
//  YammerDataConfigController.m
//  YammerLocker
//
//  CLass that shows the default mechanism to get yammer messages into the locker. Eventually
//  will allow for defining custom mechanisms to do this.
//
//  Created by Sidd Singh on 7/8/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "YammerDataConfigController.h"
#import "YammerLockerDataController.h"
#import "YammerLockerAppDelegate.h"

@interface YammerDataConfigController ()

@end

@implementation YammerDataConfigController

// Do additional setup after loading the view. 
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get a data controller that you will use later for getting current user string
    self.currUserDataController = [YammerLockerDataController sharedController];

    // If the curent user string doesn't already exist in the core data store
    NSLog(@"User string is currently:%@",[self.currUserDataController getUserString]);
    if ([self.currUserDataController getUserString] == nil) {
        // Synchronously, get the current user string FROM THE YAMMER API and save it to the core data store
        [self.currUserDataController getCurrentUserData];
    }
    
    // Asynchronously issue an http call to decline the mobile interstitial which asks the user if they had
    // like to install the ipad app
    [self.currUserDataController performSelectorInBackground:@selector(declineMobileInterstitial) withObject:nil];
    
    // Show to the user, the custom topic that they can use to add messages to Locker
    // TO DO: locker is hardcoded. Change that.
    self.messageTopicTxtFld.text = [NSString stringWithFormat:@"%@%@%@",self.messageTopicTxtFld.text,[self.currUserDataController getUserString],@"locker"];
}

// Show Yammer Messages view when Get Messages button is clicked
- (IBAction)getMessages:(id)sender {
    
    // Update the UI by segueing to show messages.
    [self performSegueWithIdentifier:@"ShowMessages" sender:self];
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
