//
//  YammerMessageDataController.m
//  YammerLocker
// 
//  Class stores and provides access to Yammer Messages and Categories, stored in core data.
//
//  Created by Sidd Singh on 12/11/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import "YammerLockerDataController.h"
#import "User.h"
#import "Message.h"
#import "Category.h"
#import "NXOAuth2.h"

@interface YammerLockerDataController ()

// Parse the list of messages from the Yammer API and format them for display
- (void)formatAddMessages:(NSData *)response;

// Parse out and save the user string from the current user data.
- (void)parseAddUserString:(NSData *)response;

// Send a notification that the list of messages has changed (updated)
- (void)sendMessagesChangeNotification;

@end

@implementation YammerLockerDataController

// Implement this class as a Singleton to create a single data connection accessible
// from anywhere in the app. Create and/or return the single instance of this class.
+ (YammerLockerDataController *) sharedDataController {
    
    static dispatch_once_t pred;
    static YammerLockerDataController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[YammerLockerDataController alloc] init];
    });
    
    return shared;
}

// Initialize the message data controller object
/* - (id)init {
    
    if (self = [super init]) {
        [self getInitialMessages];
        return self;
    }
    
    return nil;
} */

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

/// Data manipulation methods for User

// Check to see if the user has an authentication token. Current design is that
// once the user has logged in, a user is created in the data store with an auth token.
- (BOOL)checkForExistingAuthToken
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    // Query for number of user objects
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    [userFetchRequest setEntity:userEntity];
    
    NSError *error;
    NSUInteger count = [dataStoreContext countForFetchRequest:userFetchRequest error:&error];
    if (count == NSNotFound) {
        NSLog(@"Getting number of users in the data store failed: %@",error.description);
    }
    
    // If there are no users means the user has not logged in. Current design is that
    // once the user has logged in, a user is created in the data store with an auth token.
    if (count == 0) {
        return NO;
    } else{
        return YES;
    }
}

// Add a user auth token  to the data store
- (void)insertUserAuthToken:(NSString *)userAuthToken
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:dataStoreContext];
    
    (NSLog(@"userAuthToken object in data controller type is %@",userAuthToken.class));
    user.authToken = userAuthToken;
    
    NSError *error;
    if (![dataStoreContext save:&error]) {
        NSLog(@"Saving user token to data store failed: %@",error.description);
    }
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

// Get number of messages in the data store with a particular category
- (NSUInteger)noOfMessagesWithCategory:(NSString *)categoryTitle
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.title =[c] %@",categoryTitle];
    [messageFetchRequest setEntity:messageEntity];
    [messageFetchRequest setPredicate:categoryPredicate];
    
    NSError *error;
    NSUInteger count = [dataStoreContext countForFetchRequest:messageFetchRequest error:&error];
    if (count == NSNotFound) {
        NSLog(@"Getting number of messages in the data store with category %@ failed: %@",categoryTitle,error.description);
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
    
    if (error) {
        NSLog(@"Getting all messages from data store failed: %@",error.description);
    }
    
    return [fetchedMessages objectAtIndex:position];
}

// Get a message at a position in the result set from querying messages with a particular category
- (Message *)getMessageAtPosition:(NSUInteger)position category:(NSString *)categoryTitle
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.title =[c] %@",categoryTitle];
    [messageFetchRequest setEntity:messageEntity];
    [messageFetchRequest setPredicate:categoryPredicate];
    
    NSError *error;
    NSArray *fetchedMessages = [dataStoreContext executeFetchRequest:messageFetchRequest error:&error];
    
    if (error) {
        NSLog(@"Getting all messages from data store failed: %@",error.description);
    }
    
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
    
    NSError *error = nil;
    NSArray *fetchedCategories = [dataStoreContext executeFetchRequest:categoryFetchRequest error:&error];
    if (error) {
        NSLog(@"Getting all categories from data store failed: %@",error.description);
    }
    
    return [fetchedCategories objectAtIndex:position];
}

