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

@interface ItemViewController ()

@property BOOL isGroup;
@property (weak) UISegmentedControl *isGroupControl;
@property (weak) UITextField *itemNameTextField;
@property (weak) UITextField *itemAmountTextField;

- (void) itemDidChange;
- (void) saveContext;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return self.item.subItems.count; // + 1;
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
        [self.isGroupControl addTarget:self action:@selector(itemDidChange) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    else if ([indexPath indexAtPosition:0] == 1) {
        if ([indexPath indexAtPosition:1] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ItemName Cell" forIndexPath:indexPath];
            [self setItemNameTextField:cell.contentView.subviews[0]];
            [self.itemNameTextField setText:self.item.name];
            [self.itemNameTextField setDelegate:self];
            [self.itemNameTextField addTarget:self action:@selector(itemDidChange) forControlEvents:UIControlEventEditingChanged];
            return cell;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ItemAmount Cell" forIndexPath:indexPath];
            [self setItemAmountTextField:cell.contentView.subviews[1]];
            [self.itemAmountTextField setText:[self.item.amount description]];
            [self.itemAmountTextField setDelegate:self];
            [self.itemAmountTextField addTarget:self action:@selector(itemDidChange) forControlEvents:UIControlEventEditingChanged];
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
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
    if (textField == self.itemAmountTextField && self.isGroup)
        return false;
    else
        return true;
}

- (void)itemDidChange
{
    [self.item setName:self.itemNameTextField.text];
    [self.item setAmount:[NSDecimalNumber decimalNumberWithString:self.itemAmountTextField.text]];
    [self setIsGroup:(self.isGroupControl.selectedSegmentIndex == 1)];
    if (self.isGroup) [self.itemAmountTextField resignFirstResponder];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
