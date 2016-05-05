//
//  OMFriendListViewController.m
//  Collabro
//
//  Created by elance on 8/13/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMFriendListViewController.h"
#import "OMFriendListCell.h"

#import "OMProfileViewController.h"

@interface OMFriendListViewController ()

@end

@implementation OMFriendListViewController

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
    is_grid = NO;
    // Do any additional setup after loading the view.
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

- (void)loadFriends
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFollower];
    
    [mainQ includeKey:@"FromUser"];
    [mainQ includeKey:@"ToUser"];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if (error) {
            
            [OMGlobal showAlertTips:nil title:@"Error!"];
        }
        else
        {
            if (objects.count == 0) {
                NSLog(@"Not Found");
            }
            else
            {
                [arrForFriend removeAllObjects];
                for (PFObject *obj in objects) {
                    
                    NSLog(@"%@",[obj objectForKey:@"FromUser"]);
                    PFUser *user = (PFUser *)[obj objectForKey:@"FromUser"];
                    if ([user.objectId isEqualToString:kIDOfCurrentUser]) {                        
                        
                        [arrForFriend addObject:obj[@"ToUser"]];
                        
                    }
                }
                
                [tblForFriends reloadData];
            }
        }
        
    }];

}

- (void)photoClick:(UIButton *)button
{
    
}

- (void)showProfile:(PFUser *)_user
{
    OMProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OMProfileVC"];
    profileVC.is_type = 0;
    [profileVC setTargetUser:_user];
    
    [self.navigationController pushViewController:profileVC animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
    if (is_grid) {
        static NSString *CellIdentifier_ = @"PhotoCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_];
        for (int i= 0; i < 3; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            button.center = CGPointMake((kImageWidth * 0.5f + (1 + kImageWidth) * i), kImageHeight * 0.5f);
            button.tag = indexPath.row * 3 + i;
            
            [button addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *replaceView = [UIImageView new];
            replaceView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            replaceView.layer.borderWidth = 1.0f;
            if (button.tag < [arrForFriend count]) {
                
                PFObject *obj = [arrForFriend objectAtIndex:button.tag];
                PFUser *user = (PFUser *)obj;
                
                
                if ([user[@"loginType"] isEqualToString:@"email"]) {
                    PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
                    if (avatarFile) {
                        [OMGlobal setImageURLWithAsync:avatarFile.url positionView:button displayImgView:replaceView];
                    }
                    
                }
                else if ([user[@"loginType"] isEqualToString:@"facebook"])
                {
                    [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:button displayImgView:replaceView];
                }

                
                
//                PFFile *postImgFile = (PFFile *)obj[@"ProfileImage"];
//                
//                if (postImgFile) {
//                    
//                    [OMGlobal setImageURLWithAsync:postImgFile.url positionView:button displayImgView:replaceView];
                    [replaceView setFrame:button.bounds];
                    [button addSubview:replaceView];
                    replaceView.userInteractionEnabled = NO;
                    
                    [cell addSubview:button];
                }
            }
        
        
        return cell;
        
    }
    else
    {
        static NSString *CellIdentifier = @"OMFriendListCell";
        OMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[OMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.delegate = self;
        [cell setObject:[arrForFriend objectAtIndex:indexPath.row]];
        
        return cell;

    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForFriend count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (is_grid) {
        return kImageHeight;
    }
    else
    {
        return 45;
    }
}
- (IBAction)changeAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            is_grid = NO;
        }
            break;
        case 11:
        {
            is_grid = YES;
        }
            break;
        default:
            break;
    }
    [tblForFriends reloadData];

}
@end
