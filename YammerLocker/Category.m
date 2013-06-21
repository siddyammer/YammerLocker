//
//  Category.m
//  YammerLocker
//
//  Class representing a category to which a message belongs
//
//  Created by Sidd Singh on 4/22/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import "Category.h"

@implementation Category

// Initialize a new message
- (id)initWithName:(NSString *)name {
    
    self = [super init];
    
    if (self) {
        _name = name;
        return self;
    }
    
    return nil;
}

@end
