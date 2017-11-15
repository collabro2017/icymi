//
//  OMOtherProfileViewController.m
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMOtherProfileViewController.h"
#import "UIScrollView+TwitterCover.h"
#import "OMDetailEventViewController.h"

#import "OMProfileBioCell.h"
#import "OMCustomProfileInfoView.h"
#import "OMFriendCell.h"
#import "OMChangeTypeCell.h"
#import "OMEventListCell.h"
#import "OMProfileInfoCell.h"
#import "OMFolderListCell.h"

typedef enum {
    
    TableRowsEvent = 0,
    TableRowsFriend,
    TableRowsFavorite
    
} TableRows;

@interface OMOtherProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrForPhoto;
    NSMutableArray *arrForEvent;
    NSMutableArray *arrForProfileInfo;
    NSMutableArray *arrForFollowers;
    NSMutableArray *arrForFollowings;
    
    OMCustomProfileInfoView *avatarView;
}

@end

@implementation OMOtherProfileViewController
@synthesize is_type,targetUser, userType, isPrivate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrForProfileInfo   = [NSMutableArray array];
    arrForEvent         = [NSMutableArray array];
    arrForPhoto         = [NSMutableArray array];
    arrForFollowers     = [NSMutableArray array];
    arrForFollowings    = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    
    
    NSArray *arr        = [[NSBundle mainBundle] loadNibNamed:@"OMCustomProfileInfoView" owner:self options:nil];
    avatarView          = [arr lastObject];
    [avatarView setDelegate:self];
    [avatarView setUser:targetUser];
    
    [tblForOtherProfile addTwitterCoverWithImage:[UIImage imageNamed:@"cover.png"] withTopView:nil withBottomView:avatarView];
    
    tblForOtherProfile.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tblForOtherProfile.frame.size.width, CHTwitterCoverViewHeight + 93)];
    
    if (!isPrivate)
    {
    [self loadEvents];
    [self loadFollowings];
        [_lblPrivateDesc setHidden:YES];
    }
    else{
        [_lblPrivateDesc setHidden:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadEvents
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"user" equalTo:targetUser];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    //[mainQuery fromLocalDatastore];
    //    [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:targetUser];
    //    [mainQuery whereKey:@"PostType" equalTo:@"event"];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            
            //            [OMGlobal showAlertTips:@"You have had not any following yet. Please post new one." title:nil];
            
            
            return;
        }
        if (!error) {
            [arrForEvent removeAllObjects];
            //            [arrForPhoto removeAllObjects];
            
            [arrForEvent addObjectsFromArray:objects];
            [tblForOtherProfile reloadData];
        }
    }];
    
}


- (void)loadFollowings
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    
//    [query whereKey:@"ToUser" equalTo:targetUser];
    [query whereKey:@"FromUser" equalTo:targetUser];
    [query includeKey:@"ToUser"];
    [query includeKey:@"FromUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [arrForFollowings removeAllObjects];
            for (PFObject *object in objects) {
                if ([[object objectForKey:@"ToUser"] isKindOfClass:[PFUser class]]) {
                    PFUser *toUser1 = (PFUser *)object[@"ToUser"];
                    BOOL found = NO;
                    for (PFObject *obj in arrForFollowings) {
                        if ([[obj objectForKey:@"ToUser"] isKindOfClass:[PFUser class]]) {
                            PFUser *toUser2 = (PFUser *)obj[@"ToUser"];
                            if ([toUser1.objectId isEqualToString:toUser2.objectId]) {
                                found = YES;
                                break;
                            }
                        }
                    }
                    if (!found) {
                        [arrForFollowings addObject:object];
                    }
                }
            }
            [tblForOtherProfile reloadData];
        }
    }];
}

- (void)follow:(PFUser *)_user
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    
    if ([arrForFollowers count] > 0) {
        PFObject *object = [arrForFollowers objectAtIndex:0];
        
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self loadFollowings];
            }
        }];
        
    }
    else
    {
        PFObject *obj = [PFObject objectWithClassName:@"Follower"];
        
        obj[@"FromUser"] = USER;
        obj[@"ToUser"] = _user;
        
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (succeeded) {
                [self loadFollowings];
            }
        }];
        
    }
    
    
}

- (void)addFriendMainUser:(NSNumber *)_bool
{
    BOOL isFriend = [_bool boolValue];
    
    
    if (isFriend) {
        
        PFQuery *queryForUnfollow = [PFQuery queryWithClassName:kClassFollower];
        
        [queryForUnfollow whereKey:@"FromUser" equalTo:USER];
        [queryForUnfollow whereKey:@"ToUser" equalTo:targetUser];
        
        [queryForUnfollow findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                for (PFObject *obj in objects) {
                    
                    
                    [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            
                            [avatarView changeButtonState:YES];

                        }
                        else
                        {
                            
                            [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                            
                        }
                    }];
                }
            }
            
            
        }];

    }
    else
    {
        //add Friend
        PFObject *obj = [PFObject objectWithClassName:@"Follower"];
        obj[@"FromUser"] = USER;
        obj[@"ToUser"] = targetUser;
        
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                [avatarView changeButtonState:YES];
            
            }
            else
            {
                
                [avatarView changeButtonState:NO];
                
                [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
            }
        }];

    }
}

