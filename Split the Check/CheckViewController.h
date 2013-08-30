//
//  CheckViewController.h
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/30/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckViewController : UITableViewController <UITextFieldDelegate>

@property bool showDatePicker;
@property NSManagedObject *check;
@property NSString *checkTitle;
@property NSDate *checkTimeStamp;
@property (weak) NSFetchedResultsController *fetchedResultsController;
@property (weak) UITextField *titleTextField;
@property (weak) UILabel *timeStampLabel;
@property UIDatePicker *timeStampPicker;

- (void)setTitleAndTimeStampFromControls;
- (void)saveContext;

@end
