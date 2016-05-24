//
//  OMViewController.m
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMHomeViewController.h"
#import "Classes/OMNewEventPostViewController.h"
#import "OMEventListViewController.h"
#import "OMOtherProfileViewController.h"
#import "Classes/OMCommentViewController.h"
#import "OMDetailEventViewController.h"
#import "OMEventCommentViewController.h"
#import "OMTagListViewController.h"
#import "OMEventCells.h"
#import "BBBadgeBarButtonItem.h"

#import "UIImageView+AFNetworking.h"

#import <Social/Social.h>
#import <Crittercism/Crittercism.h>

#import "OMSocialEvent.h"
#import "OMFeedControlCell.h"
#import "OMFeedHeaderCell.h"
#import "OMFeedImageCell.h"
#import "OMFeedCommentCell.h"
#import "OMSearchCell.h"

@interface OMHomeViewController ()<OMTagListViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    PFUser *currentUser;
    NSMutableArray *arrCurrentTagedFriends;
    NSMutableArray *arrForTagFriends;
    NSMutableArray *arrForComments;
    NSMutableArray *arrForPosts;
    
    NSMutableArray *arrForFirstArray;
    
    UIPinchGestureRecognizer *pangesture1;
    UIPinchGestureRecognizer *pangesture2;
    
    NSUInteger process_number;
}

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl1;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl2;

@end

@implementation OMHomeViewController

@synthesize arrForFeed,dic;

- (void)reload:(__unused id)sender {
    
    [(UIRefreshControl*)sender beginRefreshing];
    
    // Display data from Local Datastore —> RETURN & update TableView

    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery includeKey:@"postedObjects"];
    //[mainQuery includeKey:@"likeUserArray"];//???
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [(UIRefreshControl*)sender endRefreshing];
        if (error == nil) {
  
            if([arrForFeed count] != 0) [arrForFeed removeAllObjects];
            for (PFObject *obj in objects) {
                
                OMSocialEvent * socialtempObj = (OMSocialEvent*) obj;
                PFUser *user = socialtempObj[@"user"];
                
                // Filtering Event: Own Events or User's Events including me in TagFriends
                if ([socialtempObj[@"TagFriends"] containsObject:USER.objectId] || [user.objectId isEqualToString:USER.objectId] )
                {
                    if (user != nil && user.username != nil) {
                        [arrForFeed addObject:socialtempObj];
                    }
                    else
                    {
                        NSLog(@"missing user obj == %@", socialtempObj);
                    }
                }
              }
            
            arrForFirstArray = [arrForFeed copy];
            [arrForFeed removeAllObjects];
            [self estimateBadgeCount1];
            
        }
    }];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    currentUser = [PFUser currentUser];
    is_grid = YES;
    commentLoaded = NO;

    arrForFeed = [NSMutableArray array];
    arrForTagFriends = [NSMutableArray array];
    arrForComments = [NSMutableArray array];
    arrCurrentTagedFriends = [NSMutableArray array];
    arrForPosts = [NSMutableArray array];
   
    UIButton *changeModeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [changeModeButton addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
    [changeModeButton setImage:[UIImage imageNamed:@"btn_display"] forState:UIControlStateNormal];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6

    //BBBadgeBarButtonItem *changeBtn = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:changeModeButton];
    //self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, changeBtn, nil];

 
    self.refreshControl1 = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, collectionViewForFeed.frame.size.width, 100.0f)];
    [self.refreshControl1 addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [collectionViewForFeed addSubview:self.refreshControl1];
    
//    self.refreshControl2 = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tblForEventFeed.frame.size.width, 100.0f)];
//    
//    [self.refreshControl2 addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];

//    [tblForEventFeed addSubview:self.refreshControl2];

//     Do any additional setup after loading the view, typically from a nib.
//    
//    [self followScrollView:collectionViewForFeed];
//    
//    
//    
//    
//    pangesture1 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeDisplayViewMode:)];
//    
//    [tblForEventFeed addGestureRecognizer:pangesture1];
//    pangesture2 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeDisplayViewMode:)];
//
//    [collectionViewForFeed addGestureRecognizer:pangesture2];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFeedData) name:kLoadFeedData object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPush:) name:kReceivedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstViewLoad) name:kNotificationFirstViewLoad object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBadge:) name:kShowBadgeOnEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEventWithGlobal) name:kLoadEventDataWithGlobal object:nil];
    
}

