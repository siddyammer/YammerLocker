//
//  YammerMessageDataController.h
//  YammerLocker
//
//  Class stores and provides access to Yammer Messages and Categories, stored in core data.
//
//  Created by Sidd Singh on 12/11/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Message;
@class Category;
@class NSFetchedResultsController;

@interface YammerLockerDataController : NSObject

// Create and/or return the single shared data controller
+ (YammerLockerDataController *) sharedController;

//////////////////////  Core Data Methods  ////////////////////

// To interact with data from Core Data Store
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Core Data Store object model
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

// Store Coordinator for Core Data Store
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory;

// Controller containing results of queries to Core Data
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

////////////////  Data manipulation methods for User  ////////////////

// Check to see if the user has an authentication token. Works off the
// assumption that there is only one user object and if it exists then
// the user is logged in.
- (BOOL)checkForExistingAuthToken;

// Add a auth token to the user data store or update it if it already exists. Current design is that there can be only one user object with a single auth token.
- (void)upsertUserAuthToken:(NSString *)userAuthToken;

// Get the access token for the one user object.
- (NSString *)getUserAccessToken;

// Add the user string to the user data store. Current design is that there can be only one data object.
- (void)insertUserString:(NSString *)userString;

// Get the user string for the one user object.
- (NSString *)getUserString;

// Delete the one user object
- (void)deleteUser;

///////////////  Data manipulation methods for Messages  ///////////////

// Get all messages. Returns a results controller with identities of all messages recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllMessages;

// Get all messages in a category. Returns a results controller with identities of all messages recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllMessagesInCategory:(NSString *)categoryTitle;

// Add a message to the data store
- (void)insertMessageWithContent:(NSString *)messageContent from:(NSString *)messageFrom app:(NSString *)messageApp webUrl:(NSString *)messageWebUrl fromMugshotUrl:(NSString *)messageFromMugshotUrl;

///////////////  Data manipulation methods for Categories  ///////////////

// Get all categories. Returns a results controller with identities of all categories recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllCategories;

// Add a category to the data store or update it, to link to the message, if it exists.
- (void)upsertCategoryWithTitle:(NSString *)categoryTitle Message:(Message *)associatedMessage;

///////////////  Methods to call Yammer REST APIs  ///////////////

// Get a list of messages that match the topic string from the Yammer search API
// and add to core data store
- (void)getMessages;

// Get all messages that match the topic string from the Yammer search API
// and add to core data store
- (void)getAllMessagesFromApi;

// Get the current user data, using the endpoint /api/v1/users/current.json,
// and add the user string to the datastore. This is typically the part before @ in the username
// e.g. in sidd@bddemo.com, the user string would be sidd
- (void)getCurrentUserData;

// Issue an http call to decline the mobile interstitial which asks the user if they had like to
// install the ipad app
- (void)declineMobileInterstitial;

@end