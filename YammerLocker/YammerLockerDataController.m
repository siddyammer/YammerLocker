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

@interface YammerLockerDataController ()

// Parse the list of messages from the Yammer API and format them for display
- (void)formatAddMessages:(NSData *)response;

// Parse the search query response and return total no of pages of messages in it.
// Assuming 20 messages are returned per page.
- (NSInteger)getNoOfMessagePages:(NSData *)response;

// Parse out and save the user string from the current user data.
- (void)parseAddUserString:(NSData *)response;

// Send a notification that the list of messages has changed (updated)
- (void)sendMessagesChangeNotification;

@end

@implementation YammerLockerDataController

static YammerLockerDataController *sharedInstance;

// Implement this class as a Singleton to create a single data connection accessible
// from anywhere in the app.
+ (void)initialize
{
    static BOOL exists = NO;
    
    // If a data controller doesn't already exist
    if(!exists)
    {
        exists = YES;
        sharedInstance= [[YammerLockerDataController alloc] init];
    }
}

// Create and/or return the single shared data controller
+(YammerLockerDataController *)sharedController {
    
    return sharedInstance;
}

////////////////////////////////////  Core Data Methods  //////////////////////////////////

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
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {NSLog(@"ERROR: Unresolved error trying to get persistent store coordinator for core data setup %@, %@", error, [error userInfo]);
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

// Controller containing results of queries to Core Data
/*- (NSFetchedResultsController *)resultsController {
    
    if (_resultsController != nil) {
        return _resultsController;
    }
    return [[NSFetchedResultsController alloc] init];
} */

////////////////////////////  Data manipulation methods for User  ///////////////////////////

// Check to see if the user has an authentication token. Works off the
// assumption that there is only one user object and if it exists then
// the user is logged in.
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
        NSLog(@"WARNING: Getting number of users in the data store failed: %@",error.description);
    }
    if (count > 1) {
        NSLog(@"SEVERE_WARNING: Found more than 1 user object in the User Data Store");
    }
    
    // If there are no users means the user has not logged in. Current design is that
    // once the user has logged in, a user is created in the data store with an auth token.
    if (count == 0) {
        return NO;
    } else{
        return YES;
    }
}

// Add a auth token to the user data store or update it if it already exists. Current design is that
// there can be only one user object with a single auth token.
- (void)upsertUserAuthToken:(NSString *)userAuthToken
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    // Check to see if the auth token exists by doing a case sensitive query on user's auth token
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"authToken = %@",userAuthToken];
    [userFetchRequest setEntity:userEntity];
    [userFetchRequest setPredicate:userPredicate];
    NSError *error;
    User *existingUser = nil;
    existingUser  = [[dataStoreContext executeFetchRequest:userFetchRequest error:&error] lastObject];
    if (error) {
        NSLog(@"ERROR: Getting user from data store failed: %@",error.description);
    }
    
    // If the category does not exist
    else if (!existingUser) {
        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:dataStoreContext];
        user.authToken = userAuthToken;
    }
    
    // TO DO: Should you really need to check for this
    // If the token exists, log a warning that due to some code condition, a new existing Oauth token is trying
    // to be written.
    else {
        NSLog(@"WARNING: Trying to update an existing Oauth token with the same value. Operation ignored");
    }
    
    // Insert or update the category
    if (![dataStoreContext save:&error]) {
        NSLog(@"ERROR: Saving user auth token to data store failed: %@",error.description);
    }
}

// Get the access token for the one user object.
- (NSString *)getUserAccessToken {
    
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *tokenFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    [tokenFetchRequest setEntity:userEntity];
    
    NSError *error;
    NSArray *fetchedUsers = [dataStoreContext executeFetchRequest:tokenFetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR: Getting user from data store failed: %@",error.description);
    }
    if (fetchedUsers.count > 1) {
        NSLog(@"SEVERE_WARNING: Found more than 1 user objects in the User Data Store");
    }
    
    User *fetchedUser = [fetchedUsers lastObject];
    return fetchedUser.authToken;
}

