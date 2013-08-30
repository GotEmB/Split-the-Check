//
//  SubItem.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/31/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SubItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSManagedObject *item;

@end
