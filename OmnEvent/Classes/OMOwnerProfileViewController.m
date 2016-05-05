//
//  OMOwnerProfileViewController.m
//  OmnEvent
//
//  Created by elance on 7/25/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMOwnerProfileViewController.h"
#import "OMProfileCell.h"

#import "OMEditProfileViewController.h"

#import "OMEventListCell.h"
#import "OMPhotoCell.h"

@interface OMOwnerProfileViewController ()
{
    
    NSMutableArray *arrForPhoto;
    NSMutableArray *arrForEvent;
}

@end

@implementation OMOwnerProfileViewController
@synthesize arrForProfileInfo;
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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadPhotos];
    [self loadEvents];
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
    [innerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    //    [mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [mainQuery whereKey:@"PostType" equalTo:@"event"];
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

#pragma mark Cell delegate

- (void)editProfile:(PFUser *)user
{
    OMEditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
            return [arrForPhoto count];
            
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
//            [cell.btnForFollow addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
            [cell setDelegate:self];
            [cell setUser:currentUser];
            
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
            
            //            [cell setObject:[arrForFeed objectAtIndex:indexPath.row]];
            
            return cell;

        }
            break;
        case 2:
        {
            OMPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMPhotoCell"];
            
            if (cell == nil) {
                cell = [[OMPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OMPhotoCell"];
            }
            [cell setDelegate:self];
            
            [cell setObject:[arrForPhoto objectAtIndex:indexPath.row]];
            
            return cell;

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
            return 350;
            break;
        default:
            break;
    }
    return 0;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editAction:(id)sender {
    OMEditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

}
@end