// Add the user string to the user data store. Current design is that there can be only one data object.
- (void)insertUserString:(NSString *)userString {
    
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    // Check to see if the user object exists by querying for it
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    [userFetchRequest setEntity:userEntity];
    NSError *error;
    User *existingUser = nil;
    NSArray *fetchedUsers= [dataStoreContext executeFetchRequest:userFetchRequest error:&error];
    existingUser = [fetchedUsers lastObject];
    if (error) {
        NSLog(@"ERROR: Getting user from data store failed: %@",error.description);
    }
    if (fetchedUsers.count > 1) {
        NSLog(@"SEVERE_WARNING: Found more than 1 user objects in the User Data Store");
    }
    
    // If the user does not exist
    else if (!existingUser) {
        NSLog(@"ERROR: User does not exist in the data store and trying to set their name string");
    }
    
    // If the user exists
    else {
        existingUser.nameString = userString;
    }
    
    // Insert or update the category
    if (![dataStoreContext save:&error]) {
        NSLog(@"ERROR: Saving user string to data store failed: %@",error.description);
    }
}

// Get the user string for the one user object.
- (NSString *)getUserString {
    
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *tokenFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    [tokenFetchRequest setEntity:userEntity];
    
    NSError *error;
    NSArray *fetchedUsers = [dataStoreContext executeFetchRequest:tokenFetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR: Getting user from data store failed: %@",error.description);
    }
    if (fetchedUsers.count > 1) {
        NSLog(@"SEVERE_WARNING: Found more than 1 user objects in the User Data Store");
    }
    
    User *fetchedUser = [fetchedUsers lastObject];
    return fetchedUser.nameString;
}

// Delete the one user object
- (void)deleteUser {
    
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *tokenFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:dataStoreContext];
    [tokenFetchRequest setEntity:userEntity];
    
    NSError *error;
    NSArray *fetchedUsers = [dataStoreContext executeFetchRequest:tokenFetchRequest error:&error];
    if (error) {
        NSLog(@"ERROR: Getting user from data store failed: %@",error.description);
    }
    if (fetchedUsers.count > 1) {
        NSLog(@"SEVERE_WARNING: Found more than 1 user objects in the User Data Store");
    }
    
    User *fetchedUser = [fetchedUsers lastObject];
    [dataStoreContext deleteObject:fetchedUser];
    [dataStoreContext save:&error];
    if (error) {
        NSLog(@"ERROR: Deleting user from data store failed: %@",error.description);
    }
   }

//////////////////////////////////  Data manipulation methods for Messages  ///////////////////////////////////

// Get all messages. Returns a results controller with identities of all messages recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllMessages
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    [messageFetchRequest setEntity:messageEntity];
    
    NSSortDescriptor *sortField = [[NSSortDescriptor alloc] initWithKey:@"webUrl" ascending:NO];
    [messageFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortField]];
    
    [messageFetchRequest setFetchBatchSize:15];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:messageFetchRequest
                                        managedObjectContext:dataStoreContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"ERROR: Getting all messages from data store failed: %@",error.description);
    }
    
    return self.resultsController;
}

// Get all messages in a category. Returns a results controller with identities of all messages recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllMessagesInCategory:(NSString *)categoryTitle
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:dataStoreContext];
    [messageFetchRequest setEntity:messageEntity];
    
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.title =[c] %@",categoryTitle];
    [messageFetchRequest setPredicate:categoryPredicate];
    
    NSSortDescriptor *sortField = [[NSSortDescriptor alloc] initWithKey:@"webUrl" ascending:NO];
    [messageFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortField]];
    
    [messageFetchRequest setFetchBatchSize:15];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:messageFetchRequest
                                                                 managedObjectContext:dataStoreContext sectionNameKeyPath:nil
                                                                            cacheName:nil];
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"ERROR: Getting all messages with category: %@ from data store failed: %@",categoryTitle, error.description);
    }
    
    return self.resultsController;
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
        NSLog(@"ERROR: Saving message to data store failed: %@",error.description);
    }
}

//////////////////////////////////  Data manipulation methods for Categories  //////////////////////////////////

