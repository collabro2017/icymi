//
//  OMMyProfileViewController.m
//  Collabro
//
//  Created by Ellisa on 26/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMMyProfileViewController.h"
#import "OMDetailEventViewController.h"
#import "UIScrollView+TwitterCover.h"
#import "OMProfileBioCell.h"
#import "OMCustomProfileInfoView.h"
#import "OMSettingsViewController.h"
#import "OMEventListCell.h"
#import "OMProfileInfoCell.h"
#import "OMFolderListCell.h"
#import "UIImage+Resize.h"

#import "OMSocialEvent.h"

typedef enum {
    
    TableRowsEvent = 0,
    TableRowsFriend,
    TableRowsFavorite,
    TableRowsEventofFolder
    
} TableRows;

BOOL refresh_require;
@interface OMMyProfileViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    
    NSMutableArray *arrForPhoto;
    NSMutableArray *arrForEvent;
    NSMutableArray *arrForProfileInfo;
    NSMutableArray *arrForFollowers;
    NSMutableArray *arrForFollowings;
    NSMutableArray *arrForFolders;
    NSMutableArray *arrForEventofFolder;
    
    OMCustomProfileInfoView *avatarView;
}

@end

@implementation OMMyProfileViewController
@synthesize is_type,targetUser;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrForProfileInfo   = [NSMutableArray array];
    arrForEvent         = [NSMutableArray array];
    arrForPhoto         = [NSMutableArray array];
    arrForFollowers     = [NSMutableArray array];
    arrForFollowings    = [NSMutableArray array];
    arrForFolders       = [NSMutableArray array];
    arrForEventofFolder = [NSMutableArray array];
    
    //[self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view.
    
    
    NSArray *arr        = [[NSBundle mainBundle] loadNibNamed:@"OMCustomProfileInfoView" owner:self options:nil];
    avatarView          = [arr lastObject];
    [avatarView setDelegate:self];
    
    NSString *imageName;
    
    if (IS_IPAD) {
        imageName = @"cover_ipad.png";
    }else{
        imageName = @"cover.png";
    }
    
    [tblForProfile addTwitterCoverWithImage:[UIImage imageNamed:imageName] withTopView:nil withBottomView:avatarView];
    tblForProfile.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tblForProfile.frame.size.width, CHTwitterCoverViewHeight + 93)];
    
    currentSegIndex = is_type;
    _isFolderCreating = NO;
    isShowSetting = NO;
    
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [_m_FolderImgView setImage:[UIImage imageNamed:@"folder_icon"]];
    
    [self initializePopupView];
    [self initializeFolderView];
    
    [self loadEvents];
    [self loadFolders];

    // Registering notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEvents) name:kLoadProfileData object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFolders) name:kLoadFolderData object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thirdViewLoad) name:kNotificationForthDetailViewLoad object:nil];

    if (IS_IPAD) {
        CGRect frame = avatarView.segmentControlForType.frame;
        avatarView.segmentControlForType.frame = CGRectMake(frame.origin.x, frame.origin.y, SCREEN_WIDTH_ROTATED - frame.origin.x * 2, frame.size.height);
    }
    
}
/*
-(void)viewWillLayoutSubviews{
    if (IS_IPAD) {
        CGRect frame = avatarView.segmentControlForType.frame;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            avatarView.segmentControlForType.frame = CGRectMake(frame.origin.x, frame.origin.y, SCREEN_HEIGHT_ROTATED - frame.origin.x * 2, frame.size.height);
        }else{
            avatarView.segmentControlForType.frame = CGRectMake(frame.origin.x, frame.origin.y, SCREEN_WIDTH_ROTATED - frame.origin.x * 2, frame.size.height);
        }
    }
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) thirdViewLoad
{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [avatarView setUser:USER];
    targetUser = USER;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (_isPushed) {
        [btnForBack setHidden:NO];
    }
    else
    {
        [btnForBack setHidden:YES];
    }
    
}

- (void)initializePopupView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedLayer)];
    [viewForLayer setUserInteractionEnabled:YES];
    [viewForLayer addGestureRecognizer:tapGesture];
    
    viewForPopup.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [viewForPopup setHidden:NO];
    
    viewForPopup.layer.cornerRadius = 4.0f;
    viewForPopup.layer.masksToBounds = YES;
    
}

- (void)initializeFolderView
{
    /*
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedFolderViewLayer)];
    [viewForLayer setUserInteractionEnabled:YES];
    [viewForLayer addGestureRecognizer:tapGesture];
    //    viewForPopup.alpha = 0.0f;*/
    
    viewForCreateFolder.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [viewForCreateFolder setHidden:NO];
    viewForCreateFolder.layer.cornerRadius = 4.0f;
    viewForCreateFolder.layer.masksToBounds = YES;
    
    
}

