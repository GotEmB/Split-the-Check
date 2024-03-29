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
    else if (section == 1) {
        return [[self.fetchedResultsController sections][0] numberOfObjects] + (self.editing ? 0 : 1);
    }
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
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"Title Cell" forIndexPath:indexPath];
                assert([cell.contentView.subviews[0] isKindOfClass:[UITextField class]]);
                [self setTitleTextField:cell.contentView.subviews[0]];
                [self.titleTextField addTarget:self action:@selector(setTitleAndTimeStampFromControls) forControlEvents:UIControlEventEditingChanged];
                [self.titleTextField setText:self.checkTitle];
                break;
            case 1:
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimeStamp Cell" forIndexPath:indexPath];
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
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] < self.check.items.count) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Item Cell" forIndexPath:indexPath];
            Item *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[indexPath indexAtPosition:1] inSection:0]];
            [cell.textLabel setText:item.name];
            [cell.detailTextLabel setText:[item.amount description]];
        }
        else
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Add Cell" forIndexPath:indexPath];
    }
    else
        @throw @"Invalid Code Path";
    return cell;
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
            [self saveContext];
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
    if (self.editing != editing) {
        [super setEditing:editing animated:animated];
        if (self.editing)
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        else
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/*
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.editButtonItem setTitle:@"Done"];
    [self.editButtonItem setStyle:UIBarButtonItemStyleDone];
    [self setTableViewInRowUpdate:true];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    for (int i = 0; i < self.check.items.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        [cell.contentView.subviews[0] resignFirstResponder];
        [cell.contentView.subviews[1] resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTableViewInRowUpdate:false];
    if (!self.rowDeletedInTableViewRowUpdate)
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.check.items.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self setRowDeletedInTableViewRowUpdate:false];
    [self.editButtonItem setTitle:@"Edit"];
    [self.editButtonItem setStyle:UIBarButtonItemStyleBordered];
}
 */

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Item *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[indexPath indexAtPosition:1] inSection:0]];
        [self.check removeItemsObject:item];
        [self.context deleteObject:item];
        [self saveContext];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.context]];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"check == %@", self.check]];
    [fetchRequest setReturnsObjectsAsFaults:false];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"Items"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    indexPath = [NSIndexPath indexPathForRow:[indexPath indexAtPosition:1] inSection:1];
    newIndexPath = [NSIndexPath indexPathForRow:[newIndexPath indexAtPosition:1] inSection:1];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            Item *item = [self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]][[indexPath indexAtPosition:1]];
            [cell.textLabel setText:item.name];
            [cell.detailTextLabel setText:[item.amount description]];
            break;
        }
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpenItem"]) {
        ItemViewController *itemViewController = [segue destinationViewController];
        [itemViewController setContext:self.context];
        [itemViewController setItem:[self.check.items sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:true]]][[self.tableView.indexPathForSelectedRow indexAtPosition:1]]];
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
