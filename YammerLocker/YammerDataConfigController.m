//
//  YammerDataConfigController.m
//  YammerLocker
//
//  Shows the default mechanism to get yammer messages into the locker. Eventually
//  will allow for defining custom mechanisms to do this.
//
//  Created by Sidd Singh on 7/8/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "YammerDataConfigController.h"
#import "YammerLockerDataController.h"
#import "YammerLockerAppDelegate.h"
#import "NXOAuth2.h"

@interface YammerDataConfigController ()

@end

@implementation YammerDataConfigController

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
    
    // Get a data controller that you will use later for getting current user string
    self.currUserDataController = [YammerLockerDataController sharedDataController];

    // Synchronously, get the current user string from the Yammer API and save it to the core data store
    [self.currUserDataController getCurrentUserData];
    
    // Show to the user, the custom topic that they can use to add messages to Locker
    // TO DO: locker is hardcoded. Change that.
    self.messageTopicTxtFld.text = [NSString stringWithFormat:@"%@%@%@",self.messageTopicTxtFld.text,[self.currUserDataController getUserString],@"locker"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Show Yammer Messages when Get Messages button is clicked
- (IBAction)getMessages:(id)sender {
    
    // Update the UI by segueing to show messages.
    [self performSegueWithIdentifier:@"ShowMessages" sender:self];
}

// Signout the user, meaning they have to login again
- (IBAction)signoutUser:(id)sender {
    
    // Clear the existing user object including the Oauth token
    [self.currUserDataController deleteUser];
    
    // The Oauth token in the library data store will be cleared on the
    // load of the login page view. This is due to a weird bug where on deleting the
    // app the library data store does not get cleared.
    NSInteger tokenCountDeleted = 0;
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        ++tokenCountDeleted;
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    }
    NSLog(@"Deleted %d existing tokens",tokenCountDeleted);
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    } 
    
    // Update the UI by segueing to show the login page controller.
    [self performSegueWithIdentifier:@"ShowLoginView" sender:self];
    //YammerLockerAppDelegate *yamLockerAppDelegate = (YammerLockerAppDelegate *)[[UIApplication sharedApplication]delegate];
    //[yamLockerAppDelegate configViewControllerWithName:@"YammerLockerViewController"];

}
@end
