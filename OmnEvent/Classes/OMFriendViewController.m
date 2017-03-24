//
//  OMFriendViewController.m
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFriendViewController.h"

#import "OMProfileViewController.h"

#import "OMFriendCell.h"
#import "OMOtherProfileViewController.h"

@interface OMFriendViewController ()
{
    NSMutableArray *arrForFriends;
    NSMutableArray *arrForPeople;
    NSMutableArray *arrForObjects;
    NSMutableArray *arrSearchString;
    BOOL isShowProfileOpened;
}

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OMFriendViewController

- (void)reload:(__unused id)sender
{
    if (!m_isViewDidLoad)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        m_isViewDidLoad = YES;
    }

    [(UIRefreshControl*)sender beginRefreshing];
    
    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
    
    [mainQ includeKey:@"FromUser"];
    [mainQ includeKey:@"ToUser"];
    [mainQ whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [(UIRefreshControl*)sender endRefreshing];
        
        if (error)
        {
            [OMGlobal showAlertTips:nil title:@"Error!"];
        }
        else
        {
            if (objects.count == 0)
            {
                NSLog(@"Not Found");
                
                [arrForFriends removeAllObjects];
                [arrForPeople removeAllObjects];
                [arrForObjects removeAllObjects];
                [tblForFriend reloadData];
                [tblForSearch reloadData];
            }
            else
            {
                [arrForFriends removeAllObjects];
                [arrForPeople removeAllObjects];
                [arrForObjects removeAllObjects];
                
                
                NSLog(@"Current USer = %@",USER);
                NSMutableArray *strUserObjectIds = [NSMutableArray array];
                
                for (PFObject *obj in objects)
                {
                    PFUser *user = (PFUser *)[obj objectForKey:@"FromUser"];
                    
                    if ([user.objectId isEqualToString:kIDOfCurrentUser] && !([[((PFUser *)obj[@"ToUser"]) objectForKey:@"visibility"] isEqualToString:@"Hidden"]))
                    {
                        if (obj[@"ToUser"])
                        {
                            [arrForObjects addObject:obj];
                            
                            //Fix issue for multiple friends
                            PFUser *user = obj[@"ToUser"];
                            if (![user.objectId isEqualToString:USER.objectId] && ![strUserObjectIds containsObject:user.objectId]) {
                                [strUserObjectIds addObject:user.objectId];
                                [arrForFriends addObject:user];
                            }
                        }
                    }
                }
                
                [strUserObjectIds removeAllObjects];
                strUserObjectIds = nil;
                
                NSMutableArray *tempArrForObjects = [NSMutableArray array];
                NSMutableArray *tempArrForFriends = [NSMutableArray array];
                
                for (PFObject *obj in arrForObjects)
                {
                    PFUser *user = (PFUser *)[obj objectForKey:@"ToUser"];
                    
                    for(PFObject *anotherObj in objects)
                    {
                        PFUser *anotherUser = (PFUser *)[anotherObj objectForKey:@"FromUser"];
                        
                        if (([anotherUser.objectId isEqualToString:user.objectId]) && !([((PFUser *)anotherObj[@"ToUser"]).objectId isEqualToString:kIDOfCurrentUser]))
                        {
                            BOOL isFound = NO;
                            BOOL isFoundMutalFriend = NO;
                            
                            for (PFUser *aUser in arrForFriends) {
                                if ([aUser.objectId isEqualToString:((PFUser *)anotherObj[@"ToUser"]).objectId]) {
                                    
                                    isFound = YES;
                                    break;
                                }
                            }
                            
                            for (PFUser *aUser in tempArrForFriends) {
                                if ([aUser.objectId isEqualToString:((PFUser *)anotherObj[@"ToUser"]).objectId]) {
                                    
                                    isFoundMutalFriend = YES;
                                    break;
                                }
                            }
                            
                            
                            if (!isFound && !isFoundMutalFriend && !([[((PFUser *)anotherObj[@"ToUser"]) objectForKey:@"visibility"] isEqualToString:@"Hidden"]))
                            {
                                if (anotherObj[@"ToUser"])
                                {
                                    [tempArrForObjects addObject:anotherObj];
                                    [tempArrForFriends addObject:anotherObj[@"ToUser"]];
                                }
                            }
                        }
                    }
                }
                
                [arrForObjects addObjectsFromArray:tempArrForObjects];
                [arrForFriends addObjectsFromArray:tempArrForFriends];
                
                //Apply Sorting
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES
                                                                        selector:@selector(caseInsensitiveCompare:)];
                [arrForFriends sortUsingDescriptors:@[sort]];
                
                [arrForObjects sortUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
                    PFUser *toUser1 = obj1[@"ToUser"];
                    PFUser *toUser2 = obj2[@"ToUser"];
                    return [toUser1.username caseInsensitiveCompare:toUser2.username];
                }];
                
                [tblForFriend reloadData];
            }
        }
    }];
}

