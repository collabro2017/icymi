//
//  OMEventCommentViewController.m
//  Collabro
//
//  Created by elance on 8/12/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMEventCommentViewController.h"
#import "Cells/OMCommentCell.h"
#import "YFInputBar.h"

#import "OMFeedOtherCommentCell.h"


@interface OMEventCommentViewController ()<UITextFieldDelegate, YFInputBarDelegate>
{
    NSMutableArray *arrForComment;
    NSMutableArray *arrForCommentUsers;
    NSMutableArray *arrForCommentContents;
    
    YFInputBar *inputBar;
}

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OMEventCommentViewController
@synthesize currentObject;

- (void)reload:(__unused id)sender
{
    
    [(UIRefreshControl*)sender beginRefreshing];
    PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
    [query whereKey:@"targetEvent" equalTo:currentObject];
    [query includeKey:@"Commenter"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [(UIRefreshControl*)sender endRefreshing];
        if ([objects count] == 0 || !objects) {
            return;
        }
        [arrForComment removeAllObjects];
        [arrForComment addObjectsFromArray:objects];
        
        [self loadController];
        [tblForComment reloadData];
    }];
    
}


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
    arrForComment = [NSMutableArray array];
    arrForCommentUsers = [NSMutableArray array];
    arrForCommentContents = [NSMutableArray array];
    
    currentUser = [PFUser currentUser];
    //Input Bar
    
    inputBar = [[YFInputBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_ROTATED - 50, SCREEN_WIDTH_ROTATED, 50)];
    inputBar.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:1];
    inputBar.delegate = self;
    inputBar.textField.delegate = self;
    inputBar.clearInputWhenSend = YES;
    inputBar.resignFirstResponderWhenSend = YES;
    
    [self.view addSubview:inputBar];
    
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tblForComment.frame.size.width, 100.0f)];
    
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    [tblForComment addSubview:self.refreshControl];
}

-(void)viewWillLayoutSubviews{
    if (IS_IPAD) {
        
        CGRect textFrame = inputBar.textField.frame;
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            inputBar.frame = CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50);
            inputBar.textField.frame = CGRectMake(textFrame.origin.x, 10, inputBar.frame.size.width - 70, 24);
            inputBar.sendBtn.frame = CGRectMake(inputBar.frame.size.width - 60, 0, 60, 50);
            
        }else{
            inputBar.frame = CGRectMake(0, SCREEN_WIDTH - 50, SCREEN_HEIGHT, 50);
            inputBar.textField.frame = CGRectMake(textFrame.origin.x, 10, inputBar.frame.size.width - 70, 24);
            inputBar.sendBtn.frame = CGRectMake(inputBar.frame.size.width - 60, 0, 60, 50);
            
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Comments";
    [self loadComments];
    [self loadController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [inputBar.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadController
{
    if (currentObject[@"commenters"]) {
        arrForCommentUsers = currentObject[@"commenters"];
        
    }
    if (currentObject[@"commentsArray"]) {
        arrForCommentContents = currentObject[@"commentsArray"];
    }
    
}

- (void)loadComments {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
    [query whereKey:@"targetEvent" equalTo:currentObject];
    [query includeKey:@"Commenter"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([objects count] == 0 || !objects) {
            return;
        }
        
        [arrForComment removeAllObjects];
        [arrForComment addObjectsFromArray:objects];
        [tblForComment reloadData];
        NSLog(@"EventCommentViewController: Loaded eventcomments");
    }];
}

- (void)backAction {
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Delegate method of UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:inputBar.textField]) {
        if (textField.text.length < MAX_COMMENT_LIMIT || [string isEqualToString:@""]) {
            return YES;
        }
    }    
    return NO;
}

#pragma mark YFInput Bar Delegate

- (void)inputBar:(YFInputBar *)_inputBar sendBtnPress:(UIButton *)sendBtn withInputString:(NSString *)str
{
    if (!str || str.length <= 0) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFObject *commentObject = [PFObject objectWithClassName:@"EventComment"];
    commentObject[@"Commenter"] = currentUser;
    NSLog(@"%@",currentObject.objectId);
    commentObject[@"targetEvent"] = currentObject;
    commentObject[@"Comments"] = str;
    [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            [arrForCommentUsers addObject:currentUser];
            [arrForCommentContents addObject:str];
            [currentObject setObject:arrForCommentUsers forKey:@"commenters"];
            [currentObject setObject:arrForCommentContents forKey:@"commentsArray"];
            
            [currentObject saveInBackgroundWithBlock:^(BOOL _succeeded, NSError *_error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (_succeeded) {
                    [self loadComments];
                    [self loadController];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadCurrentEventData object:nil];
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadPhotoData object:nil];
                    
                    NSLog(@"EventCommentViewController: Updated EventComments");
                    // for badge
                    NSMutableArray * arrPostLookedFlags = [NSMutableArray array];
                    arrPostLookedFlags = [currentObject[@"TagFriends"] mutableCopy];
                    PFUser *eventUser = currentObject[@"user"];
                    
                    if(![eventUser.objectId isEqualToString:currentUser.objectId])
                    {
                        [arrPostLookedFlags addObject:eventUser.objectId];
                        
                    }
                    if ([arrPostLookedFlags containsObject:currentUser.objectId]) {
                        [arrPostLookedFlags removeObject:currentUser.objectId];
                    }
                    
                    currentObject[@"eventBadgeFlag"] = arrPostLookedFlags;
                    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
                    if(appDel.network_state)
                    {
                        NSLog(@"Badge for event comments of Post Added");
                        [currentObject saveInBackground];
                    }
                    
                    
                }
                else if (_error)
                {
                    [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                    
                    [commentObject deleteInBackground];
                }
            }];
            
        }
        else if (error)
        {
            [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
        }
        
    }];
}
#pragma mark - UIScrollView Delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([inputBar.textField isFirstResponder]) {
        
        if (velocity.y < -0.2f) {
            
            [inputBar resignFirstResponder];
        }
        
    }
}

#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OMFeedOtherCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedOtherCommentCell];
    
    if (!cell) {
        cell = [[OMFeedOtherCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedOtherCommentCell];
    }
    [cell setDelegate:self];
    [cell configurateCell:[arrForComment objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForComment count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *obj = [arrForComment objectAtIndex:indexPath.row];
    return [OMGlobal heightForCellWithPost:obj[@"Comments"]]+ 20.0f;
}

@end
