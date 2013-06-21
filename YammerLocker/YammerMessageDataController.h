//
//  YammerMessageDataController.h
//  YammerLocker
//
//  Class stores and provides access to Yammer messages.
//
//  Created by Sidd Singh on 12/11/12.
//  Copyright (c) 2012 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Message;

@interface YammerMessageDataController : NSObject

// To interact with data from Core Data Store
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Core Data Store object model
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

// Store Coordinator for Core Data Store
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory;

// Get number of all messages in the data store
- (NSUInteger)noOfAllMessages;

// Get a message at a position in the result set from querying all messages
- (Message *)getMessageAtPositionFromAll:(NSUInteger)position;

// Add a message to the data store
- (void)insertMessageWithContent:(NSString *)messageContent from:(NSString *)messageFrom app:(NSString *)messageApp webUrl:(NSString *)messageWebUrl fromMugshotUrl:(NSString *)messageFromMugshotUrl;

@end