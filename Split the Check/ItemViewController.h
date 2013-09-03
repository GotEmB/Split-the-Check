//
//  ItemViewController.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/1/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface ItemViewController : UITableViewController <UITextFieldDelegate>

@property Item *item;
@property (weak) NSManagedObjectContext *context;

@end
