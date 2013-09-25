//
//  ItemViewController.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/1/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "ItemViewController.h"
#import "Item.h"
#import "Check.h"
#import "SubItem.h"
#import "UIView+RelatedData.h"

@interface ItemViewController ()

@property BOOL isGroup;
@property (weak) UISegmentedControl *isGroupControl;
@property (weak) UITextField *itemNameTextField;
@property (weak) UITextField *itemAmountTextField;
@property (copy) NSComparisonResult(^subitemsComparer)(SubItem *subItem1, SubItem *subItem2);
@property (readonly) NSArray *orderedSubItems;
@property BOOL tableViewInRowUpdate;
@property BOOL rowDeletedInTableViewRowUpdate;

- (void) itemDidChange:(UIControl *)control;
- (void) saveContext;
- (void) exitEditingMode;

@end

@implementation ItemViewController

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

    if ([self.item.name isEqualToString:@""])
        [self setTitle:@"New Item/Group"];
    else
        [self setTitle:self.item.name];
    [self setIsGroup:(self.item.subItems.count > 0)];
    [self setSubitemsComparer:^NSComparisonResult(SubItem *subItem1, SubItem *subItem2){
        if ((!subItem1.name || [subItem1.name isEqualToString:@""]) && (!subItem2.name || [subItem2.name isEqualToString:@""]))
            return [subItem1.objectID.URIRepresentation.absoluteString compare:subItem2.objectID.URIRepresentation.absoluteString];
        else if (!subItem1.name || [subItem1.name isEqualToString:@""])
            return NSOrderedDescending;
        else if (!subItem2.name || [subItem2.name isEqualToString:@""])
            return NSOrderedAscending;
        else
            return [subItem1.name compare:subItem2.name];
    }];
    [self setTableViewInRowUpdate:false];
    [self setRowDeletedInTableViewRowUpdate:false];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)orderedSubItems {
    return [self.item.subItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"" ascending:true comparator:self.subitemsComparer]]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.isGroup ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return 2;
    else if (section == 2 && self.isGroup)
        return self.item.subItems.count + (self.editing || (self.tableViewInRowUpdate && !self.rowDeletedInTableViewRowUpdate) ? 0 : 1);
    else
        @throw @"Invalid Code Path";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < 2)
        return NULL;
    else if (section == 2 && self.isGroup)
        return @"Subitems";
    else
        @throw @"Invalid Code Path";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([indexPath indexAtPosition:0] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Group? Cell" forIndexPath:indexPath];
        [self setIsGroupControl:cell.contentView.subviews[0]];
        [self.isGroupControl setSelectedSegmentIndex:(self.isGroup ? 1 : 0)];
        [self.isGroupControl addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ItemName Cell" forIndexPath:indexPath];
            [self setItemNameTextField:cell.contentView.subviews[0]];
            [self.itemNameTextField setText:self.item.name];
            [self.itemNameTextField setDelegate:self];
            [self.itemNameTextField addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventEditingChanged];
            return cell;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ItemAmount Cell" forIndexPath:indexPath];
            [self setItemAmountTextField:cell.contentView.subviews[1]];
            [self.itemAmountTextField setText:[self.item.amount description]];
            [self.itemAmountTextField setDelegate:self];
            [self.itemAmountTextField addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventEditingChanged];
            return cell;
        }
    }
    else if ([indexPath indexAtPosition:0] == 2 && self.isGroup) {
        if ([indexPath indexAtPosition:1] < self.item.subItems.count) {
            SubItem *subItem = self.orderedSubItems[[indexPath indexAtPosition:1]];
            cell = [tableView dequeueReusableCellWithIdentifier:@"SubItem Cell" forIndexPath:indexPath];
            [cell.contentView.subviews[0] addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView.subviews[1] addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView.subviews[0] setText:subItem.name];
            [cell.contentView.subviews[1] setText:[subItem.amount description]];
            [cell.contentView.subviews[0] setDelegate:self];
            [cell.contentView.subviews[1] setDelegate:self];
            [cell.contentView.subviews[0] setRelatedData:subItem.objectID];
            [cell.contentView.subviews[1] setRelatedData:subItem.objectID];
            return cell;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Add Cell" forIndexPath:indexPath];
            return cell;
        }
    }
    else
        @throw @"Invalid Code Path";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] == 0)
            [self.itemNameTextField becomeFirstResponder];
        else if ([indexPath indexAtPosition:1] == 1)
            [self.itemAmountTextField becomeFirstResponder];
    }
    else if ([indexPath indexAtPosition:0] == 2 && self.isGroup) {
        if ([indexPath indexAtPosition:1] == self.item.subItems.count) {
            [self resignFirstResponder];
            SubItem *subItem = [NSEntityDescription insertNewObjectForEntityForName:@"SubItem" inManagedObjectContext:self.context];
            [self.item addSubItemsObject:subItem];
            [self saveContext];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.orderedSubItems indexOfObject:subItem] inSection:2];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self.tableView cellForRowAtIndexPath:newIndexPath].contentView.subviews[0] becomeFirstResponder];
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 2 && self.isGroup && [indexPath indexAtPosition:1] < self.item.subItems.count)
        return true;
    else
        return false;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.editing != editing) {
        if (editing && self.editButtonItem.style == UIBarButtonItemStyleDone && self.isGroup)
            [super setEditing:false animated:animated];
        else {
            [super setEditing:editing animated:animated];
            if (self.isGroup) {
                if (editing) {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.item.subItems.count inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    for (int i = 0; i < self.item.subItems.count; i++) {
                        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
                        [cell.contentView.subviews[0] resignFirstResponder];
                        [cell.contentView.subviews[1] resignFirstResponder];
                    }
                }
                else {
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.item.subItems.count inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.editButtonItem setTitle:@"Done"];
    [self.editButtonItem setStyle:UIBarButtonItemStyleDone];
    [self setTableViewInRowUpdate:true];
    if (self.isGroup) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.item.subItems.count inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        for (int i = 0; i < self.item.subItems.count; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
            [cell.contentView.subviews[0] resignFirstResponder];
            [cell.contentView.subviews[1] resignFirstResponder];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTableViewInRowUpdate:false];
    if (!self.rowDeletedInTableViewRowUpdate)
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.item.subItems.count inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [self setRowDeletedInTableViewRowUpdate:false];
    [self.editButtonItem setTitle:@"Edit"];
    [self.editButtonItem setStyle:UIBarButtonItemStyleBordered];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        SubItem *subItem = self.orderedSubItems[[indexPath indexAtPosition:1]];
        [self.item removeSubItemsObject:subItem];
        [self.context deleteObject:subItem];
        [self saveContext];
        [self.tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.tableViewInRowUpdate) {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.item.subItems.count inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self setRowDeletedInTableViewRowUpdate:true];
        }
        [self.tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableVew:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.isGroup) {
        if (textField == self.itemAmountTextField)
            return false;
        else if ([textField.relatedData isKindOfClass:[NSManagedObjectID class]] && [[self.context objectWithID:textField.relatedData] isKindOfClass:[SubItem class]]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.orderedSubItems indexOfObject:[self.context objectWithID:textField.relatedData]] inSection:2]];
            if (self.editing)
                return false;
            else if (textField == cell.contentView.subviews[1] && [[cell.contentView.subviews[0] text] isEqualToString:@""])
                return false;
        }
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.itemNameTextField) {
        [self.item setName:self.itemNameTextField.text];
        [self setTitle:self.item.name];
        [self saveContext];
    }
    else if (textField == self.itemAmountTextField) {
        [self.item setAmount:[NSDecimalNumber decimalNumberWithString:self.itemAmountTextField.text]];
        if ([self.item.amount isEqualToNumber:[NSDecimalNumber notANumber]])
            [self.item setAmount:[NSDecimalNumber zero]];
        [self.itemAmountTextField setText:[self.item.amount description]];
        [self saveContext];
    }
    else
    if (self.isGroup) {
        if ([textField.relatedData isKindOfClass:[NSManagedObjectID class]] && [[self.context objectWithID:textField.relatedData] isKindOfClass:[SubItem class]]) {
            SubItem *subItem = (SubItem *)[self.context objectWithID:textField.relatedData];
            if (!subItem || subItem.isFault)
                return;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.orderedSubItems indexOfObject:subItem] inSection:2];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.contentView.subviews[0] == textField)
                [subItem setName:textField.text];
            else if (cell.contentView.subviews[1] == textField) {
                [subItem setAmount:[NSDecimalNumber decimalNumberWithString:textField.text]];
                if ([subItem.amount isEqualToNumber:[NSDecimalNumber notANumber]])
                    [subItem setAmount:[NSDecimalNumber zero]];
                [textField setText:[subItem.amount description]];
                [self.item setAmount:[[self.item.subItems valueForKey:@"amount"] valueForKeyPath:@"@sum.floatValue"]];
                [self.itemAmountTextField setText:[self.item.amount description]];
            }
            if (!subItem.name || [subItem.name isEqualToString:@""]) {
                [self.item removeSubItemsObject:subItem];
                [self.context deleteObject:subItem];
                [self saveContext];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                [self saveContext];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.orderedSubItems indexOfObject:subItem] inSection:2];
                if ([newIndexPath compare:indexPath] != NSOrderedSame)
                    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Delete SubItems"]) {
        if ([alertView cancelButtonIndex] != buttonIndex) {
            [self setIsGroup:false];
            [self.isGroupControl setSelectedSegmentIndex:0];
            for (SubItem *subItem in [NSSet setWithSet:self.item.subItems]) {
                [self.item removeSubItemsObject:subItem];
                [self.context deleteObject:subItem];
            }
            [self saveContext];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)itemDidChange:(UIControl *)control
{
    if (control == self.isGroupControl) {
        BOOL oldIsGroup = self.isGroup;
        [self setIsGroup:(self.isGroupControl.selectedSegmentIndex == 1)];
        if (oldIsGroup != self.isGroup) {
            [self.tableView beginUpdates];
            if (self.isGroup) {
                [self.itemAmountTextField resignFirstResponder];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.item setAmount:[NSDecimalNumber zero]];
                [self.itemAmountTextField setText:[self.item.amount description]];
            }
            else {
                if (self.item.subItems.count > 0) {
                    [self setIsGroup:true];
                    [self.isGroupControl setSelectedSegmentIndex:1];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete SubItems" message:@"Switching to Total Amount will delete all existing SubItems. Are you sure you want to do this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
                }
                else
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView endUpdates];
        }
    }
    [self saveContext];
}

- (void)exitEditingMode
{
    [self setEditing:false animated:true];
}

- (void)saveContext
{
    NSError *error;
    if (![self.context save:&error]) {
        abort();
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.item.name) {
        [self.item.check removeItemsObject:self.item];
        [self.item.managedObjectContext deleteObject:self.item];
    }
    [self saveContext];
}

@end