//Notification Methods

- (void)firstViewLoad {
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

// Standard Events for new account users. This will be showed when only new account is opened the app at first.
- (void) standardEventLoad
{
    [MBProgressHUD showMessag:@"Loading..." toView:self.view];
    
    // class StandardEvent : this will have special Event Table.
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"StandardEvent"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery includeKey:@"postedObjects"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil)
        {
            if ([objects count] == 0) {
                NSLog(@"No Data: %@", [mainQuery parseClassName]);
                return;
            }
            
            [arrForFeed removeAllObjects];
            for (PFObject *obj in objects) {
                OMSocialEvent * socialtempObj = (OMSocialEvent*) obj;
                [arrForFeed addObject:socialtempObj];
            }
            if (is_grid) [collectionViewForFeed reloadData];
            else [tblForEventFeed reloadData];
        }
    }];

}
- (void)showBadge:(NSNotification *)_notification {
    
    NSDictionary *userInfo = _notification.userInfo;
    
    //NSLog(@"------------notification receive now-----------------%@", userInfo);
    
    if ([userInfo objectForKey:@"request"]) {
        
        NSString *idOfTargetEvent = [userInfo objectForKey:@"request"];
        
        int i = 0;
        for (OMSocialEvent *event in arrForFeed) {

            if ([event.objectId isEqualToString:idOfTargetEvent]) {
                
                event.badgeCount++;
                
//                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
//                
//                [collectionViewForFeed performBatchUpdates:^{
//                    [collectionViewForFeed reloadItemsAtIndexPaths:[NSArray arrayWithObject:reloadIndexPath]];
//                } completion:^(BOOL finished) {
//                    
//                    
//                    NSLog(@"CollectionView reloaded");
//                    
//                }];
//
//                return;
            }
            i++;
        }
        
        [collectionViewForFeed reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"Event count && Event Global count = %ld, %ld",
    [arrForFeed count],[[GlobalVar getInstance].gArrEventList count]);
    
 }

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSString *breadcrumb = [NSString stringWithFormat:@"View controller appeared on screen: %@",[self class]];
    [Crittercism leaveBreadcrumb:breadcrumb];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push

- (void)receivedPush:(NSNotification *)_notification {
    
}

- (void)reloadEventWithGlobal
{
    NSLog(@"-- Reload with global data --");
    
    [arrForFeed removeAllObjects];
    arrForFeed = [[GlobalVar getInstance].gArrEventList mutableCopy];
    
    if (is_grid) [collectionViewForFeed reloadData];
    else [tblForEventFeed reloadData];

}

- (void)loadFeedData {
    
    [GlobalVar getInstance].isEventLoading = YES;
    
    arrForFirstArray = [NSMutableArray array];
    [MBProgressHUD showMessag:@"Loading..." toView:self.view];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    //[mainQuery includeKey:@"likeUserArray"];
    [mainQuery includeKey:@"postedObjects"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [GlobalVar getInstance].isEventLoading = NO;
        
        if (error == nil)
        {
            if ([objects count] == 0) {
                NSLog(@"No Data: %@", [mainQuery parseClassName]);
                return;
            }
            
            if([arrForFeed count] != 0) [arrForFeed removeAllObjects];
            for (PFObject *obj in objects) {
                
                OMSocialEvent * socialtempObj = (OMSocialEvent*) obj;
                PFUser *user = socialtempObj[@"user"];
                
                // Filtering Event: Own Events or User's Events including me in TagFriends
                if ([socialtempObj[@"TagFriends"] containsObject:USER.objectId] || [user.objectId isEqualToString:USER.objectId] )
                {
                    if (user != nil && user.username != nil) {
                        [arrForFeed addObject:socialtempObj];
                    }
                    else
                    {
                        NSLog(@"missing user obj = %@", socialtempObj);
                    }
                }
                
            }
            
            arrForFirstArray = [arrForFeed copy];
            [arrForFeed removeAllObjects];
            [self estimateBadgeCount1];
        }
    }];
}

