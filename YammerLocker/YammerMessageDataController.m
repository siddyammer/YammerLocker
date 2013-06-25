//
//  YammerMessageDataController.m
//  YammerLocker
// 
//  Class stores and provides access to Yammer Messages and Categories, stored in core data.
//
//  Created by Sidd Singh on 12/11/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "YammerMessageDataController.h"
#import "Message.h"
#import "Category.h"
#import "NXOAuth2.h"

@interface YammerMessageDataController ()

// Get messages for the initial view from the corresponding app service and add to core data store.
- (void)getInitialMessages;

// Get a list of messages that match the topic string from the Yammer search API.
- (void)getMessages;

// Parse the list of messages and format them for display.
- (void)formatAddMessages:(NSData *)response;

// Send a notification that the list of messages has changed (updated)
- (void)sendChangeNotification;

@end

@implementation YammerMessageDataController

// Initialize the message data controller object
- (id)init {
    
    if (self = [super init]) {
        [self getInitialMessages];
        return self;
    }
    
    return nil;
}

// Get messages for the initial view from the corresponding app service and add to core data store.
- (void)getInitialMessages {
    
    // Get and add messages to the store
    [self getMessages];
}

/// Implement core data setup methods that would have already been done for a project
/// with core data enabled.

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store
// coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Locker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Locker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/// Data manipulation methods for Messages

// Get number of all messages in the data store
- (NSUInteger)noOfAllMessages
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    [messageFetchRequest setEntity:messageEntity];
    
    NSError *error;
    NSUInteger count = [dataStoreContext countForFetchRequest:messageFetchRequest error:&error];
    if (count == NSNotFound) {
        NSLog(@"Getting number of all messages in the data store failed: %@",error.description);
    }
    
    return count;
}

// Get a message at a position in the result set from querying all messages
- (Message *)getMessageAtPositionFromAll:(NSUInteger)position
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    [messageFetchRequest setEntity:messageEntity];
    
    NSError *error;
    NSArray *fetchedMessages = [dataStoreContext executeFetchRequest:messageFetchRequest error:&error];
    
    return [fetchedMessages objectAtIndex:position];
}

// Add a message to the data store
- (void)insertMessageWithContent:(NSString *)messageContent from:(NSString *)messageFrom app:(NSString *)messageApp webUrl:(NSString *)messageWebUrl fromMugshotUrl:(NSString *)messageFromMugshotUrl
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:dataStoreContext];
    
    message.content = messageContent;
    message.from = messageFrom;
    message.app = messageApp;
    message.webUrl = messageWebUrl;
    message.fromMugshotUrl = messageFromMugshotUrl;
    
    NSError *error;
    if (![dataStoreContext save:&error]) {
        NSLog(@"Saving message to data store failed: %@",error.description);
    }
}

/// Data manipulation methods for Categories

// Get number of all categories in the data store
- (NSUInteger)noOfAllCategories
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:dataStoreContext];
    [categoryFetchRequest setEntity:categoryEntity];
    
    NSError *error;
    NSUInteger count = [dataStoreContext countForFetchRequest:categoryFetchRequest error:&error];
    if (count == NSNotFound) {
        NSLog(@"Getting number of all categories in the data store failed: %@",error.description);
    }
    
    return count;
}

// Get a category at a position in the result set from querying all categories
- (Category *)getCategoryAtPositionFromAll:(NSUInteger)position 
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:dataStoreContext];
    [categoryFetchRequest setEntity:categoryEntity];
    
    NSError *error;
    NSArray *fetchedCategories = [dataStoreContext executeFetchRequest:categoryFetchRequest error:&error];
    
    return [fetchedCategories objectAtIndex:position];
}

// Add a category to the data store
- (void)insertCategoryWithTitle:(NSString *)categoryTitle Message:(Message *)associatedMessage;
{
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:associatedMessage.managedObjectContext];
    category.title = categoryTitle;
    
    NSError *error;
    if (![category.managedObjectContext save:&error]) {
        NSLog(@"Saving category to data store failed: %@",error.description);
    }
}

/// Methods to call Yammer REST APIs

// Get a list of messages that match the topic string from the Yammer search API
- (void)getMessages
{
    NXOAuth2Account *userAccount;
    // Get the Oauthenticated account for the user
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        userAccount = account;
    }
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:@"https://www.yammer.com/api/v1/search.json"]
                        usingParameters:[[NSDictionary alloc] initWithObjectsAndKeys: @"siddlocker", @"search", nil]
                        withAccount:userAccount
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   // Update progress indicator
               }
               responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                   // Process the response
                   [self formatAddMessages:responseData];
               }];
}

// Parse the list of messages, format them for display and add them to the
// initialized message store. Send a notification that the store has been updated.
- (void)formatAddMessages:(NSData *)response {
    
    NSError *error;
    
    // Here's the format of the messages section of the API response
    // messages":{
    //     "meta":{},
    //     "messages":[],
    //     "threaded_extended":{},
    //     "references":[]
    // }
    // Get the response into a parsed object
    NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:response
                                                        options:kNilOptions
                                                        error:&error];
    // Get the messages section first from the overall response
    NSDictionary *parsedMessagesSection = [parsedResponse objectForKey:@"messages"];
    
    // Next get the messages in the section
    NSArray* parsedMessages = [parsedMessagesSection objectForKey:@"messages"];
    
    // Then loop through the messages, get the appropriate fields and create messages
    // to be displayed in this app.
    for (NSDictionary *message in parsedMessages) {
        NSDictionary *messageBody = [message objectForKey:@"body"];
        NSString *messageContent = [messageBody objectForKey:@"plain"];
        NSString *messageWebUrl = [message objectForKey:@"web_url"];
        NSString *messageFromId = [NSString stringWithFormat:@"%@",[message objectForKey:@"sender_id"]];
        // Get user full name and mugshot URL from the response using the id
        // Get the references from the messages section
        NSString *messageFrom;
        NSString *mugshotURL;
        NSArray* parsedReferences = [parsedMessagesSection objectForKey:@"references"];
        // Then loop through the references to find the one that is the type "user" and matching the id
        for (NSDictionary *reference in parsedReferences) {
            NSString *referenceType = [reference objectForKey:@"type"];
            NSString *referenceId = [NSString stringWithFormat:@"%@",[reference objectForKey:@"id"]];
            if ([referenceType isEqualToString:@"user"]&&[referenceId isEqualToString:messageFromId]) {
                messageFrom = [reference objectForKey:@"full_name"];
                mugshotURL = [reference objectForKey:@"mugshot_url"];
                break;
            }
        }
        // NSLog(@"Message Content: %@, From: %@, Web URL: %@",messageContent,messageFrom,messageWebUrl);
        
        // Add messages to the initialized message store
        // TO DO: Remove hardcoded app type name.
        [self insertMessageWithContent:messageContent from:messageFrom app:@"Yammer" webUrl:messageWebUrl fromMugshotUrl:mugshotURL];
        NSLog(@"message should have been added to the message table.");
    }
    
    // Send a notification that the store has been updated
    [self sendChangeNotification];
}

// Send a notification that the list of messages has changed (updated)
- (void)sendChangeNotification {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MessageStoreUpdated" object:self];
    NSLog(@"Notification Sent that message store has been updated");
}

@end
