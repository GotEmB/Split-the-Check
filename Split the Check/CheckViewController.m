//
//  CheckViewController.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/30/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "CheckViewController.h"

@interface CheckViewController ()

@end

@implementation CheckViewController

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
    [self setCheckTitle:[self.check valueForKey:@"title"]];
    [self setTitle:self.checkTitle];
    [self setCheckTimeStamp:[self.check valueForKey:@"timeStamp"]];
    [self setTimeStampPicker:[[UIDatePicker alloc] init]];
    [self.timeStampPicker addTarget:self action:@selector(setTitleAndTimeStampFromControls) forControlEvents:UIControlEventValueChanged];
    [self.timeStampPicker setDate:self.checkTimeStamp];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    if ([indexPath indexAtPosition:0] == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        UITableViewCell *cell;
        switch ([indexPath indexAtPosition:1]) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"Title Cell" forIndexPath:indexPath];
                assert([[cell.contentView.subviews objectAtIndex:0] isKindOfClass:[UITextField class]]);
                [self setTitleTextField:[cell.contentView.subviews objectAtIndex:0]];
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
    @throw @"Method Not Implemented";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0) {
        if (!self.tableView.editing) return;
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
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing) {
        if ([self.titleTextField isFirstResponder]) [self.titleTextField resignFirstResponder];
        if (self.showDatePicker) {
            [self setShowDatePicker:false];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView endUpdates];
            [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
        }
        [self saveContext];
    }
    else {
        [self.titleTextField becomeFirstResponder];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0) {
        return false;
    }
    return true;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.titleTextField) {
        return self.tableView.editing;
    }
    return true;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleTextField && self.showDatePicker) {
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

- (void)saveContext {
    if (![self.checkTitle isEqualToString:@""]) {
        [self.check setValue:self.checkTitle forKey:@"title"];
        [self setTitle:self.checkTitle];
    }
    else
        [self setCheckTitle:[self.check valueForKey:@"title"]];
    [self.check setValue:self.checkTimeStamp forKey:@"timeStamp"];
    
    NSError *error;
    if (![self.fetchedResultsController.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveContext];
}

- (void)dealloc {
    [self.titleTextField removeFromSuperview];
    [self.timeStampLabel removeFromSuperview];
    [self.timeStampPicker removeFromSuperview];
    [self setTimeStampPicker:NULL];
}

@end
