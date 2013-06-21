//
//  Category.h
//  YammerLocker
//
//  Class representing a category to which a message belongs
//
//  Created by Sidd Singh on 4/22/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

// The name of the category
@property (nonatomic,copy) NSString *name;

// 

// Initialize a new category
- (id)initWithName:(NSString *)name;



@end