- (void)reloadWithSearch
{
    if (!m_isViewDidLoad)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        m_isViewDidLoad = YES;
    }
    
    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
    
    [mainQ includeKey:@"FromUser"];
    [mainQ includeKey:@"ToUser"];
    [mainQ orderByDescending:@"username"];
    [mainQ whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         
         if (error)
         {
             [OMGlobal showAlertTips:nil title:@"Error!"];
         }
         else
         {
             if (objects.count == 0)
             {
                 NSLog(@"Not Found");
                 
                 [arrForFriends removeAllObjects];
                 [arrForPeople removeAllObjects];
                 [arrForObjects removeAllObjects];
                 [tblForFriend reloadData];
                 [tblForSearch reloadData];
             }
             else
             {
                 [arrForFriends removeAllObjects];
                 [arrForPeople removeAllObjects];
                 [arrForObjects removeAllObjects];
                 NSMutableArray *strUserObjectIds = [NSMutableArray array];
                 
                 for (PFObject *obj in objects)
                 {
                     NSLog(@"%@",[obj objectForKey:@"FromUser"]);
                     PFUser *user = (PFUser *)[obj objectForKey:@"FromUser"];
                     
                     if ([user.objectId isEqualToString:kIDOfCurrentUser] && !([[((PFUser *)obj[@"ToUser"]) objectForKey:@"visibility"] isEqualToString:@"Hidden"]))
                     {
                         //Fix issue for multiple friends
                         PFUser *user = obj[@"ToUser"];
                         if (![user.objectId isEqualToString:USER.objectId] && ![strUserObjectIds containsObject:user.objectId]) {
                             [strUserObjectIds addObject:user.objectId];
                             [arrForObjects addObject:obj];
                             [arrForFriends addObject:user];
                         }
                     }
                 }
                 
                 [strUserObjectIds removeAllObjects];
                 strUserObjectIds = nil;
                 
                 NSMutableArray *tempArrForObjects = [NSMutableArray array];
                 NSMutableArray *tempArrForFriends = [NSMutableArray array];
                 
                 for (PFObject *obj in arrForObjects)
                 {
                     PFUser *user = (PFUser *)[obj objectForKey:@"ToUser"];
                     
                     for(PFObject *anotherObj in objects)
                     {
                         PFUser *anotherUser = (PFUser *)[anotherObj objectForKey:@"FromUser"];
                         
                         if (([anotherUser.objectId isEqualToString:user.objectId]) && !([((PFUser *)anotherObj[@"ToUser"]).objectId isEqualToString:kIDOfCurrentUser]))
                         {
                             BOOL isFound = NO;
                             BOOL isFoundMutalFriend = NO;
                             
                             for (PFUser *aUser in arrForFriends) {
                                 if ([aUser.objectId isEqualToString:((PFUser *)anotherObj[@"ToUser"]).objectId]) {
                                     
                                     isFound = YES;
                                     break;
                                 }
                             }
                             
                             for (PFUser *aUser in tempArrForFriends) {
                                 if ([aUser.objectId isEqualToString:((PFUser *)anotherObj[@"ToUser"]).objectId]) {
                                     
                                     isFoundMutalFriend = YES;
                                     break;
                                 }
                             }
                             
                             if (!isFound && !isFoundMutalFriend && !([[((PFUser *)anotherObj[@"ToUser"]) objectForKey:@"visiblity"] isEqualToString:@"Hidden"]))
                             {
                                 if (anotherObj[@"ToUser"])
                                 {
                                     [tempArrForObjects addObject:anotherObj];
                                     [tempArrForFriends addObject:anotherObj[@"ToUser"]];
                                 }
                             }
                         }
                     }
                 }
                 
                 [arrForObjects addObjectsFromArray:tempArrForObjects];
                 [arrForFriends addObjectsFromArray:tempArrForFriends];
                 
                 //Apply Sorting
                 NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES
                                                                         selector:@selector(caseInsensitiveCompare:)];
                 [arrForFriends sortUsingDescriptors:@[sort]];
                 [arrForObjects sortUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
                     PFUser *toUser1 = obj1[@"ToUser"];
                     PFUser *toUser2 = obj2[@"ToUser"];
                     return [toUser1.username caseInsensitiveCompare:toUser2.username];
                 }];
                 
                 [tblForFriend reloadData];
                 
                 [arrForPeople addObjectsFromArray:arrForFriends];
                 
                 [tblForSearch reloadData];
             }
         }
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    arrForFriends = [NSMutableArray array];
    arrForPeople = [NSMutableArray array];
    arrForObjects = [NSMutableArray array];
    
    arrSearchString = [NSMutableArray array];
    
    isSearching = NO;
    m_isSearchContent = NO;
    m_isViewDidLoad = NO;
    
    self.title = @"Friends";
    //
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tblForFriend.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    [tblForFriend addSubview:self.refreshControl];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:kLoadFriendData object:nil];
    
    [self startTimer];
}