// For pre processing for Badge Count
// For this features, it was added some columns on Event, Post class.
// Event class: postedObjects:(Array with Post Objects)
// Event class: eventBadgeFlag:(Array with user's objectId to be able to look this events,
//                              When this event have looked, is removed the user's id)
// Post class: usersBadgeFlag:(Array with user's objectId to be able to look this posts,
//                              it is the some like eventflag)

- (void) estimateBadgeCount1
{
    if ([arrForFirstArray count] == 0 || arrForFirstArray == nil)
    {
        if (is_grid) [collectionViewForFeed reloadData];
        else [tblForEventFeed reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    for( OMSocialEvent *eventObj in arrForFirstArray)
    {
        NSInteger postBadgeCount = 0;
        
        if(eventObj[@"postedObject"] != nil && [eventObj[@"postedObject"] count] > 0)
        {
            for (PFObject *postObj in eventObj[@"postedObjects"])
            {
                if(postObj != nil)
                {
                    if(postObj[@"usersBadgeFlag"] && [postObj[@"usersBadgeFlag"] count] > 0)
                    {
                        for(NSString *userId in postObj[@"usersBadgeFlag"])
                        {
                            if ([userId isEqualToString:currentUser.objectId]) {
                                postBadgeCount++;
                            }
                        }
                    }
                }
            }

        }
            eventObj.badgeCount = postBadgeCount;
        
        if ([eventObj[@"eventBadgeFlag"] containsObject:currentUser.objectId])
        {
             eventObj.badgeNewEvent = 1;
        }
        [arrForFeed addObject:eventObj];
    }
    
    [[GlobalVar getInstance].gArrEventList removeAllObjects];
    [GlobalVar getInstance].gArrEventList = [arrForFeed mutableCopy];
    
    if (is_grid) [collectionViewForFeed reloadData];
    else [tblForEventFeed reloadData];
    
}

// Recurrent processing until arrForFirstArray is empty
- (void) estimateBadgeCount
{
    if ([arrForFirstArray count] == 0 || [arrForFirstArray firstObject] == nil)
    {
        if (is_grid) [collectionViewForFeed reloadData];
        else [tblForEventFeed reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    PFObject *event_obj = [arrForFirstArray firstObject];
    OMSocialEvent *eventSocialObj = (OMSocialEvent *)event_obj;
    
    NSDate *lastLoadTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateLocalDatastore"];
        
    if (!lastLoadTime) {
         lastLoadTime = [NSDate date];
         [[NSUserDefaults standardUserDefaults] setObject:lastLoadTime forKey:@"lastUpdateLocalDatastore"];
         [[NSUserDefaults standardUserDefaults] synchronize];
    }
        
    NSDate *postTime = [event_obj updatedAt];
    NSComparisonResult result = [lastLoadTime compare:postTime];
        
    BOOL newEventFlag = NO;
        
    if (result == NSOrderedSame || result == NSOrderedAscending){
          newEventFlag = YES;
    }
        
    PFQuery *temp_mainQuery = [PFQuery queryWithClassName:@"Post"];
    [temp_mainQuery whereKey:@"targetEvent" equalTo:event_obj];
    [temp_mainQuery orderByDescending:@"createdAt"];
    [temp_mainQuery findObjectsInBackgroundWithBlock:^(NSArray *post_objects, NSError *error) {
            
        if (error != nil) {
            eventSocialObj.badgeCount = 0;
            [arrForFeed addObject:eventSocialObj];
        }
        else
        {
            NSUInteger temp_badge_number = 0;
                
            if (newEventFlag){
                temp_badge_number = post_objects.count;
            }
            else
            {
                if (post_objects.count > 0){
                    
                    NSString * temp_lastLoadTime_Key = [NSString stringWithFormat:@"%@-lastLoadTime", event_obj.objectId];
                    NSDate * temp_lastLoadTime = [[NSUserDefaults standardUserDefaults] objectForKey:temp_lastLoadTime_Key];
                    
                    for (PFObject *t_obj in post_objects){
                        NSDate *temp_postTime = t_obj.updatedAt;
                        NSComparisonResult temp_result = [temp_lastLoadTime compare:temp_postTime];
                        
                        if (temp_result == NSOrderedSame || temp_result == NSOrderedAscending){
                            temp_badge_number ++;
                        }
                    }
                }
            }
                
            eventSocialObj.badgeCount = temp_badge_number;
            [arrForFeed addObject:eventSocialObj];
            if([arrForFirstArray count] > 0)[arrForFirstArray removeObjectAtIndex:0];
                
        }
            
        if([arrForFeed count] % 6 == 0)
        {
            if (is_grid) [collectionViewForFeed reloadData];
            else [tblForEventFeed reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
            
        if ([arrForFirstArray count] > 0){
                
            [self estimateBadgeCount];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSDate* lastUpdatedate = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:lastUpdatedate forKey:@"lastUpdateLocalDatastore"];
            [[NSUserDefaults standardUserDefaults] synchronize];
                
            if (is_grid) [collectionViewForFeed reloadData];
            else [tblForEventFeed reloadData];
        }
    }];
    
}

- (void)postNewEvent {
    
    OMNewEventPostViewController *newEventPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewEventPostVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newEventPostVC];
    
    [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];
}

- (void)eventClick:(UIButton *)btn {
    
    PFObject * _obj = [arrForFeed objectAtIndex:btn.tag];
    
    if (_obj != nil) {
        OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
        [detailEventVC setCurrentObject:_obj];
        [[SlideNavigationController sharedInstance] pushViewController:detailEventVC animated:YES];
    }
}

- (void)changeMode:(id)sender {
    
    if (is_grid) {
        
        [collectionViewForFeed setHidden:YES];
        [self.view addSubview:tblForEventFeed];
        [tblForEventFeed setHidden:NO];

    } else {
        
        [tblForEventFeed setHidden:YES];
        [self.view addSubview:collectionViewForFeed];
        [collectionViewForFeed setHidden:NO];

    }
    
    is_grid = !is_grid;
    [collectionViewForFeed reloadData];
    [tblForEventFeed reloadData];
    
}

#pragma mark - Tag List

- (void)selectedCells:(OMTagListViewController *)tagVC didFinished:(NSMutableArray *)_dict {
    
    [tagVC.navigationController dismissViewControllerAnimated:YES completion:^{
        arrForTagFriends = [_dict copy];
        
        [self addTagFriends:(NSMutableArray *)_dict];      
        
        
    }];
}

- (void)addTagFriends:(NSMutableArray *)_dict {

    NSLog(@"%@",currentObject[@"TagFriends"]);
    NSMutableArray *arrForTags = [NSMutableArray array];
    [arrForTags addObjectsFromArray:currentObject[@"TagFriends"]];
    [arrForTags addObjectsFromArray:_dict];
    [currentObject setObject:arrForTags forKey:@"TagFriends"];
    [currentObject saveInBackground];
}

//Cell Count

- (NSInteger)cellCount:(PFObject *)_obj {
    
    NSInteger rows = 0;
    
    rows += 1;
    //Photo
    
    rows += 1;
    //Comments
    
    rows += [_obj[@"commenters"] count] > 5 ? 5:[_obj[@"commenters"] count];
    //Photo Option
    rows += 1;
    
    return rows;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OMSocialEvent *obj = (OMSocialEvent *)[arrForFeed objectAtIndex:indexPath.item];
    
    OMSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchCell forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setCurrentObj:obj];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return arrForFeed.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
    OMSocialEvent *event = [arrForFeed objectAtIndex:indexPath.item];
    
    if (event != nil) {
        
        NSString *lastLoadTime_Key = [NSString stringWithFormat:@"%@-lastLoadTime", event.objectId];
        NSDate* lastLoadTime = [NSDate date];
        
        [[NSUserDefaults standardUserDefaults] setObject:lastLoadTime forKey:lastLoadTime_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        event.loadTimeAt = lastLoadTime;
        
        // Event Badge processing...
        if([event[@"eventBadgeFlag"] containsObject:currentUser.objectId])
        {
            if(event.badgeNewEvent >= 1) event.badgeNewEvent = 0;
            [event removeObject:currentUser.objectId forKey:@"eventBadgeFlag"];
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) NSLog(@"DetailEventVC: Event Badge remove when open Detail view...");
            }];
        }
        
        
        [arrForFeed replaceObjectAtIndex:indexPath.item withObject:event];
        [collectionViewForFeed reloadData];
        
        [[GlobalVar getInstance].gArrEventList removeAllObjects];
        [GlobalVar getInstance].gArrEventList = [arrForFeed mutableCopy];
        
        [GlobalVar getInstance].gEventIndex = indexPath.item;
        
        [detailEventVC setCurrentObject:event];
        [self.navigationController pushViewController:detailEventVC animated:YES];
        
    }
}

// don't use this function now
- (void) postBadgeProcess
{
    if([arrForPosts count] == 0)
    {
        return;
    }
    PFObject *postedObj = [arrForPosts firstObject];
    
        if(![postedObj isEqual:[NSNull null]] && postedObj != nil)
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            temp = [postedObj[@"usersBadgeFlag"] mutableCopy];
            
            if ([temp containsObject:currentUser.objectId])
            {
                [temp removeObject:currentUser.objectId];
                
                postedObj[@"usersBadgeFlag"] = temp;
                [postedObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil) NSLog(@"DetailEventVC: Post Badge remove when open Detail view...");
                    
                    if ([arrForPosts count] > 0) {
                        [arrForPosts removeObjectAtIndex:0];
                        [self postBadgeProcess];
                    }
                  
                    
                }];
            }
        }
}

