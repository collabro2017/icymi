//
//  OMProfileViewController.m
//  OmnEvent
//
//  Created by elance on 8/3/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMProfileViewController.h"
#import "OMProfileCell.h"
#import "OMEditProfileViewController.h"

#import "OMEventListCell.h"
#import "OMPhotoCell.h"
@interface OMProfileViewController (){
    NSMutableArray *arrForPhoto;
    NSMutableArray *arrForEvent;

}

@end

@implementation OMProfileViewController
@synthesize is_type,targetUser;
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
    currentUser = [PFUser currentUser];
    arrForProfileInfo = [NSMutableArray array];
    arrForEvent = [NSMutableArray array];
    arrForPhoto = [NSMutableArray array];
    
    arrForFollowers = [NSMutableArray array];
    arrForFollowings = [NSMutableArray array];
    [self.navigationController setNavigationBarHidden:YES];
    is_type = 1;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self loadPhotos];
    [self loadEvents];
    [self loadFollowings];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotos
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    //    [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [mainQuery whereKey:@"PostType" equalTo:@"photo"];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            
            //            [OMGlobal showAlertTips:@"You have had not any following yet. Please post new one." title:nil];
            
            
            return;
        }
        if (!error) {
            //            [arrForEvent removeAllObjects];
            [arrForPhoto removeAllObjects];
            
            [arrForPhoto addObjectsFromArray:objects];
            //            [tblForProfile reloadData];
        }
    }];
    
}

- (void)loadEvents
{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"user" equalTo:targetUser];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    //[mainQuery fromLocalDatastore];
    // [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:targetUser];
//  [mainQuery whereKey:@"PostType" equalTo:@"event"];
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
            [tblForProfile reloadData];
        }
    }];
    
}

- (void)loadFollowings
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    
    [query whereKey:@"ToUser" equalTo:targetUser];
    [query whereKey:@"FromUser" equalTo:currentUser];
    [query includeKey:@"ToUser"];
    [query includeKey:@"FromUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [arrForFollowers removeAllObjects];
            [arrForFollowers addObjectsFromArray:objects];
            [tblForProfile reloadData];

        }
    }];
}

#pragma mark Cell delegate

- (void)editProfile:(PFUser *)user
{
    OMEditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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

        obj[@"FromUser"] = currentUser;
        obj[@"ToUser"] = _user;
        
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (succeeded) {
                [self loadFollowings];
            }
        }];

    }
    
    
}

- (void)changeType:(NSNumber*)_type
{
    is_type = [_type integerValue];
    
    [tblForProfile beginUpdates];
    
    [tblForProfile reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tblForProfile endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
        {
            switch (is_type) {
                case 0:
                    return [arrForPhoto count];
                    break;
                case 1:
                    return [arrForEvent count];
                    break;
                case 2:
                    return 1;
                    break;
                default:
                    break;
            }
            return 0;
        }
            break;
        default:
            break;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    currentUser = [PFUser currentUser];
    switch (indexPath.section) {
        case 0:
        {
            ProfileHeader *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeader"];
            
            if (cell == nil) {
                cell = [ProfileHeader sharedCell];
            }
            
            [cell setDelegate:self];
            [cell setArrForFollowers:arrForFollowers];
            [cell setUser:targetUser];
            
            //            [cell setObject:[arrForFeed objectAtIndex:indexPath.row]];
            
            return cell;
            
        }
            break;
        case 1:
        {
            ProfileMiddle *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileMiddle"];
            
            if (cell == nil) {
                cell = [ProfileMiddle sharedCell];
            }
            
            [cell setDelegate:self];
            [cell setUser:currentUser];
            
            // [cell setObject:[arrForFeed objectAtIndex:indexPath.row]];
            
            return cell;
            
        }
            break;
        case 2:
        {
            switch (is_type) {
                case 0:
                {
                    ProfilePhoto *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfilePhoto"];
                    
                    if (cell == nil) {
                        cell = [ProfilePhoto sharedCell];
                    }
                    
                    [cell setDelegate:self];
                    
                    [cell setObject:[arrForPhoto objectAtIndex:indexPath.row]];
                    
                    return cell;

                }
                    break;
                case 1:
                {
                    ProfileEvent *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileEvent"];
                    
                    if (cell == nil) {
                        cell = [ProfileEvent sharedCell];
                    }
                    
                    [cell setDelegate:self];
                    
                    [cell setObject:[arrForEvent objectAtIndex:indexPath.row]];
                    
                    return cell;

                }
                    break;
                case 2:
                {
                    ProfileInfo *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileInfo"];
                    
                    if (cell == nil) {
                        cell = [ProfileInfo sharedCell];
                    }
                    
                    [cell setDelegate:self];
                    [cell setUser:targetUser];
                    
//                    [cell setObject:[arrForPhoto objectAtIndex:indexPath.row]];
                    
                    return cell;

                }
                    break;
                default:
                    break;
            }
            return nil;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 132;
            break;
        case 1:
            return 40;
            break;
        case 2:
        {
            switch (is_type) {
                case 0:
                    return 350;
                    break;
                case 1:
                    return 108;
                    break;
                case 2:
                    return 400;
                    break;
                default:
                    break;
            }
            return 0;
        }
            break;
        default:
            break;
    }
    return 0;
}

@end
