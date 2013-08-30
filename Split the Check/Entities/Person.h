//
//  Person.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/31/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *owes;
@property (nonatomic, retain) NSManagedObject *check;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addOwesObject:(NSManagedObject *)value;
- (void)removeOwesObject:(NSManagedObject *)value;
- (void)addOwes:(NSSet *)values;
- (void)removeOwes:(NSSet *)values;

@end