- (void)touchedLayer
{
    [_m_lblFolderName resignFirstResponder];
    if (!_isFolderCreating) [self hidePopup];
}

- (void)touchedFolderViewLayer
{
    [self hideFolderViewPopup];
}

- (void)hidePopup
{
    [UIView animateWithDuration:.2f delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        viewForPopup.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    } completion:^(BOOL finished) {
        
        if (!_isFolderCreating) [viewForLayer setHidden:YES];
   }];
    
}
- (void)hideFolderViewPopup
{
    [UIView animateWithDuration:.2f delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        viewForCreateFolder.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        viewForCreateFolder.userInteractionEnabled = NO;
        
    } completion:^(BOOL finished) {
        
        [viewForLayer setHidden:YES];
        [_m_FolderImgView setImage:[UIImage imageNamed:@"folder_icon"]];
    }];
    
}


- (void)loadPhotos
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    //[mainQuery whereKey:@"createdAt" greaterThanOrEqualTo:[OMGlobal getFirstDayOfThisMonth]];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [mainQuery whereKey:@"PostType" equalTo:@"photo"];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            
            // [OMGlobal showAlertTips:@"You have had not any following yet. Please post new one." title:nil];
            
            
            return;
        }
        if (!error) {
            //[arrForEvent removeAllObjects];
            [arrForPhoto removeAllObjects];
            [arrForPhoto addObjectsFromArray:objects];
            // [tblForProfile reloadData];
        }
    }];
    
}

- (void)loadEvents
{
    NSLog(@"Running by notification center...");
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];    
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
    //[mainQuery fromLocalDatastore];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    [mainQuery whereKey:@"user" equalTo:USER];
    //[mainQuery includeKey:@"postedObjects"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
            NSLog(@"My Event load - Success!");
            [arrForEvent removeAllObjects];
            //[arrForPhoto removeAllObjects];

            [arrForEvent addObjectsFromArray:objects];
            [tblForProfile reloadData];
        }
        else
        {
            NSLog(@"My Event load - error: %@", error.description);
        }
    }];
    
}

- (void)loadFolders
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *queryForFolders = [PFQuery queryWithClassName:@"Folder"];
    [queryForFolders orderByDescending:@"createdAt"];
    [queryForFolders includeKey:@"Owner"];
    [queryForFolders whereKey:@"Owner" equalTo:USER];
    [queryForFolders findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (error == nil) {
//            NSMutableArray *tempFolderArray = [NSMutableArray array];
//            
//            for (PFObject* pfFolder in objects)
//            {
//                BOOL isExist = false;
//                
//                for(PFObject* pfExist in arrForFolders)
//                    if ([pfFolder.objectId isEqualToString:pfExist.objectId])
//                    {
//                        isExist = true;
//                        break;
//                    }
//                
//                if (!isExist)
//                    [tempFolderArray addObject:pfFolder];
//                
//            }
            
            [arrForFolders removeAllObjects];
            [arrForFolders addObjectsFromArray:objects];
            [tblForProfile reloadData];
            
            NSLog(@"Load Folders Success: %i", (int)[arrForFolders count]);
        }
        else
        {
            NSLog(@"Load Folders Error: %@", error.description);
        }
    }];
    
}

- (void)createFolder
{
    PFObject *folder = [PFObject objectWithClassName:@"Folder"];
    PFUser *currentUser = [PFUser currentUser];
    
    folder[@"Owner"] = currentUser;
    folder[@"Name"] = _m_lblFolderName.text;
    
    //image upload
    PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(_m_FolderImgView.image, 0.7)];
    folder[@"Image"] = postFile;
    
    //Request a background execution task to allow us to finish uploading the photo even if the app is background
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [folder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            NSLog(@"Success ---- Create Folder");
            [arrForFolders addObject:folder];
            [tblForProfile reloadData];
        }
        else
        {
            [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];



}