// Add a category to the data store or update it, to link to the message, if it exists.
- (void)upsertCategoryWithTitle:(NSString *)categoryTitle Message:(Message *)associatedMessage;
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    // Check to see if the category exists by doing a case insensitive query on category title
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:dataStoreContext];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"title =[c] %@",categoryTitle];
    [categoryFetchRequest setEntity:categoryEntity];
    [categoryFetchRequest setPredicate:categoryPredicate];
    NSError *error;
    Category *existingCategory = nil;
    existingCategory  = [[dataStoreContext executeFetchRequest:categoryFetchRequest error:&error] lastObject];
    if (error) {
        NSLog(@"Getting a category from data store failed: %@",error.description);
    }
    
    // If the category does not exist
    else if (!existingCategory) {
        Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:dataStoreContext];
    category.title = categoryTitle;
    [category addMessagesObject:associatedMessage];
    }
    
    // If the category exists
    else {
        [existingCategory addMessagesObject:associatedMessage];
    }
    
    // Insert or update the category
    if (![dataStoreContext save:&error]) {
        NSLog(@"Saving category to data store failed: %@",error.description);
    }
}

/// Methods to call Yammer REST APIs

// Get a list of messages that match the topic string from the Yammer search API
- (void)getMessages
{
   /* NXOAuth2Account *userAccount;
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
    */
    
    NSError *error;
    
    // Get the user's access token
    NSString *accessToken = @"EviRYoOpUQH8flUhQagvw";
    
    // Get the user's custom hashtag (topic) used to get messages from Yammer
    NSString *userHashtag = @"siddlocker";
    
    // The API endpoint URL
    NSString *endpointURL = @"https://www.yammer.com/api/v1/search.json";
    
    // Append search string and access token as parameters to the URL
    endpointURL = [NSString stringWithFormat:@"%@?search=%@&access_token=%@",endpointURL,userHashtag,accessToken];
    
    // Call the endpoint with the access token
    NSData *responseData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:endpointURL] encoding:NSUTF8StringEncoding error: &error] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Process the response */
    [self formatAddMessages:responseData];
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
        // NSLog(@"***********Message Content: %@, From: %@, Web URL: %@",messageContent,messageFrom,messageWebUrl);
        
        // Add messages to the initialized message store
        // TO DO: Remove hardcoded app type name.
        [self insertMessageWithContent:messageContent from:messageFrom app:@"Yammer" webUrl:messageWebUrl fromMugshotUrl:mugshotURL];
        // NSLog(@"message should have been added to the message table.");
    }
    
    // Send a notification that the store has been updated
    [self sendMessagesChangeNotification];
}

// Get the current user data, using the endpoint /api/v1/users/current.json,
// and add the user string to the datastore. This is typically the part before @ in the username
// e.g. in sidd@bddemo.com, the user string would be sidd
- (void)getCurrentUserData {
  
    NSError *error;
    
    // Get the user's access token
    NSString *accessToken = @"EviRYoOpUQH8flUhQagvw";
    
    // The API endpoint URL
    NSString *endpointURL = @"https://www.yammer.com/api/v1/users/current.json";
    
    // Append access token as a parameter to the URL
    endpointURL = [NSString stringWithFormat:@"%@?access_token=%@",endpointURL,accessToken];
    
    // Call the endpoint with the access token
    NSData *responseData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:endpointURL] encoding:NSUTF8StringEncoding error: &error] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Process the response */
    [self parseAddUserString:responseData];
    
}

// Parse out and save the user string from the current user data.
- (void)parseAddUserString:(NSData *)response {
    
    NSError *error;
    
    // Name is at the highest level of the API response
    // {
    //   "name":"siddvicious",
    //   ......
    
    // Get the response into a parsed object
    NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                   options:kNilOptions
                                                                     error:&error];
    
    NSString *currUserString = [NSString stringWithFormat:@"%@",[parsedResponse objectForKey:@"name"]];
        // Add messages to the initialized message store
        // TO DO: Remove hardcoded app type name.
        //[self insertMessageWithContent:messageContent from:messageFrom app:@"Yammer" webUrl:messageWebUrl fromMugshotUrl:mugshotURL];
    NSLog(@"*********Current User String is: %@",currUserString);
}

// Send a notification that the list of messages has changed (updated)
- (void)sendMessagesChangeNotification {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MessageStoreUpdated" object:self];
    // NSLog(@"Notification Sent that message store has been updated");
}

@end
