//
//  OMAdditionalTagViewController.m
//  Collabro
//
//  Created by XXX on 4/10/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMAdditionalTagViewController.h"
#import "OMTagFriendCell.h"

@interface OMAdditionalTagViewController ()<UIPickerViewDataSource,UIPickerViewDelegate> {
    
    NSMutableArray *arrForFriend;
    
    NSMutableArray *arrForMain;

    NSMutableArray *arrForTaggedFriend;
    
    NSMutableArray *arrForTaggedFriendAuthorities;
    
    NSMutableArray *cellSelected;
    NSMutableArray *arrForSelectedUser;
    
    UIPickerView *invitationPicker;
    UIView *custominvitationPickerView;
    CGRect rectForCustomPickerView;
    
    NSString *AuthorityValue;
}

@end

@implementation OMAdditionalTagViewController
@synthesize currentObject;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    arrForFriend = [NSMutableArray array];
    cellSelected = [NSMutableArray array];
    arrForSelectedUser = [NSMutableArray array];
    arrForTaggedFriend = [NSMutableArray array];
    arrForTaggedFriendAuthorities = [NSMutableArray array];
    arrForMain = [NSMutableArray array];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (currentObject[@"TagFriends"]) {
        arrForTaggedFriend = currentObject[@"TagFriends"];
    }
    
    if (arrForTaggedFriend != nil && arrForTaggedFriend.count > 0){
        
        if (currentObject[@"TagFriendAuthorities"]){
            
            arrForTaggedFriendAuthorities = currentObject[@"TagFriendAuthorities"];
            
            if (arrForTaggedFriend.count != arrForTaggedFriendAuthorities.count){
                arrForTaggedFriendAuthorities = [NSMutableArray array];
                for (NSUInteger i = 0; i < arrForTaggedFriend.count; i++){
                    [arrForTaggedFriendAuthorities addObject:@"Full"];
                }
            }
            
        } else {
            for (NSUInteger i = 0; i < arrForTaggedFriend.count; i++){
                [arrForTaggedFriendAuthorities addObject:@"Full"];
            }
        }
    }
    
    [self loadFriends];
}

- (void)cancel:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeControls {
    
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

- (void)done:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(selectedCells:didFinished:)]) {
        [arrForMain addObject:arrForTaggedFriend];
        [arrForMain addObject:arrForTaggedFriendAuthorities];
        [self.delegate selectedCells:self didFinished:arrForMain];
    }
}

- (void)loadFriends {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
    [mainQ whereKey:@"FromUser" equalTo:USER];
    [mainQ includeKey:@"FromUser"];
    [mainQ includeKey:@"ToUser"];
    [mainQ orderByDescending:@"createdAt"];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            return ;
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
            
            
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrForFriend];
            NSArray *arr = [orderedSet array];
            [arrForFriend removeAllObjects];
            [arrForFriend addObjectsFromArray:arr];
            [tblForTagFriend reloadData];
        }
    }];
}

- (void)showPickerView {
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [custominvitationPickerView setFrame:CGRectMake(custominvitationPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - custominvitationPickerView.frame.size.height, custominvitationPickerView.frame.size.width, custominvitationPickerView.frame.size.height)];
        
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)doneButtonClikedDismissPickerView {
    
    if (AuthorityValue == nil || [AuthorityValue isEqualToString:@""]){
        AuthorityValue = @"Full";
    }
    
    [arrForTaggedFriendAuthorities addObject:AuthorityValue];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [custominvitationPickerView setFrame:rectForCustomPickerView];
        
    } completion:^(BOOL finished) {
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TagFriendCell";
    OMTagFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[OMTagFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    [cell setObject:[arrForFriend objectAtIndex:indexPath.row]];
    
    PFUser *user  = [arrForFriend objectAtIndex:indexPath.row];
    
    
    if ([arrForTaggedFriend containsObject:user.objectId]) {
        
        if (![cellSelected containsObject:indexPath]) {
            
            [cellSelected addObject:indexPath];
        }
    }
    else
    {
        
    }
   
    if ([cellSelected containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([cellSelected containsObject:indexPath]) {
        [cellSelected removeObject:indexPath];
        
        PFUser *user = (PFUser *)[arrForFriend objectAtIndex:indexPath.row];
        
        for (NSUInteger i = 0; i < arrForTaggedFriend.count ; i++){
            if ([user.objectId isEqualToString:[arrForTaggedFriend objectAtIndex:i]]){
                
                if([arrForTaggedFriendAuthorities count] > i)
                {
                    [arrForTaggedFriendAuthorities removeObjectAtIndex:i];
                }
                
                break;
            }
        }
        
        [arrForTaggedFriend removeObject:user.objectId];
        
    } else {
        
        [cellSelected addObject:indexPath];
        PFUser *user = (PFUser *)[arrForFriend objectAtIndex:indexPath.row];
        
        [arrForTaggedFriend addObject:user.objectId];
        
        [self showPickerView];
    }
    
    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForFriend count];
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
