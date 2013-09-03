//
//  Owe.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/3/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Person;

@interface Owe : NSManagedObject

@property (nonatomic, retain) NSNumber * fraction;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Person *person;

@end
