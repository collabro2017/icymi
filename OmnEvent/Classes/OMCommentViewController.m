//
//  OMCommentViewController.m
//  OmnEvent
//
//  Created by elance on 7/27/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMCommentViewController.h"
#import "Cells/OMCommentCell.h"
#import "YFInputBar.h"
#import "OMFeedOtherCommentCell.h"
@interface OMCommentViewController ()<YFInputBarDelegate, UITextFieldDelegate>
{
    
    NSMutableArray *arrForComment;
    NSMutableArray *arrForCommentUsers;
    NSMutableArray *arrForCommentObject;
    YFInputBar *inputBar;
}
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OMCommentViewController
@synthesize currentObject;

- (void)reload:(__unused id)sender
{
    
    [(UIRefreshControl*)sender beginRefreshing];
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"postMedia" equalTo:currentObject];
    [query includeKey:@"Commenter"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [(UIRefreshControl *)sender endRefreshing];
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
    arrForCommentObject = [NSMutableArray array];
    currentUser = [PFUser currentUser];
    //Input Bar
    
    inputBar = [[YFInputBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT_ROTATED - 50, SCREEN_WIDTH_ROTATED, 50)];
    inputBar.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:1];
    inputBar.delegate = self;
    inputBar.textField.delegate = self;
    inputBar.clearInputWhenSend = YES;
    inputBar.resignFirstResponderWhenSend = YES;    
    [self.view addSubview:inputBar];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    ///\\
    
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [inputBar.textField becomeFirstResponder];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    if (self.isMovingFromParentViewController) {
//        [self.navigationController setNavigationBarHidden:YES];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadController
{
    if (currentObject[@"commentsUsers"]) {
        arrForCommentUsers = currentObject[@"commentsUsers"];

    }
    if (currentObject[@"commentsArray"]) {
        
        arrForCommentObject = currentObject[@"commentsArray"];
    }
    
}

- (void)loadComments
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"postMedia" equalTo:currentObject];
    [query includeKey:@"Commenter"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        if ([objects count] == 0 || !objects) {
            return;
        }
        [arrForComment removeAllObjects];
        
        
        /*
        NSMutableArray *commentUsersTemp = [NSMutableArray array];
        if(currentObject[@"commentsUsers"] != nil && [currentObject[@"commentsUsers"] count] > 0 )
        {
            for (PFUser *user in currentObject[@"commentsUsers"]) {
                [commentUsersTemp addObject:user[@"objectId"]];
            }
        }
       
        for (PFObject *commentObj in objects)
        {
            PFUser *commentUser = commentObj[@"Commenter"];
            for(NSString *objId in commentUsersTemp)
            {
                if([objId isEqualToString:commentUser.objectId])
                {
                    [arrForComment addObject:commentObj];
                    break;
                }
            }
        }
       */
        [arrForComment addObjectsFromArray:objects];
        
        [tblForComment reloadData];
        
    }];
}

- (void)backAction
{
    
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
    
    PFObject *commentObject = [PFObject objectWithClassName:@"Comments"];
    
    commentObject[@"Commenter"] = currentUser;
    
    NSLog(@"comment input on commentVC: %@",currentObject.objectId);
    commentObject[@"postMedia"] = currentObject;
    commentObject[@"Comments"] = str;
    [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            [arrForCommentUsers addObject:currentUser];
            [arrForCommentObject addObject:commentObject];
            [currentObject setObject:arrForCommentUsers forKey:@"commentsUsers"];
            [currentObject setObject:arrForCommentObject forKey:@"commentsArray"];
            
            
            // for badge
            
            NSMutableArray *arrEventTagFriends = [NSMutableArray array];
            PFObject *eventObj = currentObject[@"targetEvent"];
            arrEventTagFriends = [eventObj[@"TagFriends"] mutableCopy];
            PFUser *eventUser = eventObj[@"user"];
            
            NSLog(@"Current user == %@", currentUser.objectId);
            if(![eventUser.objectId isEqualToString:currentUser.objectId])
            {
                [arrEventTagFriends addObject:eventUser.objectId];
               
            }
            if ([arrEventTagFriends containsObject:currentUser.objectId]) {
                [arrEventTagFriends removeObject:currentUser.objectId];
            }
            
            currentObject[@"usersBadgeFlag"] = arrEventTagFriends;
            NSLog(@"Badge for comments of Post Added");

            [currentObject saveInBackgroundWithBlock:^(BOOL _succeeded, NSError *_error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (_succeeded) {
                    [self loadComments];
                    [self loadController];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
//                  [[NSNotificationCenter defaultCenter] postNotificationName:kLoadCurrentEventData object:nil];
                    
                    
                }
                else if (_error)
                {
                    //[OMGlobal showAlertTips:_error.localizedDescription title:@"Oops!"];
                    NSLog(@"comment Error: %@", _error.localizedDescription);
                    [commentObject deleteEventually];
                }

            }];
            
            //---------------------------------------------------//
            [self backAction];
            //---------------------------------------------------//
        }
        else if (error)
        {
            //[OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
            NSLog(@"comment Error: %@", error.localizedDescription);
            [commentObject deleteEventually];
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
    
    NSString *strComment = [obj[@"Comments"] stringByReplacingOccurrencesOfString:@"  " withString:@""];
    strComment = [strComment stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return [OMGlobal heightForCellWithPost:strComment]+ 20.0f;
}
@end
