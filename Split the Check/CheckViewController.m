//
//  CheckViewController.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/30/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "CheckViewController.h"
#import "ItemViewController.h"
#import "Check.h"
#import "Item.h"

@interface CheckViewController ()

@property bool showDatePicker;
@property NSString *checkTitle;
@property NSDate *checkTimeStamp;
@property (weak) UITextField *titleTextField;
@property (weak) UILabel *timeStampLabel;
@property UIDatePicker *timeStampPicker;

- (void)setTitleAndTimeStampFromControls;
- (void)saveContext;

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
    [self setCheckTitle:self.check.title];
    [self setTitle:self.checkTitle];
    [self setCheckTimeStamp:self.check.timeStamp];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.showDatePicker ? 3 : 2;
    else if (section == 1)
        return self.check.items.count + (self.editing ? 0 : 1);
    else
        @throw @"Invalid Code Path";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NULL;
    else if (section == 1)
        return @"Items & Groups";
    else
        @throw @"Invalid Code Path";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0 && [indexPath indexAtPosition:1] == 2)
        return self.timeStampPicker.bounds.size.height;
    else
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL].bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([indexPath indexAtPosition:0] == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        switch ([indexPath indexAtPosition:1]) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"Title Cell" forIndexPath:indexPath];
                assert([cell.contentView.subviews[0] isKindOfClass:[UITextField class]]);
                [self setTitleTextField:cell.contentView.subviews[0]];
                [self.titleTextField addTarget:self action:@selector(setTitleAndTimeStampFromControls) forControlEvents:UIControlEventEditingChanged];
                [self.titleTextField setText:self.checkTitle];
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"TimeStamp Cell" forIndexPath:indexPath];
                assert([cell.contentView.subviews[1] isKindOfClass:[UILabel class]]);
                [self setTimeStampLabel:cell.contentView.subviews[1]];
                [self.timeStampLabel setText:[dateFormatter stringFromDate:self.checkTimeStamp]];
                break;
            case 2:
                cell = [[UITableViewCell alloc] init];
                [cell.contentView addSubview:self.timeStampPicker];
                assert([cell.contentView.subviews[0] isKindOfClass:[UIDatePicker class]]);
                break;
            default:
                break;
        }
        return cell;
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] < self.check.items.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Item Cell" forIndexPath:indexPath];
            Item *item = [self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]][[indexPath indexAtPosition:1]];
            [cell.textLabel setText:item.name];
            [cell.detailTextLabel setText:[item.amount description]];
            return cell;
        }
        else
            return [tableView dequeueReusableCellWithIdentifier:@"Add Cell" forIndexPath:indexPath];
    }
    else
        @throw @"Invalid Code Path";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0) {
        switch ([indexPath indexAtPosition:1]) {
            case 0:
                [self.titleTextField becomeFirstResponder];
                break;
            case 1:
                [self setShowDatePicker:!self.showDatePicker];
                if (self.showDatePicker) {
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.timeStampLabel setTextColor:self.timeStampLabel.tintColor];
                }
                else {
                    [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
                }
                break;
            default:
                break;
        }
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] == self.check.items.count) {
            Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.context];
            [self.check addItemsObject:item];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]] indexOfObject:item] inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView endUpdates];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[[self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]] indexOfObject:item] inSection:1] animated:true scrollPosition:UITableViewScrollPositionNone];
            [self performSegueWithIdentifier:@"OpenItem" sender:self];
        }
    }
    if ([indexPath indexAtPosition:0] != 0 || [indexPath indexAtPosition:1] != 0)
        [self.titleTextField resignFirstResponder];
    if (([indexPath indexAtPosition:0] != 0 || [indexPath indexAtPosition:1] != 1) && self.showDatePicker) {
        [self setShowDatePicker:false];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0)
        return false;
    else if ([indexPath indexAtPosition:0] == 1)
        return [indexPath indexAtPosition:1] < self.check.items.count;
    else
        @throw @"Invalid Code Path";
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (self.editing)
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpenItem"]) {
        ItemViewController *itemViewController = [segue destinationViewController];
        [itemViewController setContext:self.context];
        [itemViewController setItem:[self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]][[self.tableView.indexPathForSelectedRow indexAtPosition:1]]];
        [itemViewController setDeleteItemInCheckViewController:^{
            [self.tableView deleteRowsAtIndexPaths:@[self.tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationMiddle];
        }];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.titleTextField && self.showDatePicker) {
        [self setShowDatePicker:false];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.timeStampLabel setTextColor:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NULL].detailTextLabel.textColor];
    }
}

- (void)setTitleAndTimeStampFromControls
{
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

- (void)saveContext
{
    if (![self.checkTitle isEqualToString:@""]) {
        [self.check setTitle:self.checkTitle];
        [self setTitle:self.checkTitle];
    }
    else
        [self setCheckTitle:self.check.title];
    [self.check setTimeStamp:self.checkTimeStamp];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveContext];
}

- (void)dealloc
{
    [self.titleTextField removeFromSuperview];
    [self.timeStampLabel removeFromSuperview];
    [self.timeStampPicker removeFromSuperview];
    [self setTimeStampPicker:NULL];
}

@end