#pragma mark  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!is_grid) {
        
        static NSString *CellIdentifier_ = @"PhotoCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_];
        for (int i= 0; i < 3; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            button.center = CGPointMake((kImageWidth * 0.5f + (1 + kImageWidth) * i), kImageHeight * 0.5f);
            button.tag = indexPath.row * 3 + i;
            
            [button addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *replaceView = [UIImageView new];
            replaceView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            replaceView.layer.borderWidth = 1.0f;
            if (button.tag < [arrForFeed count]) {
                
                PFObject *obj = [arrForFeed objectAtIndex:button.tag];
                PFFile *postImgFile = (PFFile *)obj[@"thumbImage"];
                if (postImgFile) {
                    if (replaceView.image) {
                        replaceView.image = nil;
                    }
                    [OMGlobal setImageURLWithAsync:postImgFile.url positionView:button displayImgView:replaceView];
                    [replaceView setFrame:button.bounds];
                    [button addSubview:replaceView];
                    replaceView.userInteractionEnabled = NO;                    
                    [cell addSubview:button];
                }
            }
        }
        
        return cell;
        
    } else {
        
        PFObject *obj = [arrForFeed objectAtIndex:indexPath.section];
        NSLog(@"%ld", (long)[self cellCount:obj]);
        if (indexPath.row == 0) {
            OMFeedHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedHeaderCell];
            
            if (cell == nil) {
                cell = [[OMFeedHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedHeaderCell];
            }
            
            [cell setDelegate:self];
            [cell setCurrentObj:obj];
            
            return cell;
        }
        else if (indexPath.row == 1)
        {
            OMFeedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedImageCell];
            if (!cell) {
                cell = [[OMFeedImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedImageCell];
            }
            [cell setDelegate:self];
            [cell setCurrentObj:obj];
            
            return cell;
        }
        else if (indexPath.row > 1 && indexPath.row < [self cellCount:obj] - 1)
        {
            
            NSInteger row = indexPath.row - 1;
            
            OMFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedCommentCell];
            
            if (!cell) {
                cell = [[OMFeedCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedCommentCell];
            }
            
            [cell setDelegate:self];
            [cell setUser:[obj[@"commenters"] objectAtIndex:row - 1] comment:[obj[@"commentsArray"] objectAtIndex:row - 1] curObj:[arrForFeed objectAtIndex:row - 1] number:row - 1];
            
            return cell;

        }
        else if (indexPath.row == [self cellCount:obj] - 1)
        {
            OMFeedControlCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedControlCell];
            
            if (!cell) {
                cell = [[OMFeedControlCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedControlCell];
            }
            
            [cell setDelegate:self];            
            [cell setCurrentObj:obj];
            
            return cell;

        }
        
        return nil;

    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (is_grid) {
//        return kImageHeight;
//    }
//    else
//    {
        PFObject *obj = [arrForFeed objectAtIndex:indexPath.section];
        
        if (indexPath.row == 0) {
            
            return [OMGlobal heightForCellWithPost:obj[@"description"]] + 45.0f;
        }
        else if (indexPath.row == 1)
        {
            return tableView.frame.size.width;
        }
        else if (indexPath.row > 1 && indexPath.row < [self cellCount:obj] - 1)
        {
            return [OMGlobal heightForCellWithPost:[obj[@"commentsArray"] objectAtIndex:indexPath.row - 2]] + 20.0f;
        }
        else if (indexPath.row == [self cellCount:obj] - 1)
        {
            return 40;
        }
       
//    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (is_grid) {
        
        if ([arrForFeed count] % 3 == 0) {
            return [arrForFeed count] / 3;
        }
        else if ([arrForFeed count] % 3 > 0)
        {
            return ([arrForFeed count] / 3 + 1);
            
        }
        
    }
    else
    {
        PFObject *object = [arrForFeed objectAtIndex:section];        
        return [self cellCount:object];
    }
    
    return 0;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (is_grid) {
        return 0;
    }
    
    return [arrForFeed count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(OMFeedImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = [arrForFeed objectAtIndex:indexPath.section];
    
    if (indexPath.row == 1)
    {
        
        if ([obj[@"postType"] isEqualToString:@"video"]) {
            PFFile *videoFile = (PFFile *)obj[@"video"];

            [cell playVideo:videoFile.url];
            
        }
        else if ([obj[@"postType"] isEqualToString:@"audio"])
        {
            
        }
    }


}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(OMFeedImageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = [arrForFeed objectAtIndex:indexPath.section];
    
    if (indexPath.row == 1)
    {
        
        if ([obj[@"postType"] isEqualToString:@"video"]) {
            
            [cell stopVideo];
            
        }
        else if ([obj[@"postType"] isEqualToString:@"audio"])
        {
            
        }
    }


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)newEventPost:(id)sender {
    [self postNewEvent];
}

- (IBAction)showTableView:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 100:
        {
            is_grid = NO;
        }
            break;
        case 101:
        {
            is_grid = YES;
        }
            break;
        default:
            break;
    }
    [tblForEventFeed reloadData];
    
}


