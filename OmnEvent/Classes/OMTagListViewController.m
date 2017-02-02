//
//  OMTagListViewController.m
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMTagListViewController.h"
#import "OMTagFriendCell.h"

@interface OMTagListViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView *invitationPicker;
    UIView *custominvitationPickerView;
    CGRect rectForCustomPickerView;
    BOOL isPickerViewAlreadyOpened;
    NSString *AuthorityValue;
    
    NSMutableArray *fullUsers;
    NSMutableArray *viewOnlyUsers;
    NSMutableArray *commentOnlyUsers;
    NSIndexPath *selectedIndex;
}

@end

@implementation OMTagListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrForFriend = [NSMutableArray array];
    fullUsers = [NSMutableArray array];
    viewOnlyUsers = [NSMutableArray array];
    commentOnlyUsers = [NSMutableArray array];
    selectedIndex = nil;
    // Do any additional setup after loading the view.
    
    [self initializeControls];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];
    self.title = @"Tag Friends";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeControls
{
    custominvitationPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 200, self.view.frame.size.width, 150 + 40  )];
    
    rectForCustomPickerView = custominvitationPickerView.frame;
    
    invitationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 150)];
    invitationPicker.delegate = self;
    [invitationPicker setBackgroundColor:[UIColor lightGrayColor]];
    [custominvitationPickerView addSubview:invitationPicker];
    
    UIToolbar *doneToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar.barStyle = UIBarStyleDefault;
    
    doneToolBar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissPickerView)], nil];
    
    [doneToolBar sizeToFit];
    
    [custominvitationPickerView addSubview:doneToolBar];
    
    [self.navigationController.view addSubview:custominvitationPickerView];
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectedCells:didFinished:)]) {
        NSMutableArray *finalList = [NSMutableArray array];
        [finalList addObject:fullUsers];
        [finalList addObject:viewOnlyUsers];
        [finalList addObject:commentOnlyUsers];
        [self.delegate selectedCells:self didFinished:finalList];
    }
}


- (void)loadFriends
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
    [mainQ whereKey:@"FromUser" equalTo:USER];
    [mainQ includeKey:@"FromUser"];
    [mainQ includeKey:@"ToUser"];
    [mainQ orderByDescending:@"createdAt"];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if (objects == nil || [objects count] == 0) {
            return;
        }
        
        if (!error) {
            NSMutableArray *strUserObjectIds = [[NSMutableArray alloc] init];
            [arrForFriend removeAllObjects];
            
            for (PFObject *obj in objects) {
                if (obj[@"ToUser"]) {
                    PFUser *user = obj[@"ToUser"];
                    if (![user.objectId isEqualToString:USER.objectId] && ![strUserObjectIds containsObject:user.objectId]) {
                        [strUserObjectIds addObject:user.objectId];
                        [arrForFriend addObject:user];
                    }
                }
            }            
            [strUserObjectIds removeAllObjects];
            strUserObjectIds = nil;
            [tblForFriendList reloadData];
        }
    }];
}

