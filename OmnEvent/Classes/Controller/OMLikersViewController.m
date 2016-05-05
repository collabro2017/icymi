//
//  OMLikersViewController.m
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMLikersViewController.h"
#import "OMFriendCell.h"

@interface OMLikersViewController ()
{
    NSMutableArray *arrForLikers;
}
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OMLikersViewController
- (void)reload:(__unused id)sender
{
    
//    [(UIRefreshControl*)sender beginRefreshing];
//    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
//    
//    [mainQ includeKey:@"FromUser"];
//    [mainQ includeKey:@"ToUser"];
//    
//    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        
//        [(UIRefreshControl*)sender endRefreshing];
//        
//        if (error) {
//            
//            [OMGlobal showAlertTips:nil title:@"Error!"];
//        }
//        else
//        {
//            if (objects.count == 0) {
//                NSLog(@"Not Found");
//            }
//            else
//            {
//                [arrForFriends removeAllObjects];
//                [arrForPeople removeAllObjects];
//                for (PFObject *obj in objects) {
//                    
//                    NSLog(@"%@",[obj objectForKey:@"FromUser"]);
//                    PFUser *user = (PFUser *)[obj objectForKey:@"FromUser"];
//                    if ([user.objectId isEqualToString:kIDOfCurrentUser]) {
//                        
//                        [arrForObjects addObject:obj];
//                        
//                        [arrForFriends addObject:obj[@"ToUser"]];
//                    }
//                }
//                [tblForFriend reloadData];
//            }
//        }
//        
//    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrForLikers = [NSMutableArray array];
    
    
    self.title = @"Friends";
    //
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tblForLikers.frame.size.width, 100.0f)];
    
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    [tblForLikers addSubview:self.refreshControl];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:kLoadFriendData object:nil];
//    [self loadLikers];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    arrForLikers = [_curObj objectForKey:@"likeUserArray"];
}

- (void)loadLikers
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    NSMutableArray *userArr = [_curObj objectForKey:@"likeUserArray"];
    
    for (PFUser *user in userArr) {
        
        
        
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
#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = [arrForLikers objectAtIndex:indexPath.row];
    
    OMFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCell];
    
    if (!cell) {
        
        cell = [[OMFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
    }
    
    [cell setDelegate:self];
    [cell setCurrentObj:obj];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForLikers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
