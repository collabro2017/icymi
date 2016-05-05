//
//  OMSearchViewController.m
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMSearchViewController.h"
#import "OMSearchCell.h"

#import "OMDetailEventViewController.h"

@interface OMSearchViewController ()<UISearchBarDelegate>
{
    
    NSMutableArray *arrForSearchEvents;
    
    NSMutableArray *arrForSearchData;
    
}
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation OMSearchViewController
@synthesize searchBarForEvent;
- (void)reload:(__unused id)sender
{
    
    [(UIRefreshControl*)sender beginRefreshing];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    //[mainQuery fromLocalDatastore];
//        [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
//    [mainQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [(UIRefreshControl*)sender endRefreshing];
        if (objects == nil || [objects count] == 0) {
            
//            [self postNewEvent];
            
            return;
        }
        if (!error) {
            [arrForSearchEvents removeAllObjects];
            
            [arrForSearchEvents addObjectsFromArray:objects];
            
        }
        [collectionViewForSearch reloadData];
        
    }];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrForSearchEvents = [NSMutableArray array];
    arrForSearchData = [NSMutableArray array];
    
    //
    
    
    if (!self.refreshControl) {
        self.refreshControl                  = [UIRefreshControl new];
//        self.refreshControl.tintColor        = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(reload:)
                      forControlEvents:UIControlEventValueChanged];
    }
    if (![self.refreshControl isDescendantOfView:collectionViewForSearch]) {
        [collectionViewForSearch addSubview:self.refreshControl];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSearchData) name:kLoadSearchData object:nil];
    [self loadSearchData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self addObservers];
    if (!searchBarForEvent) {
        self.searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        searchBarForEvent = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
//        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
//        self.searchBar.tintColor            = [UIColor whiteColor];
//        self.searchBar.barTintColor         = [UIColor whiteColor];
        searchBarForEvent.delegate             = self;
        searchBarForEvent.placeholder          = @"Search";
//        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    }
    
    if (![searchBarForEvent isDescendantOfView:self.view]) {
        [self.view addSubview:searchBarForEvent];
    }

}

-(void)dealloc{
    // remove Our KVO observer
    [self removeObservers];
}

//Search Request and result

- (void)searchRequestWithKey:(NSString *)searchKey
{
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:kClassEvent];
    [eventQuery whereKey:@"eventname" hasPrefix:searchKey];
    
    PFQuery *eventQueryCapitalized = [PFQuery queryWithClassName:kClassEvent];
    [eventQueryCapitalized whereKey:@"eventname" hasPrefix:[searchKey capitalizedString]];
    
    PFQuery *eventQueryLowerCase = [PFQuery queryWithClassName:kClassEvent];
    [eventQueryLowerCase whereKey:@"eventname" hasPrefix:[searchKey lowercaseString]];
    
    
    
    PFQuery *descriptionQuery = [PFQuery queryWithClassName:kClassEvent];
    [descriptionQuery whereKey:@"description" hasPrefix:searchKey];
    
    PFQuery *descriptionQueryCapitalized = [PFQuery queryWithClassName:kClassEvent];
    [descriptionQueryCapitalized whereKey:@"description" hasPrefix:[searchKey capitalizedString]];
    
    PFQuery *descriptionQueryLowerCase = [PFQuery queryWithClassName:kClassEvent];
    [descriptionQueryLowerCase whereKey:@"description" hasPrefix:[searchKey lowercaseString]];
    
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[ eventQuery, eventQueryCapitalized, eventQueryLowerCase, descriptionQuery, descriptionQueryCapitalized, descriptionQueryLowerCase]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];

    [self.refreshControl beginRefreshing];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error) {
            [arrForSearchData removeAllObjects];
            [arrForSearchData addObjectsFromArray:objects];
            [collectionViewForSearch reloadData];
        }        
    }];
}

#pragma mark - observer
- (void)addObservers{
    [collectionViewForSearch addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)removeObservers{
    [collectionViewForSearch removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == collectionViewForSearch ) {
        searchBarForEvent.frame = CGRectMake(searchBarForEvent.frame.origin.x,
                                          self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY),
                                          searchBarForEvent.frame.size.width,
                                          searchBarForEvent.frame.size.height);
    }
}


#pragma mark - search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0) {
        // search and reload data source
        self.searchBarActive = YES;
        
        [self searchRequestWithKey:searchText];
       
    }else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        self.searchBarActive = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [collectionViewForSearch reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.searchBarActive = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    self.searchBarActive = NO;
    [searchBarForEvent resignFirstResponder];
    searchBarForEvent.text  = @"";
}


- (void)loadSearchData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    //[mainQuery fromLocalDatastore];
    //        [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    //    [mainQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            
            [OMGlobal showAlertTips:@"You have had not any Event yet. Please post new one." title:nil];
            //            [self postNewEvent];
            
            return;
        }
        if (!error) {
            [arrForSearchEvents removeAllObjects];
            
            [arrForSearchEvents addObjectsFromArray:objects];
            
//            for (PFObject *object in objects) {
//                PFUser *user = (PFUser *)object[@"user"];
////                if ([object[@"TagFriends"] containsObject:currentUser.objectId] || [user.objectId isEqualToString:currentUser.objectId] ) {
////                    
////                    if ([object[@"TagFriends"] containsObject:currentUser.objectId]) {
////                        NSLog(@"user was tagged.");
////                    }
////                    else
////                    {
////                        NSLog(@"user is me.");
////                    }
////                    [arrForFeed addObject:object];
////                    //                    [arrForFeed addObjectsFromArray:objects];
////                    
////                }
//                
//                
            }
            [collectionViewForSearch reloadData];
            
    }];

}

- (void)SearchData:(NSString *)searchStr
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -  <UICollectionViewDelegateFlowLayout>
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(searchBarForEvent.frame.size.height, 0, 0, 0);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat cellLeg = (collectionViewForSearch.frame.size.width/2) - 5;
//    return CGSizeMake(cellLeg,cellLeg);;
//}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([searchBarForEvent isFirstResponder]) {
        
        if (velocity.y < -0.2f) {
            
            [searchBarForEvent resignFirstResponder];
        }
        else if (velocity.y > 0.2f)
        {
            [searchBarForEvent resignFirstResponder];
            
        }
    }
}


#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *obj = nil;
    
    if (self.searchBarActive) {
        
        obj = [arrForSearchData objectAtIndex:indexPath.row];
    }
    else
    {
        obj = [arrForSearchEvents objectAtIndex:indexPath.item];
    }
    
    OMSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchCell forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setCurrentObj:obj];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (self.searchBarActive) {
        
        return arrForSearchData.count;
    }
    else
        return arrForSearchEvents.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
    
    PFObject *curObject;
    
    if (self.searchBarActive) {
        
        curObject = [arrForSearchData  objectAtIndex:indexPath.item];

    }
    else{
        
        curObject = [arrForSearchEvents  objectAtIndex:indexPath.item];

    }

    
    NSMutableArray *arrForTagFriends = curObject[@"TagFriends"];
    if (!arrForTagFriends) {
        
        arrForTagFriends = [NSMutableArray array];
    }else{
        
        if ([arrForTagFriends containsObject:USER.objectId] || [((PFUser *)curObject[@"user"]).objectId isEqualToString:USER.objectId]) {
            
            
            [detailEventVC setCurrentObject:curObject];
            
            [self.navigationController pushViewController:detailEventVC animated:YES];
            
        }

        
    }
    
    
    
    
}
@end
