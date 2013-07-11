//
//  User.h
//  YammerLocker
//
//  Represents the User object in the core data model.
//
//  Created by Sidd Singh on 7/10/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * nameString;

@end
