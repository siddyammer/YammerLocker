//
//  User.h
//  YammerLocker
//
//  Created by Sidd Singh on 8/12/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//
//  Represents the User object in the core data model.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * nameString;

@end
