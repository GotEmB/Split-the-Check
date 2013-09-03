//
//  Person.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/3/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check, Owe;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Check *check;
@property (nonatomic, retain) NSSet *owes;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addOwesObject:(Owe *)value;
- (void)removeOwesObject:(Owe *)value;
- (void)addOwes:(NSSet *)values;
- (void)removeOwes:(NSSet *)values;

@end
