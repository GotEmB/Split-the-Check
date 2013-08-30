//
//  Item.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/31/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owe, SubItem;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSManagedObject *check;
@property (nonatomic, retain) NSSet *subItems;
@property (nonatomic, retain) NSSet *owes;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addSubItemsObject:(SubItem *)value;
- (void)removeSubItemsObject:(SubItem *)value;
- (void)addSubItems:(NSSet *)values;
- (void)removeSubItems:(NSSet *)values;

- (void)addOwesObject:(Owe *)value;
- (void)removeOwesObject:(Owe *)value;
- (void)addOwes:(NSSet *)values;
- (void)removeOwes:(NSSet *)values;

@end
