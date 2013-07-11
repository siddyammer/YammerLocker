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
    
     NSLog(@"***** Loaded Data Config controller and about to get current data user");
    // Synchronously, get the current user string from the Yammer API and save it to the core data store
    [self.currUserDataController getCurrentUserData];
    
    
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
@end
