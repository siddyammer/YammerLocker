//
//  Message.h
//  YammerLocker
//
//  Created by Sidd Singh on 8/12/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//
//  Represents the Message object in the core data model.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * fromMugshotUrl;
@property (nonatomic, retain) NSString * webUrl;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSSet *categories;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
