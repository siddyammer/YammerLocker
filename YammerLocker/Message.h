//
//  Message.h
//  YammerLocker
//
//  Created by Sidd Singh on 6/24/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * fromMugshotUrl;
@property (nonatomic, retain) NSString * webUrl;
@property (nonatomic, retain) NSSet *categories;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(NSManagedObject *)value;
- (void)removeCategoriesObject:(NSManagedObject *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
