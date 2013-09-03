//
//  CheckViewController.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/30/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Check;

@interface CheckViewController : UITableViewController <UITextFieldDelegate>

@property Check *check;
@property (weak) NSManagedObjectContext *context;

@end
