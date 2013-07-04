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

@interface YammerLockerDataController : NSObject

// To interact with data from Core Data Store
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Core Data Store object model
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

// Store Coordinator for Core Data Store
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Implement this class as a Singleton to create a single data connection accessible
// from anywhere in the app. Create and/or return the single instance of this class.
+ (YammerLockerDataController *) sharedDataController;

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory;

/// Data manipulation methods for User

// Check to see if the user has a authentication token
- (BOOL)checkForExistingAuthToken;

// Add a auth token to the user data store
- (void)insertUserAuthToken:(NSString *)userAuthToken;

/// Data manipulation methods for Messages

// Get number of all messages in the data store
- (NSUInteger)noOfAllMessages;

// Get a message at a position in the result set from querying all messages
- (Message *)getMessageAtPositionFromAll:(NSUInteger)position;

// Add a message to the data store
- (void)insertMessageWithContent:(NSString *)messageContent from:(NSString *)messageFrom app:(NSString *)messageApp webUrl:(NSString *)messageWebUrl fromMugshotUrl:(NSString *)messageFromMugshotUrl;

// Get number of messages in the data store with a particular category
- (NSUInteger)noOfMessagesWithCategory:(NSString *)categoryTitle;

// Get a message at a position in the result set from querying messages with
// a particular category
- (Message *)getMessageAtPosition:(NSUInteger)position category:(NSString *)categoryTitle;

/// Data manipulation methods for Categories

// Get number of all categories in the data store
- (NSUInteger)noOfAllCategories;

// Get a category at a position in the result set from querying all categories
- (Category *)getCategoryAtPositionFromAll:(NSUInteger)position;

// Add a category to the data store or update it, to link to the message, if it exists.
- (void)upsertCategoryWithTitle:(NSString *)categoryTitle Message:(Message *)associatedMessage;

/// Methods to call Yammer REST APIs

// Get a list of messages that match the topic string from the Yammer search API and add to core data store
- (void)getMessages;


@end