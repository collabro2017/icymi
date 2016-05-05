//
//  OMFindFriendViewController.m
//  Collabro
//
//  Created by elance on 8/13/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMFindFriendViewController.h"
#import "OMProfileViewController.h"
#import "OMFriendListCell.h"

@interface OMFindFriendViewController ()

@end

@implementation OMFindFriendViewController

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
//    [self.navigationController setNavigationBarHidden:NO];
    arrForFriends = [NSMutableArray array];
    arrForUsername = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
 
//    [tblForSearchResult setFrame:CGRectMake(0, 100, 320, tblForSearchResult.frame.size.height)];
    
    [self addSearchView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriendsData:(NSString *)text
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containsString:text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            
            [arrForFriends removeAllObjects];
            
            [arrForFriends addObjectsFromArray:objects];
            [tblForSearchResult reloadData];
        }
    }];
}

- (void)addSearchView
{
    searchBar = [[INSSearchBar alloc] initWithFrame:CGRectMake(10, 1, CGRectGetWidth(self.view.bounds) - 20.0, 34.0)];
	
	[searchView addSubview:searchBar];
    searchBar.delegate = self;
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrForFriends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OMFriendListCell";
    OMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[OMFriendListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    [cell setObject:[arrForFriends objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSString *title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//    self.title = title;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - search bar delegate

- (CGRect)destinationFrameForSearchBar:(INSSearchBar *)_searchBar
{
	return CGRectMake(20.0, 1, CGRectGetWidth(self.view.bounds) - 40.0, 34.0);
}

- (void)searchBar:(INSSearchBar *)_searchBar willStartTransitioningToState:(INSSearchBarState)destinationState
{
	// Do whatever you deem necessary.
}

- (void)searchBar:(INSSearchBar *)_searchBar didEndTransitioningFromState:(INSSearchBarState)previousState
{
	// Do whatever you deem necessary.
}

- (void)searchBarDidTapReturn:(INSSearchBar *)_searchBar
{
	// Do whatever you deem necessary.
	// Access the text from the search bar like searchBar.searchField.text
    

    [_searchBar.searchField resignFirstResponder];
}

- (void)searchBarTextDidChange:(INSSearchBar *)_searchBar
{
    
    if (![_searchBar.searchField.text isEqualToString:@""]) {
        [self loadFriendsData:_searchBar.searchField.text];

    }
    else
    {
        
    }

	// Do whatever you deem necessary.
	// Access the text from the search bar like searchBar.searchField.text
}


- (IBAction)showSearchBar:(id)sender {
    
    
}

@end
