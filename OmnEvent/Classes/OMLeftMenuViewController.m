//
//  OMLeftMenuViewController.m
//  OmnEvent
//
//  Created by elance on 7/29/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMLeftMenuViewController.h"
#import "OMProfileViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimator.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

@interface OMLeftMenuViewController ()

@property (nonatomic, assign)BOOL slideOutAnimationEnabled;
@end

@implementation OMLeftMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    return [super initWithCoder:aDecoder];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.separatorColor = [UIColor lightGrayColor];
    PFUser *currentUser = [PFUser currentUser];
    lblForUsername.text = currentUser.username;
    //display avatar image
    [OMGlobal setCircleView:imageViewForProfile borderColor:[UIColor greenColor]];
    if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:imageViewForProfile displayImgView:imageViewForProfile];
        }

    }
    else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:imageViewForProfile displayImgView:imageViewForProfile];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 5;
            break;
            
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc;
    BOOL skip = YES;
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                }
                    break;
                case 1:
                    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendListVC"];
                    break;
                case 2:
                {
                    OMProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OMProfileVC"];
                    profileVC.is_type = 0;
                    [profileVC setTargetUser:[PFUser currentUser]];
                    
                    vc = profileVC;

                }
                    break;
                case 3:
                    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FindFriendVC"];
                    break;
                case 4:
                {
                    skip = NO;
                    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];
                }
                    break;
                case 5:
                    break;
                case 6:
                {
                    
                }
                    break;
                case 7:
                {
                    
                }
                    break;
                case 8:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    if (skip)
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:self.slideOutAnimationEnabled andCompletion:nil];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

@end
