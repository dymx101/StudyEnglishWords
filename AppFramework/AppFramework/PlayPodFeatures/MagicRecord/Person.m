//
//  Person.m
//  AppFramework
//
//  Created by Dong Yiming on 10/25/13.
//  Copyright (c) 2013 ToMaDon. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic age;
@dynamic firstname;
@dynamic lastname;

-(NSString *)description
{
    NSString *superDesc = [super description];
    NSString *selfDesc = [NSString stringWithFormat:@"Person {name:%@ %@, age:%d}", self.firstname, self.lastname, self.age.intValue];
    
    //return superDesc;
    return [NSString stringWithFormat:@"%@/n%@", selfDesc, superDesc];
}

@end