#pragma mark Cell Delegate Methods

- (void)tagPeople:(PFObject *)_obj
{
    currentObject = _obj;
    OMTagListViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagListVC"];
    tagListVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)shareEvent:(PFObject *)_obj {
    
    UIActionSheet *shareAction1 = nil;

    NSString *status = @"Close";
    postImgView = [[UIImageView alloc] init];
    PFFile *file = (PFFile *)_obj[@"thumbImage"];
    [postImgView setImageWithURL:[NSURL URLWithString:file.url]];
    currentObject = _obj;
    NSLog(@"%@",_obj[@"openStatus"]);
    
    
    if ([_obj[@"openStatus"] intValue] == 1) {
        status = @"Close";
    }
    else
    {
        status = @"Open";
    }
    
    PFUser *user = (PFUser *)_obj[@"user"];
    NSLog(@"%@----%@",user,[PFUser currentUser]);
    
    if ([user.objectId isEqualToString:currentUser.objectId]) {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Share via Email" otherButtonTitles:@"Facebook",@"Twitter",@"Instagram",status,@"Delete", @"Report", nil];
    }
    else
    {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Share via Email" otherButtonTitles:@"Facebook",@"Twitter",@"Instagram", @"Report", nil];

    }
    
    [shareAction1 showInView:self.view];

    shareAction1.tag = 2000;;
}

