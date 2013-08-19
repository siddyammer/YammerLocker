//
//  YammerLockerDataController.h
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

// Add a auth token to the user data store. Current design is that the user object is created
// when it's authentication is done. Thus this method creates the user with the auth token if it
// doesn't exist or updates the user with the new auth token if the user exists.
- (void)upsertUserWithAuthToken:(NSString *)userAuthToken;

// Get the access token for the one user object.
- (NSString *)getUserAccessToken;

// Add the user string to the user data store. Current design is that there can be only one data object.
- (void)insertUserString:(NSString *)userString;

// Get the user string for the one user object.
- (NSString *)getUserString;

// Set state of the initial data fetch on the one user object
- (void)setInitialDataState:(BOOL)state;

// Get state of the initial data fetch on the one user object
- (BOOL)getInitialDataState;

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
- (void)insertMessageWithID:(NSNumber *)messageID content:(NSString *)messageContent from:(NSString *)messageFrom app:(NSString *)messageApp webUrl:(NSString *)messageWebUrl fromMugshotUrl:(NSString *)messageFromMugshotUrl;

///////////////  Data manipulation methods for Categories  ///////////////

// Get all categories. Returns a results controller with identities of all categories recorded, but no more
// than batchSize (currently set to 15) objects’ data will be fetched from the persistent store at a time.
- (NSFetchedResultsController *)getAllCategories;

// Add a category to the data store or update it, to link to the message, if it exists.
- (void)upsertCategoryWithTitle:(NSString *)categoryTitle Message:(Message *)associatedMessage;

///////////////  Methods to call Yammer REST APIs  ///////////////

// Get all messages that match the topic string from the Yammer search API
// and add to core data store
- (void)getAllMessagesFromApi;

// Get the latest 2 pages worth of messages (40) that match the topic string from the Yammer search API,
// check if these already exist in the core data store and if not add them.
- (void)getNewMessagesFromApi;

// Get the current user data, using the endpoint /api/v1/users/current.json,
// and add the user string to the datastore. This is typically the part before @ in the username
// e.g. in sidd@bddemo.com, the user string would be sidd
- (void)getCurrentUserData;

// Issue an http call to decline the mobile interstitial which asks the user if they had like to
// install the ipad app
- (void)declineMobileInterstitial;

@end