-(void)startTimer
{
    [self stopTimer];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if (m_timer != NULL)
    {
        [m_timer invalidate];
        m_timer = NULL;
    }
}

-(void)onTimer:(id)sender
{
    if ([arrSearchString count] == 0)
        return;
    
    if (!m_isSearchContent)
    {
        int nCount = [arrSearchString count];
        
        NSString* szSearch = [arrSearchString objectAtIndex:(nCount-1)];
        [self loadFriendsData:szSearch];
        
        [arrSearchString removeAllObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!isShowProfileOpened) {
        [self reload:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isShowProfileOpened = NO;
}

- (void)loadFriendsData:(NSString *)text
{
    if (m_isSearchContent)
        return;
    
    m_isSearchContent = YES;
    
    // city, state/province
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containsString:text];
    
    PFQuery *queryCapitalizedString = [PFUser query];
    [queryCapitalizedString whereKey:@"username" containsString:[text capitalizedString]];
    
    //query converted user text to lowercase
    PFQuery *queryLowerCaseString = [PFUser query];
    [queryLowerCaseString whereKey:@"username" containsString:[text lowercaseString]];
    
    //////
    
    PFQuery *queryForCity = [PFUser query];
    [queryForCity whereKey:@"City" containsString:text];
    
    PFQuery *queryForCityCapitalizedString = [PFUser query];
    [queryForCityCapitalizedString whereKey:@"City" containsString:[text capitalizedString]];
    
    //query converted user text to lowercase
    PFQuery *queryForCityLowerCaseString = [PFUser query];
    [queryForCityLowerCaseString whereKey:@"City" containsString:[text lowercaseString]];
    
    ///
    PFQuery *queryForState = [PFUser query];
    [queryForState whereKey:@"State" containsString:text];
    
    PFQuery *queryForStateCapitalizedString = [PFUser query];
    [queryForStateCapitalizedString whereKey:@"State" containsString:[text capitalizedString]];
    
    PFQuery *queryForStateUpperCaseString = [PFUser query];
    [queryForStateUpperCaseString whereKey:@"State" containsString:[text uppercaseString]];
    
    //query converted user text to lowercase
    PFQuery *queryForStateLowerCaseString = [PFUser query];
    [queryForStateLowerCaseString whereKey:@"State" containsString:[text lowercaseString]];
    
    PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query, queryCapitalizedString,queryLowerCaseString, queryForCity, queryForCityCapitalizedString, queryForCityLowerCaseString, queryForState, queryForStateCapitalizedString, queryForStateUpperCaseString, queryForStateLowerCaseString, nil]];
    
//    [finalQuery findObjectsInBackgroundWithTarget:self selector:@selector(searchPeopleWithResult:error:)];
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        m_isSearchContent = NO;
        if (!error) {
            
            [arrForPeople removeAllObjects];
            
            for (PFUser *aUser in objects) {
                NSString* strVisibility = [aUser objectForKey:@"visibility"];
                
                if (![strVisibility isEqualToString:@"Hidden"]) {
                    
                    [arrForPeople addObject:aUser];
                }
            }
            
            //Apply Sorting
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES
                                                                    selector:@selector(caseInsensitiveCompare:)];
            [arrForPeople sortUsingDescriptors:@[sort]];
            
            [tblForSearch reloadData];
        }
    }];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
        [self reloadWithSearch];
    else
        [arrSearchString addObject:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    isSearching = YES;
    
    [arrForPeople removeAllObjects];
    
    if ([searchBar.text isEqualToString:@""])
    {
        [arrForPeople addObjectsFromArray:arrForFriends];
        [tblForSearch reloadData];
    }
    else
    {
        [self loadFriendsData:searchBar.text];
    }
    
    [tblForSearch setHidden:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
//    [arrForPeople removeAllObjects];
//    [tblForSearch setHidden:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self loadFriendsData:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [searchBar setText:@""];
    isSearching = NO;
    [tblForSearch setHidden:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
    [arrForPeople removeAllObjects];
    [tblForSearch reloadData];
    
    [self reload:nil];
}
#pragma mark - Cell Delegate

- (void)showProfile:(NSMutableDictionary *)_dic
{
    NSString* strVisibility = @"Public";
    PFUser* aUser = (PFUser* )[_dic objectForKey:@"user"];
    
    if ([aUser objectForKey:@"visibility"])
        strVisibility = [aUser objectForKey:@"visibility"];
    
    NSInteger nUserType = [[_dic objectForKey:@"friendType"] integerValue];
    if ([strVisibility isEqualToString:@"Friend only"])
    {
        if (nUserType == 2)
        {
            isShowProfileOpened = YES;
            OMOtherProfileViewController *otherProfileVC = [self.storyboard
                                                            instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
            otherProfileVC.is_type = 0;
            otherProfileVC.userType = nUserType;
            [otherProfileVC setTargetUser:aUser];
            otherProfileVC.isPrivate = NO;
            [self.navigationController pushViewController:otherProfileVC animated:YES];
        }
        else
        {
            [OMGlobal showAlertTips:@"This profile is Friend only, you can't open it" title:@"Oops!"];
        }
    }
    else if ([strVisibility isEqualToString:@"Private"])
    {
        isShowProfileOpened = YES;
        OMOtherProfileViewController *otherProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
        otherProfileVC.is_type = 0;
        otherProfileVC.userType = nUserType;
        [otherProfileVC setTargetUser:aUser];
        otherProfileVC.isPrivate = YES;
        [self.navigationController pushViewController:otherProfileVC animated:YES];
    }
    else if ([strVisibility isEqualToString:@"Public"])
    {
        isShowProfileOpened = YES;
        OMOtherProfileViewController *otherProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
        otherProfileVC.is_type = 0;
        otherProfileVC.userType = nUserType;
        [otherProfileVC setTargetUser:aUser];
        otherProfileVC.isPrivate = NO;
        [self.navigationController pushViewController:otherProfileVC animated:YES];
    }
}

- (void)addFriend:(NSMutableDictionary *)_dic
{
    PFUser *tempUser = [_dic objectForKey:@"user"];    
    int friendType = [((NSNumber *)[_dic objectForKey:@"friendType"]) intValue];
    NSInteger tempIndex = [(NSNumber *)[_dic objectForKey:@"index"] integerValue];
    BOOL searchMode = [(NSNumber *)[_dic objectForKey:@"searchMode"] boolValue];
    
    OMFriendCell *cell = (OMFriendCell *)[_dic objectForKey:@"cell"];
    
    if (searchMode) {
        
        // Search TableView
        if (friendType == 2 ) {
            
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
                                    [self reload:nil];

                                }
                                else
                                {
                                    [cell changeButtonState:NO];
                                    
                                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                                }
                            }];
                        }
                    }
                }];
            }
        }else
        {
            
            //add Friend
            PFObject *obj = [PFObject objectWithClassName:@"Follower"];
            obj[@"FromUser"] = USER;
            obj[@"ToUser"] = tempUser;
            
            [cell animateIndicatorView:YES];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [cell animateIndicatorView:NO];
                if (succeeded) {
                    
                    [cell changeButtonState:YES];
                    
                    PFObject *_obj = [arrForPeople objectAtIndex:tempIndex];
                    
                    [_obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        [arrForFriends addObject:_obj];
                        [self reloadWithSearch];
                        //[tblForSearch reloadData];
                        
                    }];

                    
//                    [tblForSearch reloadData];
                }
                else
                {
                    [cell animateIndicatorView:NO];
                    
                    [cell changeButtonState:NO];
                    
                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                }
            }];
            
        }

    }
    else
    {
        
        //Friend TableView
        if (friendType == 2) {
            
            // remove friend --- unfollow
            if (tempIndex >= 0) {
                
                PFObject *obj = [arrForObjects objectAtIndex:tempIndex];
                
                [cell animateIndicatorView:YES];
                
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [cell animateIndicatorView:NO];
                        [cell changeButtonState:YES];
                        [arrForObjects removeObjectAtIndex:tempIndex];
                        
                        //                    [tblForFriend reloadData];
                        [self reload:nil];

                    }
                    else
                    {
                        [cell animateIndicatorView:NO];
                        
                        [cell changeButtonState:NO];
                        
                        [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                    }
                }];
                
            }
            
        }else
        {
            
            //add friend
            
            PFObject *obj = [PFObject objectWithClassName:@"Follower"];
            obj[@"FromUser"] = USER;
            obj[@"ToUser"] = tempUser;
            
            [cell animateIndicatorView:YES];
            
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [cell animateIndicatorView:NO];
                if (succeeded) {
                    
                    [cell changeButtonState:YES];
                    [self reload:nil];
                }
                else if (error)
                {
                    [cell animateIndicatorView:NO];
                    
                    [cell changeButtonState:NO];
                    
                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];

                }
            }];
            
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([searchBarForFriendSearch isFirstResponder]) {
        
        if (velocity.y < -0.2f) {
            
            [searchBarForFriendSearch resignFirstResponder];
        }
        else if (velocity.y > 0.2f)
        {
            [searchBarForFriendSearch resignFirstResponder];

        }
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:tblForFriend]) {
        
        PFObject *obj = [arrForFriends objectAtIndex:indexPath.row];

        OMFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCell];
        
        if (!cell) {
            
            cell = [[OMFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
        }
        
        [cell setDelegate:self];
        [cell setCurrentObj:obj tempFriendArray:arrForFriends tempObjectArray:arrForObjects rowIndex:indexPath.row searchMode:NO];

        return cell;
    }
    else if ([tableView isEqual:tblForSearch])
    {
        PFObject *obj = [arrForPeople objectAtIndex:indexPath.row];
        
        OMFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCell];
        
        if (!cell) {
            
            cell = [[OMFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
        }
        
        [cell setDelegate:self];
        [cell setCurrentObj:obj tempFriendArray:arrForFriends tempObjectArray:arrForObjects rowIndex:indexPath.row searchMode:YES];
        
        return cell;

    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:tblForFriend])
    {
        return arrForFriends.count;//arrForFriends.count;
    }
    else if ([tableView isEqual:tblForSearch])
    {
        return arrForPeople.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
