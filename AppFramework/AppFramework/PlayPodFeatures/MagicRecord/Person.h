//
//  Person.h
//  AppFramework
//
//  Created by Dong Yiming on 10/25/13.
//  Copyright (c) 2013 ToMaDon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;

@end