- (void)noticeNewPost:(PFObject *)_obj
{
    
}

- (void)showEventList:(PFObject *)_obj
{
    OMEventListViewController * eventListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    
    [self.navigationController pushViewController:eventListVC animated:YES];
}


- (void)showComments:(PFObject *)_obj
{
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [((OMAppDelegate *)[UIApplication sharedApplication].delegate) tabBarController];
    
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:YES];
    OMEventCommentViewController *eventCommentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventCommentVC"];
    [eventCommentVC setCurrentObject:_obj];
    
    [self.navigationController pushViewController:eventCommentVC animated:YES];
}

- (void)showDetail:(PFObject *)_obj
{
    OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
    [detailEventVC setCurrentObject:_obj];
    [[SlideNavigationController sharedInstance] pushViewController:detailEventVC animated:YES];
}

- (void)showProfile:(PFUser *)_user
{
    OMOtherProfileViewController *otherProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
    otherProfileVC.is_type = 0;
    [otherProfileVC setTargetUser:_user];
    [self.navigationController pushViewController:otherProfileVC animated:YES];
}


- (IBAction)showLeftMenu:(id)sender {
    
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == 2000) {
        
        
        switch (buttonIndex) {
            case 0:
            {
                [self shareViaEmail];
                
            }
                break;
            case 1:
            {
                [self shareViaFacebook];
                
            }
                break;
            case 2:
            {
                [self shareViaTwitter];
                
            }
                break;
            case 3:
            {
                [self shareViaInstagram];
                
            }
                break;
            case 5:
            {
                [self deleteFeed];
                
            }
                break;
            case 4:
            {
                NSInteger status;
                
                if ([currentObject[@"openStatus"] intValue] == 1) {
                    status = 0;
                }
                else
                {
                    status = 1;
                }
                [currentObject setObject:[NSNumber numberWithInteger:status] forKey:@"openStatus"];
                
                [currentObject saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self loadFeedData];
                    }
                }];
            }
                break;
            default:
                break;
        }

    }
    
    
}