// Get all categories. Returns a results controller with identities of all categories recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllCategories
{
    NSManagedObjectContext *dataStoreContext = [self managedObjectContext];
    
    NSFetchRequest *categoryFetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:dataStoreContext];
    [categoryFetchRequest setEntity:categoryEntity];
    
    NSSortDescriptor *sortField = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    [categoryFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortField]];
    
    [categoryFetchRequest setFetchBatchSize:15];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:categoryFetchRequest
                                                                 managedObjectContext:dataStoreContext sectionNameKeyPath:nil
                                                                            cacheName:nil];
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"ERROR: Getting all categories from data store failed: %@",error.description);
    }
    
    return self.resultsController;
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
        NSLog(@"ERROR: Getting a category from data store failed: %@",error.description);
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
        NSLog(@"ERROR: Saving category to data store failed: %@",error.description);
    }
}

////////////////////////////////////////  Methods to call Yammer REST APIs  ///////////////////////////////////////

// Get a list of messages that match the topic string from the Yammer search API
- (void)getMessages
{
    // Get the user's access token
    NSString *accessToken = [self getUserAccessToken];
    
    // Get the user's custom hashtag (topic) used to get messages from Yammer
    // TO DO: locker is hardcoded. Change that.
    NSString *userHashtag =[NSString stringWithFormat:@"%@%@",[self getUserString],@"locker"];
    
    // The API endpoint URL
    NSString *endpointURL = @"https://www.yammer.com/api/v1/search.json";
    
    // Append search string as parameter to the URL
    endpointURL = [NSString stringWithFormat:@"%@?search=%@",endpointURL,userHashtag];
    
    NSError * error = nil;
    NSURLResponse *oAuthTokenResponse = nil;
    
    // Add access token to the http authorization header as a bearer token
    NSMutableURLRequest *messageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointURL]];
    NSString *authHeader = [NSString stringWithFormat:@"Bearer %@",accessToken];
    [messageRequest setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    // Make the call synchronously
    NSData *responseData = [NSURLConnection sendSynchronousRequest:messageRequest returningResponse:&oAuthTokenResponse
                                                             error:&error];
    
    // Process the response
    if (error == nil)
    {
        // Process the response
        [self formatAddMessages:responseData];
    } else {
        NSLog(@"ERROR: Could not get messages from the Yammer Search endpoint. Error description: %@",error.description);
    }
}

// Get all messages that match the topic string from the Yammer search API and add to core data store
- (void)getAllMessagesFromApi
{
    // Get the user's access token
    NSString *accessToken = [self getUserAccessToken];
    
    // Get the user's custom hashtag (topic) used to get messages from Yammer
    // TO DO: locker is hardcoded. Change that.
    NSString *userHashtag =[NSString stringWithFormat:@"%@%@",[self getUserString],@"locker"];
    
    // The API endpoint URL
    NSString *endpointURL = @"https://www.yammer.com/api/v1/search.json";
    
    // Set page number of the results, with 20 messages being returned per page, to 1
    NSInteger pageNo = 1;
    
    // Retrieve first page to get no of pages and then keep retrieving till you get all pages.
    while (pageNo > 0) {
        
        // Append page number and search string as parameter to the API endpoint URL
        endpointURL = [NSString stringWithFormat:@"%@?page=%d&search=%@",endpointURL,pageNo,userHashtag];
    
        // Add access token to the http authorization header as a bearer token
        NSMutableURLRequest *messageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointURL]];
        NSString *authHeader = [NSString stringWithFormat:@"Bearer %@",accessToken];
        [messageRequest setValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        NSError * error = nil;
        NSURLResponse *oAuthTokenResponse = nil;
    
        // Make the call synchronously
        NSData *responseData = [NSURLConnection sendSynchronousRequest:messageRequest returningResponse:&oAuthTokenResponse
                                                             error:&error];
    
        // Process the response
        if (error == nil)
        {
            // Process response to get total no of pages of messages in the response
            [self getNoOfMessagePages:responseData];
            
            // Process the response from the first page
            [self formatAddMessages:responseData];
        } else {
            NSLog(@"ERROR: Could not get messages from the Yammer Search endpoint. Error description: %@",error.description);
        }
        
        --pageNo;
    }
}

