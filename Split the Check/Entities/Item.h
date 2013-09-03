//
//  Item.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/3/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check, Owe, SubItem;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Check *check;
@property (nonatomic, retain) NSSet *owes;
@property (nonatomic, retain) NSSet *subItems;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addOwesObject:(Owe *)value;
- (void)removeOwesObject:(Owe *)value;
- (void)addOwes:(NSSet *)values;
- (void)removeOwes:(NSSet *)values;

- (void)addSubItemsObject:(SubItem *)value;
- (void)removeSubItemsObject:(SubItem *)value;
- (void)addSubItems:(NSSet *)values;
- (void)removeSubItems:(NSSet *)values;

@end