#pragma mark ActionSheet Actions

//delete Feed Action
- (void)deleteFeed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [alertView show];
}

//share Via Email
- (void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:currentObject[@"eventname"]];
        [mailView setMessageBody:[NSString stringWithFormat:@"You are invited to join ICYMI and %@ by %@!", currentObject[@"eventname"], USER.username ] isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
        [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [TABController presentViewController:mailView animated:YES completion:nil];
        //        [mailView release];
        
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles: nil];
        [alert show];
    }/* else {
      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Mail transfered successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [self dismissViewControllerAnimated:YES completion:nil];
      } */
    [TABController dismissViewControllerAnimated:YES completion:nil];
    
}


//share Via Facebook

- (void)shareViaFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Created by ICYMI App!"];
        [controller addURL:[NSURL URLWithString:@"http://collabro.com"]];
        [controller addImage:postImgView.image];
        
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your facebook setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

//share Via Twitter
- (void)shareViaTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Created  by My  ICYMI App!"];
        [tweetSheet addURL:[NSURL URLWithString:@"http://Collabro.com"]];
        [tweetSheet addImage:postImgView.image];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your twitter setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)shareViaInstagram
{
    UIImage * screenshot = postImgView.image;//[[CCDirector sharedDirector] screenshotUIImage];
    
    // UIImage *screenshot = [UIImage imageNamed:@"splash@2x.png"];
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Screenshot.igo"];
    
    // Write image to PNG
    [UIImageJPEGRepresentation(screenshot, 1.0) writeToFile:savePath atomically:YES];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //imageToUpload is a file path with .ig file extension
        dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        dic.UTI = @"com.instagram.exclusivegram";
        dic.delegate = self;
        
        dic.annotation = [NSDictionary dictionaryWithObject:@"Uploaded using #ICYMI App" forKey:@"InstagramCaption"];
        [dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
    }
    else
    {
        [OMGlobal showAlertTips:@"Please install Instagram app" title:nil];
    }
    
}
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            
            [self.view addSubview:hud];
            
            [hud setLabelText:@"Deleting Event..."];
            [hud show:YES];
            [currentObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [hud hide:YES];
                if (succeeded) {
                    
                    [self loadFeedData];
                }
            }];
        }
            break;
        case 1:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)selectDidCancel:(OMTagListViewController *)fsCategoryVC {
    //[fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end