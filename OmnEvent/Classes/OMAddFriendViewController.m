//
//  OMAddFriendViewController.m
//  OmnEvent
//
//  Created by elance on 7/23/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMAddFriendViewController.h"
#import "UIImageView+AFNetworking.h"
@interface OMAddFriendViewController ()

@end

@implementation OMAddFriendViewController
@synthesize arrForFriends;
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
    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Follower"];
    [mainQuery whereKey:@"FromUser" equalTo:[PFUser currentUser]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"ToUser"];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!objects) {
            return;
        }
        if (!error) {
            [arrForFriends removeAllObjects];
            [arrForFriends addObjectsFromArray:objects];
            
            [tblForFriends reloadData];
        }
    }];
}
#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFObject *obj = [arrForFriends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = obj[@""];
    
//    PFFile *postImgFile = (PFFile *)obj[@"image"];
//    if (postImgFile) {
//        [cell.imageView setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForFriends count];
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

@end
