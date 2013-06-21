//
//  Message.h
//  YammerLocker
//
//  Created by Sidd Singh on 6/19/13.
//  Copyright (c) 2013 Sidd Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * webUrl;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * fromMugshotUrl;

@end
