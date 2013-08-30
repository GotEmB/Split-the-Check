//
//  Owe.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/31/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Owe : NSManagedObject

@property (nonatomic, retain) NSNumber * fraction;
@property (nonatomic, retain) NSManagedObject *item;
@property (nonatomic, retain) Person *person;

@end
