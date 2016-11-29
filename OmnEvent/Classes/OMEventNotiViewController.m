//
//  OMEventNotiViewController.m
//  ICYMI
//
//  Created by lion on 11/28/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMEventNotiViewController.h"
#import "OMNotiTextCell.h"
#import "OMNotiMediaCell.h"

@interface OMEventNotiViewController (){
    NSMutableArray *arrNotifyActivity;
}

@end

@implementation OMEventNotiViewController
@synthesize notiTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    notiTable.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self initializeNavBar];
    [self getNotifyActivities];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeNavBar
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    lblTitle.text = _event[@"eventname"];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont boldSystemFontOfSize:17.0f];
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.numberOfLines = 0;
    self.navigationItem.titleView = lblTitle;
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier1 = @"NotiMediaCell";
    static NSString *cellIdentifier2 = @"NotiTextCell";
    
    PFObject *tempObj = [arrNotifyActivity objectAtIndex:indexPath.row];
    
    if ([tempObj[@"postType"] isEqualToString:@"text"]){    // text
        
        OMNotiTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[OMNotiTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        
        //Displaying username and timedate.
        PFUser *user = tempObj[@"user"];
        [cell.lblUser setText:user.username];
        [cell.lblUser setTextColor:[UIColor redColor]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        
        NSString *str_date = [dateFormat stringFromDate:tempObj.createdAt];
        [cell.lblDateTime setText:str_date];
        
        //Displaying title.
        [cell.lblActivityTitle setText:tempObj[@"title"]];
        
        return cell;
        
    }else{  // photo, audio and video.
        
        OMNotiMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[OMNotiMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        }
        
        //Displaying username and timedate.
        PFUser *user = tempObj[@"user"];
        [cell.lblUser setText:user.username];
        [cell.lblUser setTextColor:[UIColor redColor]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        
        NSString *str_date = [dateFormat stringFromDate:tempObj.createdAt];
        [cell.lblDateTime setText:str_date];
        
        //Displaying title.
        [cell.lblActivityTitle setText:tempObj[@"title"]];
        
        //Displaying post image.
        PFFile *postImgFile = (PFFile *)tempObj[@"thumbImage"];
        
        if (postImgFile) {
            [cell.imgActivity setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
        }
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *tempObj = [arrNotifyActivity objectAtIndex:indexPath.row];
    [self removeNotificationBadge:tempObj];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrNotifyActivity count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *tempObj = [arrNotifyActivity objectAtIndex:indexPath.row];
    if ([tempObj[@"postType"] isEqualToString:@"text"])
        return 60.0f;
    else
        return 70.0f;
}

-(void)getNotifyActivities{
    
    [GlobalVar getInstance].isPosting = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [GlobalVar getInstance].isPostLoading = YES;
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"targetEvent" equalTo:_event];
    
    [mainQuery includeKey:@"user"];
    [mainQuery orderByDescending:@"createdAt"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [GlobalVar getInstance].isPostLoading = NO;
        [GlobalVar getInstance].isPosting = NO;
        
        if (error == nil) {
            arrNotifyActivity = [NSMutableArray array];
            if([objects count] > 0) {
                for (PFObject *tObj in objects) {
                    NSMutableArray *temp = [[NSMutableArray alloc] init];
                    temp = [tObj[@"usersBadgeFlag"] mutableCopy];
                    if ([temp containsObject:[PFUser currentUser].objectId]) {
                        [arrNotifyActivity addObject:tObj];
                    }
                }
                
            }
            
            [notiTable reloadData];
        }
    }];
}

-(void)removeNotificationBadge:(PFObject*)obj{
    PFUser *self_user = [PFUser currentUser];
    
    if (_event.badgeCount > 0) {
        
        if(obj != nil)
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            temp = [obj[@"usersBadgeFlag"] mutableCopy];
            
            if ([temp containsObject:self_user.objectId])
            {
                [GlobalVar getInstance].isPosting = YES;
                
                [temp removeObject:self_user.objectId];
                obj[@"usersBadgeFlag"] = temp;
                [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil)
                    {
                        [arrNotifyActivity removeObject:obj];
                        if ([arrNotifyActivity count] == 0) {
                            [self backAction];
                        }
                        [notiTable reloadData];
                        
                        [GlobalVar getInstance].isPosting = NO;
                    }
                }];
                
                if(_event.badgeCount >= 1) _event.badgeCount -= 1;
                [[GlobalVar getInstance].gArrEventList replaceObjectAtIndex:_curEventIndex withObject:_event];
                
            }
            
            
        }
    }else{
        [self backAction];
    }
}
@end
