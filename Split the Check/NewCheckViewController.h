//
//  NewCheckViewController.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/29/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCheckViewController : UITableViewController

@property bool showDatePicker;
@property NSString *checkTitle;
@property NSDate *checkTimeStamp;
@property (weak) NSFetchedResultsController *fetchedResultsController;
@property (weak) UITextField *titleTextField;
@property (weak) UILabel *timeStampLabel;
@property UIDatePicker *timeStampPicker;
@property (copy) void (^dismissViewControllerCallback)(NSManagedObject *);

- (IBAction)cancelNewCheck:(id)sender;
- (IBAction)commitNewCheck:(id)sender;
- (void)titleFieldEditingDidBegin;
- (void)setTitleAndTimeStampFromControls;

@end
