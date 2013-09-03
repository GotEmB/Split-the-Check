//
//  NewCheckViewController.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/29/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Check;

@interface NewCheckViewController : UITableViewController

@property (weak) NSManagedObjectContext *context;
@property (copy) void (^dismissViewControllerCallback)(Check *);

- (IBAction)cancelNewCheck:(id)sender;
- (IBAction)commitNewCheck:(id)sender;

@end