// Parse the search query response and return total no of pages of messages in it.
// Assuming 20 messages are returned per page.
- (NSInteger)getNoOfMessagePages:(NSData *)response {
    
    NSError *error;
    NSInteger noOfPages = 1;
    
    // Here's the format of the search query response
    // {
    //    "messages":{},
    //    "groups":[],
    //    "topics":[],
    //    "users":[],
    //    "pages":[],
    //    "search_uuid":"abc",
    //    "count":{
    //        "messages":32,
    //        "praises":0,
    //        "pages":0,
    //        "users":0,
    //        "topics":1,
    //        "groups":0,
    //        "uploaded_files":0
    //      },
    
    // Get the response into a parsed object
    NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                   options:kNilOptions
                                                                     error:&error];
    // Get the count section first from the overall response
    NSDictionary *parsedCountSection = [parsedResponse objectForKey:@"count"];
    
    // Next get the no of messages in the count section
    NSString *parsedNoOfMessages = [parsedCountSection objectForKey:@"messages"];
    NSInteger noOfMessages = [parsedNoOfMessages integerValue];
    NSLog(@"****************NO OF MESSAGES IN RESPONSE:%d",noOfMessages);
    
    // Compute no of pages assuming 20 messages per page
    noOfPages = (noOfMessages/20) + 1;
    if ((noOfMessages%20)== 0){
        -- noOfPages;
    }
    NSLog(@"****************NO OF PAGES IN RESPONSE:%d",noOfPages);
    
    return noOfPages;
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
        
        // Add messages to the initialized message store
        // TO DO: Remove hardcoded app type name.
        [self insertMessageWithContent:messageContent from:messageFrom app:@"Yammer" webUrl:messageWebUrl fromMugshotUrl:mugshotURL];
    }
    
    // Send a notification that the store has been updated
    [self sendMessagesChangeNotification];
}

// Get the current user data, using the endpoint /api/v1/users/current.json,
// and add the user string to the datastore. This is typically the part before @ in the username
// e.g. in sidd@bddemo.com, the user string would be sidd
- (void)getCurrentUserData {
    
    // Get the user's access token
    NSString *accessToken = [self getUserAccessToken];
    
    // The API endpoint URL
    NSString *endpointURL = @"https://www.yammer.com/api/v1/users/current.json";
    
    NSError * error = nil;
    NSURLResponse *oAuthTokenResponse = nil;
    
    // Add access token to the http authorization header as a bearer token
    NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointURL]];
    NSString *authHeader = [NSString stringWithFormat:@"Bearer %@",accessToken];
    [userRequest setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    // Make the call synchronously
    NSData *responseData = [NSURLConnection sendSynchronousRequest:userRequest returningResponse:&oAuthTokenResponse
                                                             error:&error];
    
    // Process the response
    if (error == nil)
    {
        // Process the response
        [self parseAddUserString:responseData];
    } else {
        NSLog(@"ERROR: Could not get user information from the Yammer Current User endpoint. Error description: %@",error.description);
    }
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
        // Add current user string to the data store
        [self insertUserString:currUserString];
}

// Send a notification that the list of messages has changed (updated)
- (void)sendMessagesChangeNotification {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MessageStoreUpdated" object:self];
}

// Issue an http call to decline the mobile interstitial which asks the user if they had like to
// install the ipad app
- (void)declineMobileInterstitial {
    
    NSString *declineHttpAddress = @"https://www.yammer.com/home/decline_mobile_interstitial";
    
    NSError * error = nil;
    NSURLResponse *declineResponse = nil;
    
    NSMutableURLRequest *declineRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:declineHttpAddress]];
    [NSURLConnection sendSynchronousRequest:declineRequest returningResponse:&declineResponse error:&error];
    
    if (error) {
        NSLog(@"WARNING: Could not dismiss the mobile interstitial. Error description: %@",error.description);
    } 
}

@end
