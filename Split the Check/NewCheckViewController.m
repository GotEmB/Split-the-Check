//
//  NewCheckViewController.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 8/29/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "NewCheckViewController.h"

@interface NewCheckViewController ()

@end

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0 && [indexPath indexAtPosition:1] == 2)
        return self.showDatePicker == 2 ? 216 : 0;
    else
        return [[self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] sizeThatFits:self.view.bounds.size].height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showDatePicker > 0 ? 3 : 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 0 && [indexPath indexAtPosition:1] == 1) {
        if (self.showDatePicker == 0) {
            [self setShowDatePicker:1];
            [tableView reloadData];
        }
        [self setShowDatePicker:(self.showDatePicker == 1 ? 2 : 1)];
        [tableView beginUpdates];
        [tableView endUpdates];
        if (self.showDatePicker == 5) {
            [self setShowDatePicker:0];
            [tableView reloadData];
        }
    }
}

- (IBAction)cancelNewCheck:(id)sender {
    [self dismissViewControllerAnimated:true completion:NULL];
}

@end
