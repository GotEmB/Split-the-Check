//
//  NewCheckViewController.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/29/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "NewCheckViewController.h"

@implementation NewCheckViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setShowDatePicker:false];
    [self setCheckTimeStamp:[NSDate date]];
    [self setTimeStampPicker:[[UIDatePicker alloc] init]];
    [self.timeStampPicker addTarget:self action:@selector(setTitleAndTimeStampFromControls) forControlEvents:UIControlEventValueChanged];
    [self.timeStampPicker setDate:self.checkTimeStamp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showDatePicker ? 3 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:1] == 2)
        return self.timeStampPicker.bounds.size.height;
    else
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL].bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    UITableViewCell *cell;
    switch ([indexPath indexAtPosition:1]) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Title Cell" forIndexPath:indexPath];
            assert([[cell.contentView.subviews objectAtIndex:0] isKindOfClass:[UITextField class]]);
            [self setTitleTextField:[cell.contentView.subviews objectAtIndex:0]];
            [self.titleTextField addTarget:self action:@selector(titleFieldEditingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
            [self.titleTextField addTarget:self action:@selector(setTitleAndTimeStampFromControls) forControlEvents:UIControlEventEditingChanged];
            [self.titleTextField setText:self.checkTitle];
            [self.titleTextField becomeFirstResponder];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TimeStamp Cell" forIndexPath:indexPath];
            assert([[cell.contentView.subviews objectAtIndex:1] isKindOfClass:[UILabel class]]);
            [self setTimeStampLabel:[cell.contentView.subviews objectAtIndex:1]];
            [self.timeStampLabel setText:[dateFormatter stringFromDate:self.checkTimeStamp]];
            break;
        case 2:
            cell = [[UITableViewCell alloc] init];
            [cell.contentView addSubview:self.timeStampPicker];
            assert([[cell.contentView.subviews objectAtIndex:0] isKindOfClass:[UIDatePicker class]]);
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:1]) {
        case 0:
            [self.titleTextField becomeFirstResponder];
            break;
        case 1:
            [self.titleTextField resignFirstResponder];
            [self setShowDatePicker:!self.showDatePicker];
            if (self.showDatePicker) {
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
                [tableView endUpdates];
                [self.timeStampLabel setTextColor:self.timeStampLabel.tintColor];
            }
            else {
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
                [tableView endUpdates];
                [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
            }
            break;
        default:
            break;
    }
}

- (IBAction)cancelNewCheck:(id)sender {
    self.dismissViewControllerCallback(NULL);
}

- (IBAction)commitNewCheck:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newCheck = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newCheck setValue:self.checkTitle forKey:@"title"];
    [newCheck setValue:self.checkTimeStamp forKey:@"timeStamp"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.dismissViewControllerCallback(newCheck);
}

- (void)titleFieldEditingDidBegin {
    if (self.showDatePicker) {
        [self setShowDatePicker:false];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
    }
}

- (void)setTitleAndTimeStampFromControls {
    if (self.titleTextField)
        [self setCheckTitle:self.titleTextField.text];
    if (self.timeStampPicker) {
        [self setCheckTimeStamp:self.timeStampPicker.date];
        if (self.timeStampLabel) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [self.timeStampLabel setText:[dateFormatter stringFromDate:self.checkTimeStamp]];
        }
    }
}

- (void)dealloc {
    [self.titleTextField removeFromSuperview];
    [self.timeStampLabel removeFromSuperview];
    [self.timeStampPicker removeFromSuperview];
    [self setTimeStampPicker:NULL];
}

@end