- (void)addFriend:(NSDictionary *)_dic {
    
    PFUser *tempUser = [_dic objectForKey:@"user"];
    BOOL isFriend = [((NSNumber *)[_dic objectForKey:@"isFriend"]) boolValue];
    NSInteger tempIndex = [(NSNumber *)[_dic objectForKey:@"index"] integerValue];
    BOOL searchMode = [(NSNumber *)[_dic objectForKey:@"searchMode"] boolValue];
    OMFriendCell *cell = (OMFriendCell *)[_dic objectForKey:@"cell"];
    
    if (searchMode) {
        
        // Search TableView
        if (isFriend) {
            
            // remove friend --- unfollow
            if (tempIndex >= 0) {
                [cell animateIndicatorView:YES];
                
                PFQuery *queryForUnfollow = [PFQuery queryWithClassName:kClassFollower];
                
                [queryForUnfollow whereKey:@"FromUser" equalTo:USER];
                [queryForUnfollow whereKey:@"ToUser" equalTo:tempUser];
                
                [queryForUnfollow findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [cell animateIndicatorView:NO];
                    
                    if (!error) {
                        
                        for (PFObject *obj in objects) {
                            
                            
                            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                if (succeeded) {
                                    [cell changeButtonState:YES];
                                    
                                    //[tblForOtherProfile reloadData];
                                    
                                } else {
                                    [cell changeButtonState:NO];
                                    
                                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                                    
                                }
                            }];
                        }
                    }
                }];
            }
        } else {
            
            //add Friend
            PFObject *obj = [PFObject objectWithClassName:@"Follower"];
            obj[@"FromUser"] = USER;
            obj[@"ToUser"] = tempUser;
            
            [cell animateIndicatorView:YES];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [cell animateIndicatorView:NO];
                if (succeeded) {
                    
                    [cell changeButtonState:YES];
                    
                    PFObject *_obj = [arrForFollowings objectAtIndex:tempIndex];
                    
                    [_obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        [tblForOtherProfile reloadData];
                        
                    }];
                    
                } else {
                    [cell animateIndicatorView:NO];
                    
                    [cell changeButtonState:NO];
                    
                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                }
            }];
        }
    }
}

- (void)changeType:(NSNumber*)_type
{
    is_type = [_type integerValue];
    

    [tblForOtherProfile reloadData];
    
//    [tblForOtherProfile beginUpdates];
//
//    [tblForOtherProfile reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [tblForOtherProfile endUpdates];
}

#pragma mark - Cell delegate


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows)is_type) {
        case TableRowsEvent:
        {
            OMEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventListCell];
            
            if (!cell) {
                cell = [[OMEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventListCell];
            }
            
            [cell setDelegate:self];
            [cell setObject:[arrForEvent objectAtIndex:indexPath.row]];
            
            return cell;
        }
            break;
        case TableRowsFriend:
        {
            OMFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCell];
            
            if (!cell) {
                cell = [[OMFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
            }
            
            [cell setDelegate:self];
            [cell setCurrentObj:[arrForFollowings objectAtIndex:indexPath.row] ofProfileView:YES];
            return cell;
//
//            Info
//            
//            OMProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileInfoCell];
//            
//            if (!cell) {
//                
//                cell = [[OMProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileInfoCell];
//                
//            }
//            [cell setDelegate: self];
//            
//            [cell setUser:targetUser];
//            
//            return cell;
            
            
        }
            break;
        case TableRowsFavorite:
        {
            
            OMFolderListCell * cell = [tableView dequeueReusableCellWithIdentifier:kFolderListCell];
            
            if (!cell) {
                cell = [[OMFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFolderListCell];
            }
            
            //[cell setDelegate:self];
            //[cell setObject:[arrForFolder objectAtIndex:indexPath.row]];
            
            return cell;
            
            /*OMEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventListCell];
            
            if (!cell) {
                cell = [[OMEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventListCell];
            }
            
            [cell setDelegate:self];
            [cell setObject:[arrForEvent objectAtIndex:indexPath.row]];
            
            return cell;*/

        }
            break;
        default:
            break;
    }
    
    
    return nil;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    OMChangeTypeCell *view = [tableView dequeueReusableCellWithIdentifier:kChangeTypeCell];
//    
//    if (!view) {
//        
//        view = [[OMChangeTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChangeTypeCell];
//    }
//    
//    [view setDelegate: self];
//    
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch ((TableRows)is_type) {
        case TableRowsEvent:
        {
            
            return arrForEvent.count;
        }
            break;
        case TableRowsFriend:
        {
            return arrForFollowings.count;
        }
            break;
        case TableRowsFavorite:
        {
            return arrForEvent.count;
            
        }
            break;
        default:
            break;
    }
    
    return arrForEvent.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows)is_type) {
        case TableRowsEvent:
        {
            
            return 108;
        }
            break;
        case TableRowsFriend:
        {
            return 50;
        }
            break;
        case TableRowsFavorite:
        {
            return 108;
            
        }
            break;
        default:
            break;
    }
    
    return arrForEvent.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows)is_type) {
        case TableRowsEvent:
        {
            PFObject *eventObj = [arrForEvent objectAtIndex:indexPath.row];
            NSArray<NSString *> *tagFrnds = (NSArray<NSString *>*)eventObj[@"TagFriends"];
            if ([tagFrnds containsObject:USER.objectId]) {
                OMDetailEventViewController *detailEventVC = [self.storyboard
                                                              instantiateViewControllerWithIdentifier:@"DetailEventVC"];
                [detailEventVC setCurrentObject:[arrForEvent objectAtIndex:indexPath.row]];
                [self.navigationController pushViewController:detailEventVC animated:YES];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"Oh, You are not tagged by post owner." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
            }
        }
            break;
        case TableRowsFriend:
        {
        }
            break;
        case TableRowsFavorite:
        {
        }
            break;
        default:
            break;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 45;
//}
//
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    
    [self.navigationController setNavigationBarHidden:NO];

    [self.navigationController popViewControllerAnimated:YES];
}
@end