- (void)showPickerView
{
    [UIView animateWithDuration:0.2f animations:^{
        [custominvitationPickerView setFrame:CGRectMake(custominvitationPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - custominvitationPickerView.frame.size.height, custominvitationPickerView.frame.size.width, custominvitationPickerView.frame.size.height)];
        isPickerViewAlreadyOpened = YES;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)doneButtonClikedDismissPickerView {
    if (AuthorityValue == nil || [AuthorityValue isEqualToString:@""]){
        AuthorityValue = @"Full";
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [custominvitationPickerView setFrame:rectForCustomPickerView];
        isPickerViewAlreadyOpened = NO;
    } completion:^(BOOL finished) {
        
    }];
    
    if (selectedIndex.section == 0) {
        if ([AuthorityValue isEqualToString:@"View Only"]) {
            PFUser *user = (PFUser *)[fullUsers objectAtIndex:selectedIndex.row];
            [fullUsers removeObjectAtIndex:selectedIndex.row];
            [viewOnlyUsers addObject:user];
        }
        else if ([AuthorityValue isEqualToString:@"Comment Only"]) {
            PFUser *user = (PFUser *)[fullUsers objectAtIndex:selectedIndex.row];
            [fullUsers removeObjectAtIndex:selectedIndex.row];
            [commentOnlyUsers addObject:user];
        }
    }
    else if (selectedIndex.section == 1) {
        if ([AuthorityValue isEqualToString:@"Full"]) {
            PFUser *user = (PFUser *)[viewOnlyUsers objectAtIndex:selectedIndex.row];
            [viewOnlyUsers removeObjectAtIndex:selectedIndex.row];
            [fullUsers addObject:user];
        }
        else if ([AuthorityValue isEqualToString:@"Comment Only"]) {
            PFUser *user = (PFUser *)[viewOnlyUsers objectAtIndex:selectedIndex.row];
            [viewOnlyUsers removeObjectAtIndex:selectedIndex.row];
            [commentOnlyUsers addObject:user];
        }
    }
    else if (selectedIndex.section == 2) {
        if ([AuthorityValue isEqualToString:@"Full"]) {
            PFUser *user = (PFUser *)[commentOnlyUsers objectAtIndex:selectedIndex.row];
            [commentOnlyUsers removeObjectAtIndex:selectedIndex.row];
            [fullUsers addObject:user];
        }
        else if ([AuthorityValue isEqualToString:@"View Only"]) {
            PFUser *user = (PFUser *)[commentOnlyUsers objectAtIndex:selectedIndex.row];
            [commentOnlyUsers removeObjectAtIndex:selectedIndex.row];
            [viewOnlyUsers addObject:user];
        }
    }
    else {
        if ([AuthorityValue isEqualToString:@"Full"]) {
            PFUser *user = (PFUser *)[arrForFriend objectAtIndex:selectedIndex.row];
            [arrForFriend removeObjectAtIndex:selectedIndex.row];
            [fullUsers addObject:user];
        }
        else if ([AuthorityValue isEqualToString:@"View Only"]) {
            PFUser *user = (PFUser *)[arrForFriend objectAtIndex:selectedIndex.row];
            [arrForFriend removeObjectAtIndex:selectedIndex.row];
            [viewOnlyUsers addObject:user];
        }
        else if ([AuthorityValue isEqualToString:@"Comment Only"]) {
            PFUser *user = (PFUser *)[arrForFriend objectAtIndex:selectedIndex.row];
            [arrForFriend removeObjectAtIndex:selectedIndex.row];
            [commentOnlyUsers addObject:user];
        }
    }
    
    [tblForFriendList reloadData];
}

#pragma mark UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [fullUsers count];
    } else if (section == 1) {
        return [viewOnlyUsers count];
    } else if (section == 2) {
        return [commentOnlyUsers count];
    }
    return [arrForFriend count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Full";
    } else if (section == 1) {
        return @"View Only";
    } else if (section == 2) {
        return @"Comment Only";
    }
    return @"Other Friends";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagFriendCell";
    OMTagFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[OMTagFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        [cell setObject:[fullUsers objectAtIndex:indexPath.row]];
    }
    else if (indexPath.section == 1) {
        [cell setObject:[viewOnlyUsers objectAtIndex:indexPath.row]];
    }
    else if (indexPath.section == 2) {
        [cell setObject:[commentOnlyUsers objectAtIndex:indexPath.row]];
    }
    else {
        [cell setObject:[arrForFriend objectAtIndex:indexPath.row]];
    }
    
    cell.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isPickerViewAlreadyOpened == YES) {
        return;
    }
    selectedIndex = indexPath;
    [self showPickerView];
    [tableView reloadData];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"Full";
            break;
        case 1:
            return @"View Only";
            break;
        case 2:
            return @"Comment Only";
            break;
            
        default:
            break;
    }
    
    return nil;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (row) {
        case 0:
        {
            AuthorityValue = @"Full";
        }
            break;
        case 1:
        {
            AuthorityValue = @"View Only";
        }
            break;
        case 2:
        {
            AuthorityValue = @"Comment Only";
        }
            break;
            
        default:
            break;
    }
}

@end