- (void)loadFollowings
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    
    [query whereKey:@"ToUser" equalTo:targetUser];
    [query whereKey:@"FromUser" equalTo:USER];
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
//    OMEditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
//    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
        
        obj[@"FromUser"] = USER;
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
    //is_type = [_type integerValue];
    currentSegIndex = [_type integerValue];
    
    [tblForProfile reloadData];
//  [tblForProfile beginUpdates];
//    
//    [tblForProfile reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [tblForProfile endUpdates];
}


#pragma mark - UITableViewDataSource

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows)currentSegIndex) {
        case TableRowsEvent:
        {
            OMEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventListCell];
            
            if (!cell) {
                cell = [[OMEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventListCell];
            }
            
            [cell setDelegate:self];
            [cell setObject:[arrForEvent objectAtIndex:indexPath.row]];
            
            return cell;
        }
            break;
        case TableRowsFriend:
        {
            OMProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileInfoCell];
            
            if (!cell) {
                
                cell = [[OMProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileInfoCell];
                
            }
            [cell setDelegate: self];
            [cell setUser:USER];
            
            return cell;
            
        }
            break;
        case TableRowsFavorite:
        {
            OMFolderListCell * cell = [tableView dequeueReusableCellWithIdentifier:kFolderListCell];
            
            if (!cell) {
                cell = [[OMFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFolderListCell];
            }
            
            [cell setDelegate:self];
            [cell setFolderType:kTypeOwner];
            [cell setObject:[arrForFolders objectAtIndex:indexPath.row]];
            
            return cell;
            
        }
            break;
        case TableRowsEventofFolder:
        {
            OMEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventListCell];
            
            if (!cell) {
                cell = [[OMEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventListCell];
            }
            
            [cell setDelegate:self];
            [cell setObject:[arrForEventofFolder objectAtIndex:indexPath.row]];
            
            return cell;
        }
            break;

        default:
            break;
    }
    
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch ((TableRows)currentSegIndex) {
        case TableRowsEvent:
            return nil;
            break;
        case TableRowsFriend:
            return nil;
            break;
        case TableRowsFavorite:
        {
            CGRect frame = [[UIScreen mainScreen] bounds];
            UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 5, 50, 50)];
            [addButton setImage:[UIImage imageNamed:@"btn_add_folder"] forState:UIControlStateNormal];
            
            [addButton addTarget:self
                       action:@selector(addFolder)
                       forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 30)];
            title.text = @"Please create new Folder";
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [headerView addSubview:title];
            [headerView addSubview:addButton];
        
            return headerView;
        }
            break;
        case TableRowsEventofFolder:
        {
            CGRect frame = [[UIScreen mainScreen] bounds];
            UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 5, 50, 50)];
            [addButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
            
            [addButton addTarget:self
                          action:@selector(backToFolder)
                forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 30)];
            NSString* strFolderName = [[arrForFolders objectAtIndex:nCurrentFolderIdx] objectForKey:@"Name"];
            title.text = [NSString stringWithFormat:@"Event of %@", strFolderName];
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [headerView addSubview:title];
            [headerView addSubview:addButton];
            
            return headerView;
        }
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch ((TableRows)currentSegIndex) {
        case TableRowsEvent:
            return 0;
            break;
        case TableRowsFriend:
            return 0;
            break;
        case TableRowsFavorite:
            return 50;
            break;
        case TableRowsEventofFolder:
            return 50;
            break;
        default:
            return 0;
            break;
    }
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch ((TableRows)currentSegIndex) {
        case TableRowsEvent:
        {
            return arrForEvent.count;
        }
            break;
        case TableRowsFriend:
        {
            return 1;
        }
            break;
        case TableRowsFavorite:
        {
            return arrForFolders.count;
            
        }
            break;
        case TableRowsEventofFolder:
        {
            return arrForEventofFolder.count;
        }
            break;
        default:
            break;
    }
    
    return arrForEvent.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows) currentSegIndex) {
        case TableRowsEvent:
        {
            
            return 108;
        }
            break;
        case TableRowsFriend:
        {
            return 540;
        }
            break;
        case TableRowsFavorite:
        {
            return 108;
            
        }
            break;
        case TableRowsEventofFolder:
        {
            return 108;
        }
            break;
        default:
            break;
    }
    
    return 108;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((TableRows) currentSegIndex) {
        case TableRowsEvent:
        {
            OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
            
            PFObject *selectedObj = [arrForEvent objectAtIndex:indexPath.row];
            OMSocialEvent *socialObj = (OMSocialEvent*)selectedObj;
            socialObj.badgeCount = 0;
            
            [GlobalVar getInstance].gEventIndex = -1;
            [detailEventVC setCurrentObject:socialObj];
            [self.navigationController pushViewController:detailEventVC animated:YES];

        }
            break;
        case TableRowsFriend:
        {
        }
            break;
        case TableRowsFavorite:
        {
            [arrForEventofFolder removeAllObjects];
            PFObject* pfCurrentFolder = [arrForFolders objectAtIndex:indexPath.row];
            
            if (pfCurrentFolder[@"Events"])
            {
                nCurrentFolderIdx = (int)indexPath.row;
                NSMutableArray* eventIDs = pfCurrentFolder[@"Events"];
            
                for( NSString* eventID in eventIDs)
                {
                    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Event"];
                    
                    //[mainQuery fromLocalDatastore];
                    [mainQuery orderByDescending:@"createdAt"];
                    [mainQuery includeKey:@"user"];
                    [mainQuery whereKey:@"objectId" equalTo:eventID];
                    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (error == nil) {
                            if([objects count] == 0) return;
                            [arrForEventofFolder addObjectsFromArray:objects];
                            currentSegIndex = TableRowsEventofFolder;
                            [tblForProfile reloadData];
                        }
                    }];
                }
            }
            
        }
            break;
        case TableRowsEventofFolder:
        {
            int nEventCount = (int)[arrForEventofFolder count];
            if (nEventCount > 0)
            {
                OMDetailEventViewController *detailEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailEventVC"];
            
                [GlobalVar getInstance].gEventIndex = -1;
                [detailEventVC setCurrentObject:[arrForEventofFolder objectAtIndex:indexPath.row]];
            
                [self.navigationController pushViewController:detailEventVC animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
}
- (IBAction)settingAction:(id)sender {
    
    if (!isShowSetting)
    {
        [viewForLayer setHidden:NO];
    
    
        [UIView animateWithDuration:0.2f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewForPopup.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
        isShowSetting = YES;
    }
    else
    {
        isShowSetting = NO;
        
        [self hidePopup];
    }
   
}

- (IBAction)backAction:(id)sender {
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutAction:(id)sender {
    
    [self hidePopup];
    [TABController signOut];
}

- (IBAction)profileAction:(id)sender {
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    
    OMSettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    [ tab presentViewController:nav animated:YES completion:^{
        
        [self hidePopup];
    }];

}

- (IBAction)createFolderAction:(id)sender {
    
    NSString *tempStr = _m_lblFolderName.text;
    tempStr = [tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([tempStr isEqualToString:@""] || tempStr.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must input a folder's name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    _isFolderCreating = NO;
    [self hideFolderViewPopup];
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    [MBProgressHUD showMessag:@"Creating Folder..." toView:self.view];
    [self createFolder];

}

- (IBAction)cancelCreateAction:(id)sender {
    
    _isFolderCreating = NO;
    [self hideFolderViewPopup];
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark add Folder
- (void)addFolder
{
    _isFolderCreating = YES;
    [viewForLayer setHidden:NO];
    _m_lblFolderName.text = @"";
    
    [UIView animateWithDuration:0.2f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewForCreateFolder.transform = CGAffineTransformIdentity;
        viewForCreateFolder.userInteractionEnabled = YES;
    } completion:^(BOOL finished) {
    }];
    
}

- (IBAction)changeFolderImage:(id)sender {
    
    [_m_lblFolderName resignFirstResponder];

    [self addChildViewController:imagePicker];
    [imagePicker didMoveToParentViewController:self];
    [self.view addSubview:imagePicker.view];
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:YES];
    
}

- (void) backToFolder
{
    currentSegIndex = TableRowsFavorite;
    [tblForProfile reloadData];
}

#pragma mark - UITextField Controller Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //image = [image resizedImageToSize:CGSizeMake(AVATAR_SIZE, AVATAR_SIZE)];
    
    [_m_FolderImgView setImage:image];
    
    //[picker dismissViewControllerAnimated:YES completion:^{}];
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:NO];
    

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [picker dismissViewControllerAnimated:YES completion:^{
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//        
//    }];
    
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:NO];

}

@end
