//
//  OMDetailEventViewController.m
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMDetailEventViewController.h"
#import "OMIndividualEventCell.h"
#import "OMNewPostViewController.h"
#import "OMCommentViewController.h"
#import "OMEventCommentViewController.h"
#import "UIScrollView+TwitterCover.h"
#import "UIImageView+AFNetworking.h"
#import "OMOtherProfileViewController.h"
#import "OMTagListViewController.h"
#import "OMAdditionalTagViewController.h"
#import <Social/Social.h>

#import "OMLikersViewController.h"
#import "OMMyProfileViewController.h"
#import "OMTagFolderViewController.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
//////
#import "OMFeedControlCell.h"
#import "OMFeedHeaderCell.h"
#import "OMFeedImageCell.h"
#import "OMFeedCommentCell.h"
#import "OMMediaCell.h"
#import "OMDetailHeaderCell.h"
#import "OMDescriptionCell.h"
#import "OMTextCell.h"
#import "BBBadgeBarButtonItem.h"
#import "UIImage+Resize.h"
#import "PDFRenderer.h"
#import <QuickLook/QuickLook.h>
#import "PDFRenderer.h"
#import "OMAppDelegate.h"
#import "Reachability.h"
//--------------------------------------------------
#import "OMEventNotiViewController.h"

#define kTag_NewPhoto           4000
#define kTag_NewVideo           5000
#define kTag_NewAudio           6000
#define kTag_Share              7000
#define kTag_Share1             8000
#define kTag_EventShare         2000
#define kTag_EventShareGuest    2001
#define kTag_AddMediaAfter      4001

#define kTag_TextShare          9000
#define kTag_TextShare1         10000

#define kTag_PDF                20000
#define kTag_DupEvent           20001

#define kTag_PDF_Select         30000
#define kTag_PDF_Profile_Mode   40000


@interface OMDetailEventViewController ()<AVAudioPlayerDelegate,OMAdditionalTagViewControllerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate, OMTagFolderViewControllerDelegate, UIViewControllerTransitioningDelegate, UIPickerViewDataSource,UIPickerViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, OMEventNotiViewControllerDelegate>
{
    
    AVAudioPlayer *audioPlayer;
    
    UIPickerView *Picker;
    UIView *customPickerView;
    CGRect rectForPickerView;
    
    NSString* is_type;
    
    NSURL *pdfURL;
    BOOL editable_flag;
    
    NSUInteger real_parse_data_num;
    NSUInteger offline_data_num;
    NSMutableArray *offlineURLs;
    
    NSTimer *autoRefreshTimer;
    
    NSMutableArray *arrPrevTagFriends;
    
    // temp array for geolocation editing
    NSMutableArray *arrTemp;
    NSMutableArray *arrTargetForGeo;
    
    BOOL modeForExport;
    int selectedPostOrder;
    
    NSString *exportModeOfPDF;
    NSString *profileModeInPDF;
}

@property (weak, nonatomic) IBOutlet UITableView *tblForDetailList;

@property (weak, nonatomic) IBOutlet UIView *doneView;

@property (weak, nonatomic) IBOutlet UIButton *btnDoneForExport;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelForExport;

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OMDetailEventViewController
@synthesize currentObject, dic, tblForDetailList, curEventIndex;
@synthesize doneView, btnDoneForExport;


- (IBAction)onCancelForExport:(id)sender {
    
    [doneView setHidden:YES];
    modeForExport = NO;
    [tblForDetailList reloadData];
    [GlobalVar getInstance].isPosting = NO;
    
    [[GlobalVar getInstance].gArrPostList removeAllObjects];
    [[GlobalVar getInstance].gArrSelectedList removeAllObjects];
    
}


- (void)reload:(__unused id)sender
{
    [(UIRefreshControl*)sender beginRefreshing];
    [GlobalVar getInstance].isPosting = YES;
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"targetEvent" equalTo:currentObject];
    [mainQuery includeKey:@"user"];
    [mainQuery includeKey:@"commentsArray"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery orderByDescending:@"postOrder"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [GlobalVar getInstance].isPosting = NO;
        [(UIRefreshControl*)sender endRefreshing];
        if (error || !objects) {
            return;
        }
        else
        {
            [arrForDetail removeAllObjects];
            [arrForDetail addObjectsFromArray:objects];
            
            OMAppDelegate* appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
            offline_data_num = appDel.m_offlinePosts.count;
            
            for (NSUInteger i = 0; i < offline_data_num; i ++) {
                PFObject *temp_object = [appDel.m_offlinePosts objectAtIndex:i];
                PFObject *temp_targetEventObject = temp_object[@"targetEvent"];
                
                if ([temp_targetEventObject.objectId isEqualToString:currentObject.objectId]) {
                    [arrForDetail addObject:temp_object];
                    [offlineURLs addObject:[appDel.m_offlinePostURLs objectAtIndex:i]];
                }
            }
            
            //Sort Posts on postOrder
            if (appDel.m_offlinePosts.count > 0) {
                [arrForDetail sortUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
                    NSNumber *postOrder1 = obj1[@"postOrder"];
                    NSNumber *postOrder2 = obj2[@"postOrder"];
                    if (postOrder1.intValue > postOrder2.intValue) {
                        return NSOrderedAscending;
                    } else if (postOrder1.intValue < postOrder2.intValue) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedSame;
                }];
            }
            
            if (isActionSheetReverseSelected) {
                arrForDetail = [[[arrForDetail reverseObjectEnumerator] allObjects] mutableCopy];
            }
            
            [tblForDetailList reloadData];
        }
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
    [self initializeNavBar];
    [self addRefreshControlToTable];

    // Do any additional setup after loading the view.
    
    // global array Init
    [GlobalVar getInstance].gArrPostList = [[NSMutableArray alloc] init];
    [GlobalVar getInstance].gArrSelectedList = [[NSMutableArray alloc] init];
    
    arrTemp = [NSMutableArray array];
    arrTargetForGeo = [NSMutableArray array];
    
    [doneView setHidden:YES];
    modeForExport = NO;
    
    // Initialize variables
    arrForDetail = [[NSMutableArray alloc] init];
    offlineURLs  = [[NSMutableArray alloc] init];
    arrPrevTagFriends = [[NSMutableArray alloc] init];
    
    imagePicker  = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    isVideoAdd = NO;
    
    is_type = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadContents) name:kLoadComponentsData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCurrentObject) name:kLoadCurrentEventData object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelForExport:) name:kExportCancel object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstViewLoad) name:kNotificationFirstDetailViewLoad object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:kNotificationKeyboardShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:kNotificationKeyboardHide object:nil];
    
    [GlobalVar getInstance].isPosting = NO;
    currentMediaCell = nil;
    curEventIndex = [GlobalVar getInstance].gEventIndex;
    
    [self initializeControls];
    
    // DetailEvent contents Loading...
    [self loadContents];
    arrPrevTagFriends = [currentObject[@"TagFriends"] copy];
}

- (void)firstViewLoad {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
    
    if (appDel.network_state) {
        UIImage *btnImage = [UIImage imageNamed:@"online_state.png"];
        [btnForNetState setImage:btnImage forState:UIControlStateNormal];
    } else {
        UIImage *btnImage = [UIImage imageNamed:@"offline_state.png"];
        [btnForNetState setImage:btnImage forState:UIControlStateNormal];
    }
    
    autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
    
    //---------------------------------------------//
    [self initializeBadges];
    
    //processing bagde
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processBadges:) name:@"descount_bagdes" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [autoRefreshTimer invalidate];
    autoRefreshTimer = nil;
    NSLog(@"Auto Refresh timer - stoped!");
    
    //processing bagde
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"descount_bagdes" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardShow:(NSNotification *)notification {
    
    [GlobalVar getInstance].isPosting = YES;
    
    NSDictionary *messageInfo = [notification userInfo];
    
    NSString *pointInTable_x_string = [messageInfo objectForKey:@"pointInTable_x"];
    NSString *pointInTable_y_string = [messageInfo objectForKey:@"pointInTable_y"];
    NSString *textFieldHeight_string = [messageInfo objectForKey:@"textFieldHeight"];
    
    CGFloat pointInTable_x = (CGFloat)[pointInTable_x_string floatValue];
    CGFloat pointInTable_y = (CGFloat)[pointInTable_y_string floatValue] - 100;
    CGFloat textFieldHeight = (CGFloat)[textFieldHeight_string floatValue];
    
    CGPoint pointInTable = CGPointMake(pointInTable_x, pointInTable_y);
    CGPoint contentOffset = tblForDetailList.contentOffset;
    
    contentOffset.y = (pointInTable.y - textFieldHeight);
    
    [tblForDetailList setContentOffset:contentOffset animated:YES];
}

- (void)keyboardHide:(NSNotification *)notification {
    NSDictionary *messageInfo = [notification userInfo];
    
    NSString *pointInTable_x_string = [messageInfo objectForKey:@"pointInTable_x"];
    NSString *pointInTable_y_string = [messageInfo objectForKey:@"pointInTable_y"];
    
    CGFloat pointInTable_x = (CGFloat)[pointInTable_x_string floatValue];
    CGFloat pointInTable_y = (CGFloat)[pointInTable_y_string floatValue];
    
    CGPoint bottomPosition = CGPointMake(pointInTable_x, pointInTable_y);
    NSIndexPath *indexPath = [tblForDetailList indexPathForRowAtPoint:bottomPosition];
    
    [tblForDetailList reloadData];
    
    [tblForDetailList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    
    [GlobalVar getInstance].isPosting = NO;
}

- (void)initializeControls {
    
    customPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 300, self.view.frame.size.width, 250 + 40  )];
    
    rectForPickerView = customPickerView.frame;
    
    Picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 250)];
    Picker.delegate = self;
    [Picker setBackgroundColor:[UIColor lightGrayColor]];
    [customPickerView addSubview:Picker];
    
    UIToolbar *doneToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar.barStyle = UIBarStyleDefault;
    
    doneToolBar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissPickerView)], nil];
    
    [doneToolBar sizeToFit];
    
    [customPickerView addSubview:doneToolBar];
    [self.navigationController.view addSubview:customPickerView];
}

- (void)showPickerView
{
    [UIView animateWithDuration:0.2f animations:^{
        
        [customPickerView setFrame:CGRectMake(customPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - customPickerView.frame.size.height, customPickerView.frame.size.width, customPickerView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)doneButtonClikedDismissPickerView {
    
    [UIView animateWithDuration:0.2f animations:^{
        [customPickerView setFrame:rectForPickerView];
        [self loadContents];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addRefreshControlToTable
{
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tblForDetailList.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [tblForDetailList addSubview:self.refreshControl];
}

- (void)initializeNavBar
{
    //Junaid: The text needs to be expanded for the title and the description.
    //    self.title = currentObject[@"eventname"];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    lblTitle.text = currentObject[@"eventname"];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont boldSystemFontOfSize:17.0f];
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.numberOfLines = 0;
    self.navigationItem.titleView = lblTitle;
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [customButton addTarget:self action:@selector(tagPeople) forControlEvents:UIControlEventTouchUpInside];
    [customButton setBackgroundImage:[UIImage imageNamed:@"btn_tag"] forState:UIControlStateNormal];
    
    BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [inviteButton addTarget:self action:@selector(showInvite) forControlEvents:UIControlEventTouchUpInside];
    [inviteButton setBackgroundImage:[UIImage imageNamed:@"icon_friend"] forState:UIControlStateNormal];
    
    BBBadgeBarButtonItem *btnForInvite = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:inviteButton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, btnForInvite, negativeSpacer1, barButton,nil];
    
}

- (void)reloadCurrentObject
{
    [currentObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [tblForDetailList reloadData];
    }];
}

- (void)loadContents {
    
    if(currentObject == nil) return;
    [GlobalVar getInstance].isPosting = YES;
    [tblForDetailList setContentOffset:CGPointZero animated:NO];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [GlobalVar getInstance].isPostLoading = YES;
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"targetEvent" equalTo:currentObject];
    
    if ([is_type isEqualToString:@"text"]
        || [is_type isEqualToString:@"video"]
        || [is_type isEqualToString:@"audio"]
        || [is_type isEqualToString:@"photo"])
    {
        [mainQuery whereKey:@"postType" equalTo:is_type];
    }
    
    [mainQuery includeKey:@"user"];
    [mainQuery includeKey:@"commentsArray"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery orderByDescending:@"postOrder"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [GlobalVar getInstance].isPostLoading = NO;
        [GlobalVar getInstance].isPosting = NO;
        
        if (error == nil) {
            
            if([arrForDetail count] != 0)[arrForDetail removeAllObjects];
            if([offlineURLs count] != 0)[offlineURLs removeAllObjects];
            
            if([objects count] > 0) [arrForDetail addObjectsFromArray:objects];
            
            OMAppDelegate* appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
            offline_data_num = appDel.m_offlinePosts.count;
            
            for (NSUInteger i = 0; i < offline_data_num; i++ ) {
                PFObject *temp_object = [appDel.m_offlinePosts objectAtIndex:i];
                PFObject *temp_targetEventObject = temp_object[@"targetEvent"];
                
                if ([temp_targetEventObject.objectId isEqualToString:currentObject.objectId]) {
                    [arrForDetail addObject:temp_object];
                    [offlineURLs addObject:[appDel.m_offlinePostURLs objectAtIndex:i]];
                }
            }
            
            //Sort Posts on postOrder
            if (appDel.m_offlinePosts.count > 0) {
                [arrForDetail sortUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
                    NSNumber *postOrder1 = obj1[@"postOrder"];
                    NSNumber *postOrder2 = obj2[@"postOrder"];
                    if (postOrder1.intValue > postOrder2.intValue) {
                        return NSOrderedAscending;
                    } else if (postOrder1.intValue < postOrder2.intValue) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedSame;
                }];
            }
            
            if (isActionSheetReverseSelected) {
                arrForDetail = [[[arrForDetail reverseObjectEnumerator] allObjects] mutableCopy];
            }
            
            //Save the postOrder for those posts who don't have postOrder with null value
            for (int i=0; i<arrForDetail.count; i++) {
                PFObject *item = arrForDetail[i];
                if (!item[@"postOrder"]) {
                    item[@"postOrder"] = [NSNumber numberWithInt:i+1];
                    [item save];
                }
            }
            
            // Current Test feature. lets check these again.
            PFUser *eventUser = currentObject[@"user"];
            if([eventUser.objectId isEqualToString: USER.objectId])
            {
                currentObject[@"postedObjects"] = arrForDetail;
                if (appDel.network_state) {
                    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error == nil) NSLog(@"DetailEventVC: added Post objs on postedObjects on Event");
                    }];
                }
            }
            
            [tblForDetailList reloadData];
            
        }
    }];
}

- (void)reloadContents
{
    NSLog(@"Auto Refresh Progressing...");
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"targetEvent" equalTo:currentObject];
    
    if ([is_type isEqualToString:@"text"]
        || [is_type isEqualToString:@"video"]
        || [is_type isEqualToString:@"audio"]
        || [is_type isEqualToString:@"photo"])
    {
        [mainQuery whereKey:@"postType" equalTo:is_type];
    }
    
    [mainQuery includeKey:@"user"];
    [mainQuery includeKey:@"commentsArray"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery orderByDescending:@"postOrder"];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error || !objects) {
            return;
        }
        else
        {
            [arrForDetail removeAllObjects];
            [arrForDetail addObjectsFromArray:objects];
            
            OMAppDelegate* appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
            offline_data_num = appDel.m_offlinePosts.count;
            
            for (NSUInteger i = 0; i < offline_data_num; i ++) {
                PFObject *temp_object = [appDel.m_offlinePosts objectAtIndex:i];
                PFObject *temp_targetEventObject = temp_object[@"targetEvent"];
                
                if ([temp_targetEventObject.objectId isEqualToString:currentObject.objectId]) {
                    [arrForDetail addObject:temp_object];
                    [offlineURLs addObject:[appDel.m_offlinePostURLs objectAtIndex:i]];
                }
            }
            
            //Sort Posts on postOrder
            if (appDel.m_offlinePosts.count > 0) {
                [arrForDetail sortUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
                    NSNumber *postOrder1 = obj1[@"postOrder"];
                    NSNumber *postOrder2 = obj2[@"postOrder"];
                    if (postOrder1.intValue > postOrder2.intValue) {
                        return NSOrderedAscending;
                    } else if (postOrder1.intValue < postOrder2.intValue) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedSame;
                }];
            }
            
            if (isActionSheetReverseSelected) {
                arrForDetail = [[[arrForDetail reverseObjectEnumerator] allObjects] mutableCopy];
            }
            
            [tblForDetailList reloadData];
        }
    }];
}


- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadEventDataWithGlobal object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addContentsAction:(id)sender
{
    selectedPostOrder = -1;
    UIButton *button = (UIButton *)sender;
    if ([currentObject[@"openStatus"] intValue]) {
        switch (button.tag) {
            case 10:
            {
                [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCapturePhoto currentObject:currentObject
                                   postOrder:selectedPostOrder];
            }
                break;
            case 11:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Audio" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Record Audio", nil];
                
                [actionSheet setTag:kTag_NewAudio];
                [actionSheet showInView:self.view];
                
                //                mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
                //
                //                mediaPicker.allowsPickingMultipleItems = NO;
                //                mediaPicker.delegate = self;
                //                [TABController presentViewController:mediaPicker animated:YES completion:nil];
            }
                break;
            case 12:
            {
                [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCaptureVideo currentObject:currentObject
                                   postOrder:selectedPostOrder];
            }
                break;
            case 13:
            {
                [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCaptureText currentObject:currentObject
                                   postOrder:selectedPostOrder];
            }
                break;
            default:
                break;
        }
        
    }
    else
    {
        [OMGlobal showAlertTips:@"Oops!" title:@"This event was closed."];
    }
    
}

- (IBAction)changeShowOption:(id)sender {
    
    [self showPickerView];
}

- (IBAction)changeModeAction:(id)sender {
    
    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
    
    NSDate* lastUpdatedate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdatedate forKey:@"lastUpdateLocalDatastore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
        NSLog(@"There IS NO internet connection");
        if (!appDel.network_state){
            [OMGlobal showAlertTips:@"No Access Network!" title:@"Newwork State"];
        }
        
        appDel.network_state = NO;
        
        UIImage *btnImage = [UIImage imageNamed:@"offline_state.png"];
        [btnForNetState setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        
        NSLog(@"There IS internet connection");
        
        if (appDel.network_state){
            
            appDel.network_state = NO;
            
            UIImage *btnImage = [UIImage imageNamed:@"offline_state.png"];
            [btnForNetState setImage:btnImage forState:UIControlStateNormal];
            
        } else {
            
            appDel.network_state = YES;
            
            UIImage *btnImage = [UIImage imageNamed:@"online_state.png"];
            [btnForNetState setImage:btnImage forState:UIControlStateNormal];
            
            for(PFObject* post in appDel.m_offlinePosts){
                [GlobalVar getInstance].isPosting = YES;
                //Request a background execution task to allow us to finish uploading the photo even if the app is background
                self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
                
                if ([currentObject[@"postedObjects"] containsObject:post]) {
                    [currentObject[@"postedObjects"] removeObject:post];
                }
                
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if (succeeded) {
                        NSLog(@"Success ---- Post");
                        
                        
                        // add new Post object on postedObjects array: for badge
                        [currentObject[@"postedObjects"] addObject:post];
                        [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            [GlobalVar getInstance].isPosting = NO;
                        }];
                        
                        [post fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            
                            [[OMPushServiceManager sharedInstance] sendNotificationToTaggedFriends:object];
                            [appDel.m_offlinePosts removeObject:post];
                            
                        }];
                        
                    } else {
                        
                        NSLog(@"Error ---- Post = %@", error);
                        
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:appDel.network_state forKey:@"network_status"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onBtnReverseActionSheetContentsTapped:(UIButton *)sender {
    isActionSheetReverseSelected = !isActionSheetReverseSelected;
    if (isActionSheetReverseSelected) {
        [sender setImage:[UIImage imageNamed:@"btn-updown-arrow-selected"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"btn-updown-arrow"] forState:UIControlStateNormal];
    }
    
    if (arrForDetail.count > 0) {
        arrForDetail = [[[arrForDetail reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
    [tblForDetailList reloadData];
}


- (NSInteger)firstSectionCount:(PFObject *)_obj
{
    NSInteger rows = 0;
    //Header
    rows += 1;
    
    //
    rows += 1;
    //Comments
    //rows += [_obj[@"commenters"] count] > 3 ? 3:[_obj[@"commenters"] count];
    if(_obj[@"commenters"] != nil && [_obj[@"commenters"] count] > 0)
        if(_obj[@"commentsArray"] !=nil && [_obj[@"commentsArray"] count] > 0)
            //if(rows + [_obj[@"commenters"] count] <= [_obj[@"commentsArray"] count])
            rows += [_obj[@"commenters"] count];
    
    return rows;
}

- (NSInteger)cellCount:(PFObject *)_obj
{
    NSInteger rows = 0;
    //Header
    if(_obj != nil)
        rows += 1;
    //Comments
    //rows += [_obj[@"commentsUsers"] count] > 3 ? 3:[_obj[@"commentsUsers"] count];
    if(_obj[@"commentsUsers"] != nil && [_obj[@"commentsUsers"] count] > 0)
        if (_obj[@"commentsArray"] != nil && [_obj[@"commentsArray"] count] > 0 )
            //if(rows + [_obj[@"commentsUsers"] count] <= [_obj[@"commentsArray"] count])
        {
            rows += [_obj[@"commentsUsers"] count];
        }
    return rows;
}
- (void)showInvite
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite People" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Invite via Email" otherButtonTitles:@"Invite via SMS", nil];
    
    [actionSheet setTag:300];
    [actionSheet showInView:self.view];
}

- (void)tagPeople {
    
    NSArray *arrForTaggedFriend = [NSArray array];
    NSArray *arrTagFriendAuthorities = [NSArray array];
    
    if (currentObject[@"TagFriends"]) {
        arrForTaggedFriend = currentObject[@"TagFriends"];
    }
    
    if (currentObject[@"TagFriendAuthorities"]) {
        arrTagFriendAuthorities = currentObject[@"TagFriendAuthorities"];
    }
    
    PFUser *postUser = currentObject[@"user"];
    
    if ([arrForTaggedFriend containsObject:USER.objectId]) {
        NSInteger index = [arrForTaggedFriend indexOfObject:USER.objectId];
        NSString *strAuthLevel = [arrTagFriendAuthorities objectAtIndex:index];
        if ([strAuthLevel isEqualToString:@"Full"]) {
            OMAdditionalTagViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdditionalTagVC"];
            tagListVC.delegate = self;
            [tagListVC setCurrentObject:currentObject];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
            [TABController presentViewController:nav animated:YES completion:nil];
        }
    }
    else if ([postUser.objectId isEqualToString:USER.objectId])
    {
        OMAdditionalTagViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AdditionalTagVC"];
        tagListVC.delegate = self;
        [tagListVC setCurrentObject:currentObject];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
        [TABController presentViewController:nav animated:YES completion:nil];
    } else {
        [OMGlobal showAlertTips:@"Oh, You were not tagged by Post owner." title:@"Oops!"];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 300) {
        switch (buttonIndex) {
            case 0:
            {
                [self inviteViaEmail];
            }
                break;
            case 1:
            {
                [self inviteViaSMS];
            }
                break;
            default:
                break;
        }
    }
}

- (void)inviteViaEmail {
    
    postImgView = [[UIImageView alloc] init];
    PFFile *file = (PFFile *)currentObject[@"thumbImage"];
    [postImgView setImageWithURL:[NSURL URLWithString:file.url]];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:currentObject[@"eventname"]];
        [mailView setMessageBody:[NSString stringWithFormat:@"You are invited! Join  %@ INTELLISPEX %@!", USER.username , currentObject[@"eventname"]] isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
        [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        //                NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
        //                [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [TABController presentViewController:mailView animated:YES completion:nil];
        
    } else {
        [OMGlobal showAlertTips:@"Please confirm whether you registered the email address." title:nil];
    }
    
}

- (void)inviteViaSMS {
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.persistent = YES;
    //            pasteboard.image = [UIImage imageNamed:<#(NSString *)#>]
    
    NSString *phoneToCall = @"sms:";
    NSString *phoneToCallEncoded = [phoneToCall stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL *url = [[NSURL alloc] initWithString:phoneToCallEncoded];
    [[UIApplication sharedApplication] openURL:url];
    
    if ([MFMessageComposeViewController canSendText]) {
        controller.messageComposeDelegate = self;
        controller.body = @"Created by INTELLISPEX App!Please install it.\n https://itunes.applec.com.....";
        NSMutableDictionary *navBarTitleAttributes = [[UINavigationBar appearance] titleTextAttributes].mutableCopy;
        
        UIFont *navBarTitleFont = navBarTitleAttributes[NSFontAttributeName];
        
        navBarTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:navBarTitleFont.pointSize];
        [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
        
        [TABController presentViewController:controller animated:YES completion:^{
            navBarTitleAttributes[NSFontAttributeName] = navBarTitleFont;
            [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
        }];
    } else {
        [OMGlobal showAlertTips:@"Your device can't support SMS" title:nil];
    }
}


#pragma mark

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Tag List

- (void)selectDidCancel:(OMAdditionalTagViewController *)fsCategoryVC
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedCells:(OMAdditionalTagViewController *)tagVC didFinished:(NSMutableArray *)_dict
{
    [tagVC.navigationController dismissViewControllerAnimated:YES completion:^{
        NSMutableArray *tagFriends = [NSMutableArray array];
        NSMutableArray *authorities = [NSMutableArray array];
        
        for (int i=0; i<3; i++) {
            NSArray *list = _dict[i];
            if (list.count > 0) {
                for (PFUser *user in list) {
                    [tagFriends addObject:user.objectId];
                    if (i==0) {
                        [authorities addObject:@"Full"];
                    } else if (i==1) {
                        [authorities addObject:@"View Only"];
                    } else if (i==2) {
                        [authorities addObject:@"Comment Only"];
                    }
                }
            }
        }
        
        NSMutableArray *data = [NSMutableArray array];
        [data addObject:tagFriends];
        [data addObject:authorities];
        [self addTagFriends:data];
    }];
}

// In case to change the Tag for Friends.
- (void)addTagFriends:(NSMutableArray *)_dict {
    NSMutableArray *arrChangedTagFriends = [_dict objectAtIndex:0];
    NSMutableArray *arrAdds = [NSMutableArray array];
    NSMutableArray *arrDels = [NSMutableArray array];
    
    // for badge
    if([arrPrevTagFriends count] > 0)
    {
        // If exist the new friends?
        for (NSString *addId in arrChangedTagFriends) {
            if(![arrPrevTagFriends containsObject:addId]) {
                [arrAdds addObject:addId];
            }
        }
        
        for (NSString *deledtedId in arrPrevTagFriends) {
            if (![arrChangedTagFriends containsObject:deledtedId]) {
                [arrDels addObject:deledtedId];
            }
        }
    }
    else
    {
        [arrAdds addObjectsFromArray:arrChangedTagFriends];
    }
    
    currentObject[@"TagFriends"] = [_dict objectAtIndex:0];
    currentObject[@"TagFriendAuthorities"] = [_dict objectAtIndex:1];
    
    // Event Badge Processing...for badge
    if([currentObject[@"eventBadgeFlag"] count] > 0)
    {
        for (NSString *temp in arrDels) {
            if ([currentObject[@"eventBadgeFlag"] containsObject:temp]) {
                [currentObject removeObject:temp forKey:@"eventBadgeFlag"];
            }
        }
        
        for (NSString *temp in arrAdds) {
            if (![currentObject[@"eventBadgeFlag"] containsObject:temp]) {
                [currentObject addObject:temp forKey:@"eventBadgeFlag"];
            }
        }
    }
    else
    {
        [currentObject addObjectsFromArray:arrAdds forKey:@"eventBadgeFlag"];
    }
    
    NSLog(@"Newly added friends: %@", arrAdds);
    NSLog(@"Deleted friends: %@", arrDels);
    
    [GlobalVar getInstance].isPosting = YES;
    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [GlobalVar getInstance].isPosting = NO;
        if(error) NSLog(@"Event updated for tag: %@", error.description);
        if(error == nil) NSLog(@"DetailEventVC:Badge Processing - Updated an eventBadgeFlage of Event Fields");
    }];
}

#pragma mark - MPMediaPickerController Delegate
- (void)mediaPicker:(MPMediaPickerController *)_mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSMutableData *songData;
    
    
    MPMediaItemCollection *collection=mediaItemCollection;
    MPMediaItem *item = [collection representativeItem];
    
    
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSString *title=[item valueForProperty:MPMediaItemPropertyTitle];
    NSURL *url;
    
    if (!assetURL) {
        
        NSLog(@"%@ has DRM",title);
        
        [OMGlobal showAlertTips:@"Can't attach the audio file." title:@"Oops!"];
        
    }
    
    else{
        
        url = [item valueForProperty: MPMediaItemPropertyAssetURL];
        
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        NSError * error = nil;
        AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
        
        AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
        
        AVAssetReaderTrackOutput * output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:nil];
        
        [reader addOutput:output];
        
        songData = [[NSMutableData alloc] init];
        
        [reader startReading];
        
        
        while (reader.status == AVAssetReaderStatusReading)
        {
            AVAssetReaderTrackOutput  *trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
            CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
            
            if (sampleBufferRef)
            {
                
                CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
                size_t length = CMBlockBufferGetDataLength(blockBufferRef);
                
                UInt8 buffer[length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, buffer);
                NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
                
                [songData appendData:data];
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
    }
    
    m_audioData = [NSData dataWithData:songData];
    
    //    if(url != NULL)
    //    {
    //        m_isAudio = YES;
    //        m_AudioURL = url;
    //        [_btn_play setHidden:NO];
    //
    //        m_AVAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:m_AudioURL error:nil];
    //        [m_AVAudioPlayer prepareToPlay];
    //        m_AVAudioPlayer.delegate = self;
    //        [_btn_play setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
    //    }
    [_mediaPicker dismissViewControllerAnimated:YES completion:^{
        
        if (m_audioData) {
            
            [TABController postAudio:kTypeUploadPost
                           mediaKind:kTypeCaptureAudio
                       currentObject:currentObject
                           audioData:m_audioData postOrder:selectedPostOrder];
            
        }
        else
            [OMGlobal showAlertTips:@"Can't attached audio file." title:@"Oops!"];
        
        
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)_mediaPicker
{
    
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrForDetail.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) // Even Header Content
    {
        if (indexPath.row == 0) {
            
            OMDetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailHeaderCell];
            if (!cell) {
                cell = [[OMDetailHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDetailHeaderCell];
            }
            
            [cell setDelegate:self];
            [cell setCurrentObj:currentObject];
            return cell;
            
        } else if (indexPath.row == 1) {
            
            OMDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kDescriptionCell];
            
            if (!cell) {
                cell = [[OMDescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDescriptionCell];
            }
            [cell setCurrentObj:currentObject];
            return cell;
            
        } else if (indexPath.row > 1 && indexPath.row < [self firstSectionCount:currentObject]) {
            
            OMFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedCommentCell];
            if (!cell) {
                cell = [[OMFeedCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedCommentCell];
            }
            
            
            PFObject *temp = [currentObject[@"commenters"] objectAtIndex:indexPath.row - 2];
            
            NSString *objectId = temp.objectId;
            if (objectId == nil){
                objectId = [[currentObject[@"commenters"] objectAtIndex:indexPath.row - 2] objectId];
            }
            
            [cell setDelegate:self];
            [cell newsetUser:objectId comment:[currentObject[@"commentsArray"] objectAtIndex:indexPath.row - 2] curObj:currentObject commentType:kTypeEventComment number:indexPath.row - 2];
            
            return cell;
        }
        
    }
    else // Event Detail Content with Post detail contents
    {
        
        if([arrForDetail count] > 0)
        {
            PFObject *tempObj;
            
            tempObj = (PFObject*)[arrForDetail objectAtIndex:indexPath.section - 1];
            
            // Post Contents with text type
            if ([tempObj[@"postType"] isEqualToString:@"text"])
            {
                if (indexPath.row == 0) {
                    OMTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextCell];
                    
                    if (cell == nil) {
                        cell = [[OMTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextCell];
                    }
                    
                    [cell setDelegate:self];
                    [cell setCurEventIndex:curEventIndex];
                    [cell setCurPostIndex:indexPath.section - 1];
                    [cell setCheckMode:modeForExport];
                    [cell setCurrentObj:tempObj];
                    
                    return cell;
                    
                } else if (indexPath.row > 0 && indexPath.row < [self cellCount:tempObj]) {
                    
                    NSMutableArray *arr = [[NSMutableArray alloc]init];
                    
                    if (tempObj[@"commentsArray"] != nil && [tempObj[@"commentsArray"] count] > 0 ) {
                        arr = tempObj[@"commentsArray"];
                    }
                    OMFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedCommentCell];
                    
                    if (!cell) {
                        cell = [[OMFeedCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedCommentCell];
                    }
                    
                    [cell setDelegate:self];
                    
                    //[cell configCell:[tempObj[@"commentsArray"] objectAtIndex:(arr.count - indexPath.row)] EventObject:tempObj[@"targetEvnet"] commentType:kTypePostComment];
                    [cell configPostCell:[arr objectAtIndex:(arr.count - indexPath.row)] PostObject:tempObj EventObject:tempObj[@"targetEvent"] CommentType:kTypePostComment];
                    
                    
                    return cell;
                }
            }
            
            // Post Contents with Media type
            else
            {
                if (indexPath.row == 0) {
                    
                    OMMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaCell];
                    
                    if (cell == nil) {
                        cell = [[OMMediaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMediaCell];
                    }
                    
                    if (indexPath.section - 1 < offline_data_num){
                        
                        cell.file = (PFFile *)tempObj[@"postFile"];
                        cell.offline_url = [offlineURLs objectAtIndex:indexPath.section - 1];
                        
                    } else {
                        cell.file = nil;
                        cell.offline_url = nil;
                    }
                    
                    [cell setDelegate:self];
                    [cell setCurEventIndex: curEventIndex];
                    [cell setCurPostIndex:indexPath.section - 1];
                    [cell setCheckMode:modeForExport];
                    [cell setCurrentObj:tempObj];
                    //cell.currentObj = tempObj;
                    
                    [cell setNeedsLayout];
                    [cell layoutIfNeeded];
                    
                    return cell;
                }
                else if (indexPath.row > 0 && indexPath.row < [self cellCount:tempObj])
                {
                    NSMutableArray *arr = [[NSMutableArray alloc]init];
                    
                    if (tempObj[@"commentsArray"] != nil && [tempObj[@"commentsArray"] count] > 0) {
                        arr = tempObj[@"commentsArray"];
                    }
                    
                    OMFeedCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kFeedCommentCell];
                    
                    if (!cell) {
                        cell = [[OMFeedCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFeedCommentCell];
                    }
                    
                    [cell setDelegate:self];
                    //[cell configCell:[arr objectAtIndex:(arr.count - indexPath.row )] EventObject:tempObj[@"targetEvnet"]commentType:kTypePostComment];
                    [cell configPostCell:[arr objectAtIndex:(arr.count - indexPath.row)] PostObject:tempObj EventObject:tempObj[@"targetEvent"] CommentType:kTypePostComment];
                    
                    return cell;
                }
            }
            
        }
        
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        return [self firstSectionCount:currentObject];
    }
    else
    {
        PFObject *tempObj = [arrForDetail objectAtIndex:section - 1];
        return [self cellCount:tempObj];
    }
    
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        
    }
    else
    {
        PFObject *tempObj = [arrForDetail objectAtIndex:indexPath.section - 1];
        if ([tempObj[@"postType"] isEqualToString:@"text"])
        {
            return;
        }
        else
        {
            
            if (indexPath.row == 0)
            {
                if ([cell isKindOfClass:[OMMediaCell class]]) {
                    OMMediaCell *_cell = (OMMediaCell *)cell;
                    if (_cell)
                    {
                        if ([tempObj[@"postType"] isEqualToString:@"video"])
                        {
                            [_cell stopVideo];
                        }
                        else if ([tempObj[@"postType"] isEqualToString:@"audio"]) {
                            [_cell stopAudio];
                        }
                    }
                }
            }
            else if (indexPath.row > 0 && indexPath.row < [self cellCount:tempObj])
            {
                return;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return tableView.frame.size.width;
        }
        else if (indexPath.row == 1)
        {
            if (currentObject[@"description"]) {
                return ([OMGlobal getBoundingOfString:currentObject[@"description"] width:tableView.frame.size.width].height + 40.0f);
            }
            return 0;
        }
        else
        {
            if (indexPath.row > 1)
                return [OMGlobal heightForCellWithPost:[[currentObject objectForKey:@"commentsArray"] objectAtIndex:(indexPath.row - 2)]] + 30;
            else
                return 70;
        }
    }
    else
    {
        PFObject *tempObj = [arrForDetail objectAtIndex:indexPath.section - 1];
        
        if ([tempObj[@"postType"] isEqualToString:@"text"])
        {
            if (indexPath.row == 0) {
                
                return [OMGlobal heightForCellWithPost:tempObj[@"title"]] + [OMGlobal heightForCellWithPost:tempObj[@"description"]] + 80;
            }
            else if (indexPath.row > 0 && indexPath.row < [self cellCount:tempObj])
            {
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                
                if (tempObj[@"commentsArray"]) {
                    arr = tempObj[@"commentsArray"];
                }
                
                PFObject* _obj = (PFObject* )[arr objectAtIndex:(arr.count - indexPath.row )];
                NSString* strComments =  _obj[@"Comments"];
                
                return [OMGlobal heightForCellWithPost:strComments] + 30;
            }
        }
        else
        {
            if (indexPath.row == 0) {
                PFObject *tempObj = (PFObject*)[arrForDetail objectAtIndex:indexPath.section - 1];
                CGFloat height = [OMGlobal heightForCellWithPost:tempObj[@"title"]] + [OMGlobal heightForCellWithPost:tempObj[@"description"]] - 55;
                return IS_IPAD? SCREEN_WIDTH_ROTATED + 130 + height: 450 + height;
            }
            else if (indexPath.row > 0 && indexPath.row < [self cellCount:tempObj])
            {
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                
                if (tempObj[@"commentsArray"]) {
                    arr = tempObj[@"commentsArray"];
                }
                
                PFObject* _obj = (PFObject* )[arr objectAtIndex:(arr.count - indexPath.row )];
                NSString* strComments =  _obj[@"Comments"];
                
                return [OMGlobal heightForCellWithPost:strComments] + 30;
            }
        }
    }
    return 50;
}


#pragma mark Cell Delegate Methods

- (void)shareEvent:(PFObject *)_obj
{
    selectedPostOrder = -1;
    
    UIActionSheet *shareAction1 = nil;
    NSString *status = @"Close";
    if (postImgView) {
        postImgView = nil;
    }
    postImgView = [[UIImageView alloc] init];
    PFFile *file = (PFFile *)_obj[@"thumbImage"];
    [postImgView setImageWithURL:[NSURL URLWithString:file.url]];
    currentObject = _obj;
    NSLog(@"%@",_obj[@"openStatus"]);
    
    if ([_obj[@"openStatus"] intValue] == 1) {
        status = @"Close";
    }
    else
    {
        status = @"Open";
    }
    
    PFUser *user = (PFUser *)_obj[@"user"];
    NSArray *arrForTaggedFriend = [NSArray array];
    NSArray *arrTagFriendAuthorities = [NSArray array];
    
    if (currentObject[@"TagFriends"]) {
        arrForTaggedFriend = currentObject[@"TagFriends"];
    }
    
    NSString *strAuthLevel = @"";
    
    if ([arrForTaggedFriend containsObject:USER.objectId]) {
        
        if (currentObject[@"TagFriendAuthorities"]) {
            arrTagFriendAuthorities = currentObject[@"TagFriendAuthorities"];
        }
        
        NSInteger index = [arrForTaggedFriend indexOfObject:USER.objectId];
        strAuthLevel = [arrTagFriendAuthorities objectAtIndex:index];
    }
    
    NSInteger index = [arrForTaggedFriend indexOfObject:USER.objectId];
    NSString *strAuthLevel = @"";
    if (index != NSNotFound) {
        strAuthLevel = [arrTagFriendAuthorities objectAtIndex:index];
    }    
    
    if ([user.objectId isEqualToString:USER.objectId] || [strAuthLevel isEqualToString:@"Full"]) {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Share via Email"
                                          otherButtonTitles:@"Facebook", @"Twitter", @"Instagram",
                        @"Add Media After", @"Add to Folder", @"Export to PDF", @"Select Items for New Event",
                        @"Delete", status, @"Report", @"Move",nil];
        
        [shareAction1 showInView:self.view];
        shareAction1.tag = kTag_EventShare;
    }
    else
    {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Share via Email"
                                          otherButtonTitles:@"Facebook", @"Twitter", @"Instagram", @"Export to PDF",
                        @"Select Items for New Event", @"Report", @"Move",nil];
        
        [shareAction1 showInView:self.view];
        shareAction1.tag = kTag_EventShareGuest;
    }
}

- (void)sharePost:(UITableViewCell *)_cell {
    
    if(_cell == nil) return;
    
    NSIndexPath *indexPath = [tblForDetailList indexPathForCell:_cell];
    selectedPostOrder = (int)indexPath.section - 1;
    
    currentMediaCell = _cell;
    OMMediaCell* _tmpCell = (OMMediaCell*)_cell;
    PFObject* _obj = _tmpCell.currentObj;
    tempObejct = _obj;
    currentCellOfflineUrl = _tmpCell.offline_url;
    
    UIActionSheet *shareAction1 = nil;
    
    postImgView = [[UIImageView alloc] init];
    PFFile *file = (PFFile *)_obj[@"thumbImage"];
    [postImgView setImageWithURL:[NSURL URLWithString:file.url]];
    
    PFUser *user = (PFUser *)_obj[@"user"];
    
    NSMutableArray *arrForTagFriends = [NSMutableArray array];
    NSMutableArray *arrForTagFriendAuthorities  = [NSMutableArray array];
    BOOL authFlag = NO;
    
    if(currentObject[@"TagFriends"] != nil && [currentObject[@"TagFriends"] count] > 0)
    {
        arrForTagFriends = currentObject[@"TagFriends"];
    }
    if(currentObject[@"TagFriendAuthorities"] != nil && [currentObject[@"TagFriendAuthorities"] count] > 0)
    {
        arrForTagFriendAuthorities = currentObject[@"TagFriendAuthorities"];
    }
    
    NSString *AuthorityValue = @"";
    
    if (arrForTagFriendAuthorities != nil && [arrForTagFriendAuthorities count] > 0){
        
        for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
            if ([[arrForTagFriends objectAtIndex:i] isEqualToString:USER.objectId]){
                if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                    AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                break;
            }
        }
        
        if ([AuthorityValue isEqualToString:@"Full"]){
            authFlag = YES;
        }
        else
        {
            authFlag = NO;
        }
        
    }
    else
    {
        if ([arrForTagFriends containsObject:USER.objectId]){
            authFlag = YES;
        }
    }
    
    
    if ([user.objectId isEqualToString:USER.objectId] || authFlag) {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:@"More option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Save to Camera roll" otherButtonTitles:@"Add Media After", @"Use this as thumbnail",
                        @"Delete", @"Report", nil];
        [shareAction1 setTag:kTag_Share];
        [shareAction1 showInView:self.view];
        
    } else {
        shareAction1 = [[UIActionSheet alloc] initWithTitle:@"More option" delegate:self cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Save to Camera roll" otherButtonTitles:@"Add Media After",
                        @"Report", nil];
        [shareAction1 setTag:kTag_Share1];
        [shareAction1 showInView:self.view];
    }
}

- (void)sharePostText:(PFObject *) _obj{
    
    UIActionSheet *shareAction1 = nil;
    
    postImgView = [[UIImageView alloc] init];
    PFFile *file = (PFFile *)_obj[@"thumbImage"];
    [postImgView setImageWithURL:[NSURL URLWithString:file.url]];
    tempObejct = _obj;
    PFUser *user = (PFUser *)_obj[@"user"];
    
    NSMutableArray *arrForTagFriends = [NSMutableArray array];
    NSMutableArray *arrForTagFriendAuthorities  = [NSMutableArray array];
    BOOL authFlag = NO;
    
    if(currentObject[@"TagFriends"] != nil && [currentObject[@"TagFriends"] count] > 0)
    {
        arrForTagFriends = currentObject[@"TagFriends"];
    }
    if(currentObject[@"TagFriendAuthorities"] != nil && [currentObject[@"TagFriendAuthorities"] count] > 0)
    {
        arrForTagFriendAuthorities = currentObject[@"TagFriendAuthorities"];
    }
    
    NSString *AuthorityValue = @"";
    
    if (arrForTagFriendAuthorities != nil && [arrForTagFriendAuthorities count] > 0){
        
        for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
            if ([[arrForTagFriends objectAtIndex:i] isEqualToString:USER.objectId]){
                if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                    AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                break;
            }
        }
        
        if ([AuthorityValue isEqualToString:@"Full"]) {
            authFlag = YES;
        }
        else
        {
            authFlag = NO;
        }
        
    }
    else
    {
        if ([arrForTagFriends containsObject:USER.objectId]){
            authFlag = YES;
        }
    }
    
    if ([user.objectId isEqualToString:USER.objectId] || authFlag) {
        
        shareAction1 = [[UIActionSheet alloc] initWithTitle:@"More option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Delete", @"Report", nil];
        [shareAction1 setTag:kTag_TextShare];
        [shareAction1 showInView:self.view];
        
    } else {
        
        shareAction1 = [[UIActionSheet alloc] initWithTitle:@"More option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
        [shareAction1 setTag:kTag_TextShare1];
        [shareAction1 showInView:self.view];
        
    }
}

- (void)noticeNewPost:(PFObject *)_obj{
    
}

// Event Comments - message icon click:
- (void)showEventComments:(PFObject *)_obj {
    
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [((OMAppDelegate *)[UIApplication sharedApplication].delegate) tabBarController];
    
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:YES];
    OMEventCommentViewController *eventCommentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventCommentVC"];
    [eventCommentVC setCurrentObject:_obj];
    
    [self.navigationController pushViewController:eventCommentVC animated:YES];
}

- (void)showLikersOfEvent:(PFObject *)_obj
{
    OMLikersViewController *likerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LikersVC"];
    [likerVC setCurObj:_obj];
    [likerVC setIsEventMode:YES];
    [self.navigationController pushViewController:likerVC animated:YES];
    
}

- (void)showLikersOfPost:(PFObject *)_obj
{
    OMLikersViewController *likerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LikersVC"];
    [likerVC setCurObj:_obj];
    [likerVC setIsEventMode:NO];
    [self.navigationController pushViewController:likerVC animated:YES];
}

- (void)showComments:(PFObject *)_obj
{
    OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    FTTabBarController *tab = [appDel tabBarController];
    [tab hideTabView:YES];
    OMCommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
    [commentVC setCurrentObject:_obj];
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)showDetail:(PFObject *)_obj
{
}

- (void)showProfile:(PFUser *)_user
{
    if ([_user.objectId isEqualToString:USER.objectId]) {
        
        OMMyProfileViewController *myProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileVC"];
        myProfileVC.is_type = 0;
        [myProfileVC setTargetUser:USER];
        [myProfileVC setIsPushed:YES];
        [self.navigationController pushViewController:myProfileVC animated:YES];
        
    }
    else
    {
        OMOtherProfileViewController *otherProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherProfileVC"];
        otherProfileVC.is_type = 0;
        [otherProfileVC setTargetUser:_user];
        [self.navigationController pushViewController:otherProfileVC animated:YES];
        
    }
}

- (void) zoomImage:(UITableViewCell *)_cell
{
    NSLog(@"touched image to zoom in");
    currentMediaCell = _cell;
    
    TGRImageViewController *viewController;
    OMMediaCell* tmpCell = (OMMediaCell* )_cell;
    viewController = [[TGRImageViewController alloc] initWithImage:tmpCell.imageViewForMedia.image];
    viewController.transitioningDelegate = self;
    viewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH_ROTATED, SCREEN_HEIGHT_ROTATED);
    [TABController presentViewController:viewController animated:YES completion:nil];
}

- (void)playAudio:(PFObject *)_obj
{
    
    PFFile *audioFile = (PFFile *)_obj[@"postFile"];
    
    if (audioFile) {
        NSData *fetchedData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:audioFile.url]];
        if (audioPlayer)
        {
            [audioPlayer stop]; //data is an iVar holding any existing playing music
            audioPlayer = nil;
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fetchedData error:nil];
        audioPlayer.delegate = self;
        [audioPlayer play];
        
    }
}


#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kTag_NewPhoto:
        {
            switch (buttonIndex) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kTag_NewAudio:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [TABController postAudio:kTypeUploadPost
                                   mediaKind:kTypeCaptureAudio
                               currentObject:currentObject
                                   audioData:m_audioData postOrder:selectedPostOrder];
                    
                }
                    break;
                case 1:
                {
                    
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case kTag_NewVideo:
        {
            switch (buttonIndex) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case kTag_EventShare:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self shareViaEmail];
                }
                    break;
                    
                case 1:
                {
                    [self shareViaFacebook];
                }
                    break;
                    
                case 2:
                {
                    [self shareViaTwitter];
                }
                    break;
                case 3:
                {
                    [self shareViaInstagram];
                }
                    break;
                    
                case 4:
                {
                    [self performSelector:@selector(showAddMediaAfter) withObject:nil afterDelay:0.1f];
                }
                    break;
                    
                case 5:
                {
                    [self tagFolders];
                }
                    break;
                    
                case 6:
                {
                    [self performSelector:@selector(exportToPDF) withObject:nil afterDelay:0.1f];
                }
                    break;
                    
                case 7:
                {
                    [self duplicateToNewEvent];
                }
                    break;
                    
                case 8:
                {
                    [self deleteEvent];
                }
                    break;
                    
                case 9:
                {
                    PFUser *user = (PFUser *)currentObject[@"user"];
                    if ([user.objectId isEqualToString:USER.objectId]) {
                        
                        NSInteger status;
                        
                        if ([currentObject[@"openStatus"] intValue] == 1) {
                            status = 0;
                        }
                        else
                        {
                            status = 1;
                        }
                        [currentObject setObject:[NSNumber numberWithInteger:status] forKey:@"openStatus"];
                        [currentObject saveEventually:^(BOOL succeeded, NSError *error) {}];
                    }
                    else
                    {
                        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportEvent)
                                                       userInfo:nil repeats:NO];
                    }
                }
                    break;
                    
                case 10:
                {
                    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportEvent) userInfo:nil repeats:NO];
                }
                    break;
                //--------------------------------------------//
                case 11:
                {
                    [tblForDetailList setEditing:!tblForDetailList.editing animated:YES];
                    [autoRefreshTimer invalidate];
                    [tblForDetailList reloadData];
                }
                    break;
                //--------------------------------------------//
                default:
                    break;
            }
            
        }
            break;
            
        case kTag_EventShareGuest:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self shareViaEmail];
                }
                    break;
                case 1:
                {
                    [self shareViaFacebook];
                }
                    break;
                case 2:
                {
                    [self shareViaTwitter];
                }
                    break;
                case 3:
                {
                    [self shareViaInstagram];
                }
                    break;
                    
                case 4:
                {
                    [self performSelector:@selector(exportToPDF) withObject:nil afterDelay:0.1f];
                }
                    break;
                case 5:
                {
                    [self duplicateToNewEvent];
                }
                    break;
                    
                case 6:{
                    //Report Event by Guest/Tag user
                    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportEvent) userInfo:nil repeats:NO];
                }
                    break;
                case 7:
                    //--------------------------------------------//
                {
                    [tblForDetailList setEditing:!tblForDetailList.editing animated:YES];
                    [autoRefreshTimer invalidate];
                    [tblForDetailList reloadData];
                }
                    break;
                    //--------------------------------------------//
                default:
                    break;
            }
            
        }
            break;
        case kTag_Share:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [MBProgressHUD showMessag:@"Saving Image to Camera Roll..." toView:self.view];
                    [self saveToCameraRoll];
                }
                    break;
                case 1:
                {
                    [self performSelector:@selector(showAddMediaAfter) withObject:nil afterDelay:0.1f];
                }
                    break;
                case 2:
                {
                    [self useThisAsThumbnail];
                }
                    break;
                case 3:
                {
                    [self deleteFeed];
                }
                    break;
                    
                case 4:
                {
                    //Report Post by Guest/Tag user
                    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportPost) userInfo:nil repeats:NO];
                }
                default:
                    break;
            }
        }
            break;
        case kTag_Share1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [MBProgressHUD showMessag:@"Saving Image to Camera Roll..." toView:self.view];
                    [self saveToCameraRoll];
                }
                    break;
                case 1:
                {
                    [self performSelector:@selector(showAddMediaAfter) withObject:nil afterDelay:0.1f];
                }
                    break;
                case 2:
                {
                    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportPost) userInfo:nil repeats:NO];
                }
                default:
                    break;
            }
        }
            break;
            
        case kTag_TextShare:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self deleteFeed];
                    
                }
                    break;
                    
                case 1:
                {
                    //Report Post
                    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reportPost) userInfo:nil repeats:NO];
                }
                default:
                    break;
            }
        }
            break;
        case kTag_TextShare1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(reportPost) userInfo:nil repeats:NO];
                }
                default:
                    break;
            }
        }
            break;
            
        case kTag_PDF_Select:
        {
            switch (buttonIndex) {
                case 0:
                    exportModeOfPDF = @"all";
                    [self performSelector:@selector(profileModeForPDF) withObject:nil afterDelay:0.1];
                    break;
                case 1:
                    exportModeOfPDF = @"custom";
                    [self performSelector:@selector(profileModeForPDF) withObject:nil afterDelay:0.1];
                    break;
                default:
                    break;
            }
        }
            break;
            
        case kTag_PDF_Profile_Mode:
        {
            
            switch (buttonIndex) {
                case 0:
                    profileModeInPDF = @"user_profile";
                    break;
                case 1:
                    profileModeInPDF = @"company_profile";
                    break;
                default:
                    profileModeInPDF = @"";
                    break;
            }
            
            if (![profileModeInPDF isEqualToString:@""]) {
                if ([exportModeOfPDF isEqualToString:@"all"]) {
                    [self exportToPDFAll];
                } else if ([exportModeOfPDF isEqualToString:@"custom"]) {
                    [self exportToPDFWithSelect];
                }
            }
        }
            break;
            
        case kTag_AddMediaAfter:
        {
            switch (buttonIndex) {
                case 0: //Text
                {
                    if ([currentObject[@"openStatus"] intValue]) {
                        [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCaptureText currentObject:currentObject
                                           postOrder:selectedPostOrder];
                    } else {
                        [OMGlobal showAlertTips:@"Oops!" title:@"This event was closed."];
                    }
                }
                    break;
                case 1: //Image
                {
                    if ([currentObject[@"openStatus"] intValue]) {
                        [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCapturePhoto currentObject:currentObject
                                           postOrder:selectedPostOrder];
                    } else {
                        [OMGlobal showAlertTips:@"Oops!" title:@"This event was closed."];
                    }
                }
                    break;
                case 2: //Audio
                {
                    if ([currentObject[@"openStatus"] intValue]) {
                        [TABController postAudio:kTypeUploadPost mediaKind:kTypeCaptureAudio
                                   currentObject:currentObject audioData:m_audioData postOrder:selectedPostOrder];
                    } else {
                        [OMGlobal showAlertTips:@"Oops!" title:@"This event was closed."];
                    }
                }
                    break;
                case 3: //Video
                {
                    if ([currentObject[@"openStatus"] intValue]) {
                        [TABController newPostAction:kTypeUploadPost mediaKind:kTypeCaptureVideo currentObject:currentObject
                                           postOrder:selectedPostOrder];
                    } else {
                        [OMGlobal showAlertTips:@"Oops!" title:@"This event was closed."];
                    }
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
}

//Report
- (void)reportEvent
{
    [MBProgressHUD showMessag:@"Progressing..." toView:self.view];
    PFQuery *query = [PFQuery queryWithClassName:@"ReportedContent"];
    [query whereKey:@"targetEvent" equalTo:currentObject];
    [query whereKey:@"targetPost" equalTo:[NSNull null]];
    [query whereKey:@"reportedBy" equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (!error) {
            if (number == 0) {
                PFObject *obj = [PFObject objectWithClassName:@"ReportedContent"];
                obj[@"targetEvent"] = currentObject;
                obj[@"reportedBy"] = [PFUser currentUser];
                [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (succeeded) {
                        [OMGlobal showAlertTips:@"Reported successfully. Your report will be reviewed by Administrator." title:nil];
                    } else {
                        [OMGlobal showAlertTips:error.localizedDescription title:@"Error"];
                    }
                }];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [OMGlobal showAlertTips:@"You have already reported this event. Your report will be reviewed by Administrator."
                                  title:nil];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [OMGlobal showAlertTips:error.localizedDescription title:@"Error"];
        }
    }];
}

//Report Event's post
- (void)reportPost
{
    [MBProgressHUD showMessag:@"Progressing..." toView:self.view];
    PFQuery *query = [PFQuery queryWithClassName:@"ReportedContent"];
    [query whereKey:@"targetEvent" equalTo:currentObject];
    [query whereKey:@"targetPost" equalTo:tempObejct];
    [query whereKey:@"reportedBy" equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (!error) {
            if (number == 0) {
                PFObject *obj = [PFObject objectWithClassName:@"ReportedContent"];
                obj[@"targetEvent"] = currentObject;
                obj[@"targetPost"] = tempObejct;
                obj[@"reportedBy"] = [PFUser currentUser];
                [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (succeeded) {
                        [OMGlobal showAlertTips:@"Post reported successfully. Your report will be reviewed by Administrator." title:nil];
                    } else {
                        [OMGlobal showAlertTips:error.localizedDescription title:@"Error"];
                    }
                }];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [OMGlobal showAlertTips:@"You have already reported this post. Your report will be reviewed by Administrator."
                                  title:nil];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [OMGlobal showAlertTips:error.localizedDescription title:@"Error"];
        }
    }];
}

#pragma mark ActionSheet Actions

// Use Image as thumbnail

- (void) useThisAsThumbnail
{
    OMMediaCell* tmpCell = (OMMediaCell*)currentMediaCell;
    UIImage* cellImage = tmpCell.imageViewForMedia.image;
    PFFile *postFile1 = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([cellImage resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
    currentObject[@"thumbImage"] = postFile1;
    
    PFFile *postFile = [PFFile fileWithName:@"postImage.jpg" data:UIImagePNGRepresentation(cellImage)];
    currentObject[@"postImage"] = postFile;
    
    [MBProgressHUD showMessag:@"Changing thumbnail Image..." toView:self.view];
    
    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [tblForDetailList reloadData];
    }];
}

// Save Image to Camera Roll

-(void) saveToCameraRoll
{
    PFFile *file = (PFFile *)tempObejct[@"thumbImage"];
    NSURL *imageURL = [NSURL URLWithString:file.url];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIImage* postImage = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(postImage, nil, nil, nil);
        });
    });
}

// Export feed data table to pdf

- (IBAction)onExportDoneBtn:(id)sender {
    
    [doneView setHidden:YES];
    
    UIButton *tmp = (UIButton*)sender;
    
    if([tmp tag] == kTag_PDF)
    {
        [self doneToPDF];
        
    }
    else if([tmp tag] == kTag_DupEvent)
    {
        [self doneToNewEvent];
    }
}

- (void)doneToPDF
{
    
    if([[GlobalVar getInstance].gArrSelectedList count] > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSArray *sortedArray = [[GlobalVar getInstance].gArrSelectedList sortedArrayUsingComparator:^NSComparisonResult(PFObject *obj1, PFObject *obj2) {
            return [obj2.createdAt compare:obj1.createdAt];
        }];
        
        //-----------------------------------------//
        arrTemp = [sortedArray mutableCopy];
        [arrTargetForGeo removeAllObjects];
        //-----------------------------------------//
        [self getLocationFromObject];
        
    }
    else
    {
        [self onCancelForExport:nil];
    }
    
}

- (void)printPDF
{
    NSMutableDictionary* contentPDF = [[NSMutableDictionary alloc] init];
    
    [contentPDF setObject:currentObject forKey:@"currentObject"];
    [contentPDF setObject:arrTargetForGeo forKey:@"arrDetail"];
    [contentPDF setObject:PFUser.currentUser[@"company"] forKey:@"companyName"];
    [contentPDF setObject:profileModeInPDF forKey:@"profileMode"];
    
    [PDFRenderer createPDF:[self getPDFFilePath] content:contentPDF];
    pdfURL = [NSURL fileURLWithPath:[self getPDFFilePath]];
    
    //Preview the PDF
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    [previewController setDelegate:self];
    [previewController setDataSource:self];
    
    if ([self DeviceSystemMajorVersion] >= 7) {
        previewController.transitioningDelegate = self;
        previewController.modalPresentationStyle = UIModalPresentationCustom;
    } else {
        previewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:previewController animated:YES completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    });
}

-(void)getLocationFromObject{
    
    if([arrTemp count] <= 0)
    {
        NSLog(@"completion ****");
        [self printPDF];
        return;
    }
    else
    {
        PFObject *tempObj = (PFObject*)[arrTemp firstObject];
        
        if (tempObj[@"countryLatLong"] && ![tempObj[@"countryLatLong"] isEqualToString:@""]) {
            
            [arrTargetForGeo addObject:tempObj];
            [arrTemp removeObject:tempObj];
            
            NSLog(@"has long-----");
            
            [self getLocationFromObject];
        }
        else{
            
            if (tempObj[@"country"] && ![tempObj[@"country"] isEqualToString:@"Unknown"]) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                NSLog(@"country +++++%@", tempObj[@"country"]);
                [geocoder geocodeAddressString:tempObj[@"country"] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    
                    if (placemarks.count > 0) {
                        CLPlacemark *placemark = placemarks.firstObject;
                        CLLocationCoordinate2D location = placemark.location.coordinate;
                        
                        int latSeconds = (int)(location.latitude * 3600);
                        int latDegrees = latSeconds / 3600;
                        latSeconds = ABS(latSeconds % 3600);
                        int latMinutes = latSeconds / 60;
                        latSeconds %= 60;
                        
                        int longSeconds = (int)(location.longitude * 3600);
                        int longDegrees = longSeconds / 3600;
                        longSeconds = ABS(longSeconds % 3600);
                        int longMinutes = longSeconds / 60;
                        longSeconds %= 60;
                        
                        NSString* result = [NSString stringWithFormat:@"%d°%d'%d\"%@ %d°%d'%d\"%@",
                                            ABS(latDegrees),
                                            latMinutes,
                                            latSeconds,
                                            latDegrees >= 0 ? @"N" : @"S",
                                            ABS(longDegrees),
                                            longMinutes,
                                            longSeconds,
                                            longDegrees >= 0 ? @"E" : @"W"];
                        
                        tempObj[@"countryLatLong"] = result;
                        [arrTargetForGeo addObject:tempObj];
                        [arrTemp removeObject:tempObj];
                        NSLog(@"passed ----- ");
                        [self getLocationFromObject];
                   }
                    else
                    {
                        tempObj[@"countryLatLong"] = @"Unknown";
                        [arrTargetForGeo addObject:tempObj];
                        [arrTemp removeObject:tempObj];
                        [self getLocationFromObject];
                        
                    }
                }];

            }
            else{
                
                tempObj[@"countryLatLong"] = @"Unknown";
                [arrTargetForGeo addObject:tempObj];
                [arrTemp removeObject:tempObj];
                
                NSLog(@"has long-----");
                [self getLocationFromObject];
            }
            
            
        }
  
    }

}

//for duplication
- (void) doneToNewEvent
{
    if([[GlobalVar getInstance].gArrSelectedList count] > 0)
    {
        [GlobalVar getInstance].gThumbImg = nil;
        for (PFObject *postObj in [GlobalVar getInstance].gArrSelectedList) {
            if([postObj[@"postType"] isEqualToString:@"photo"])
            {
                [GlobalVar getInstance].gThumbImg = (PFFile *)postObj[@"thumbImage"];
                break;
            }
        }
        
        [GlobalVar getInstance].gEventObj = currentObject;
        
        [doneView setHidden:YES];
        modeForExport = NO;
        [tblForDetailList reloadData];
        
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenPostEvent object:nil];
        
        
    }
    else
    {
        [self onCancelForExport:nil];
    }
}

- (void) profileModeForPDF {
    UIActionSheet* shareAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Display User Profile", @"Display Name + Company", nil];
    
    [shareAction showInView:self.view];
    shareAction.tag = kTag_PDF_Profile_Mode;
}

- (void) exportToPDF {
    UIActionSheet* shareAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Select All" otherButtonTitles:@"Select Items", nil];
    
    [shareAction showInView:self.view];
    shareAction.tag = kTag_PDF_Select;
}

- (void) exportToPDFWithSelect
{
    if(!modeForExport)
    {
        [doneView setHidden:NO];
        [btnDoneForExport setTag:kTag_PDF];
        modeForExport = YES;
        [GlobalVar getInstance].isPosting = YES;
        [GlobalVar getInstance].gArrPostList = [arrForDetail mutableCopy];
        
        [tblForDetailList reloadData];
    }
    else
    {
        [self onCancelForExport:nil];
    }
    
}

- (void) exportToPDFAll
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //-----------------------------------------//
    arrTemp = [arrForDetail mutableCopy];
    [arrTargetForGeo removeAllObjects];
    //-----------------------------------------//
    [self getLocationFromObject];
    
}

//for duplication
- (void) duplicateToNewEvent
{
    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
    if(!appDel.network_state)
    {
        [OMGlobal showAlertTips:@"You can't duplicate in offline mode." title:@"Warning"];
        return;
    }
    if(!modeForExport)
    {
        [doneView setHidden:NO];
        [btnDoneForExport setTag:kTag_DupEvent];
        modeForExport = YES;
        [GlobalVar getInstance].isPosting = YES;
        [GlobalVar getInstance].gArrPostList = [arrForDetail mutableCopy];
        
        [tblForDetailList reloadData];
    }
    else
    {
        [self onCancelForExport:nil];
    }
    
}

-(NSString*)getPDFFilePath
{
    NSString* fileName = @"sample.pdf";
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFilePath = [path stringByAppendingPathComponent:fileName];
    
    return pdfFilePath;
}

-(NSUInteger) DeviceSystemMajorVersion {
    
    static NSUInteger _deviceSystemMajorVersion = -1;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
        
    });
    
    return _deviceSystemMajorVersion;
    
}

- (void)createPDFfromUIViews:(UIView *)myImage saveToDocumentsWithFileName:(NSString *)string
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, myImage.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [myImage.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:string];
    
    NSLog(@"%@",documentDirectoryFilename);
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    
}

// delete Event
- (void)deleteEvent
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    [alertView setTag:kTag_EventShare];
    [alertView show];
}

//delete Feed Action
- (void)deleteFeed
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    [alertView setTag:kTag_Share];
    [alertView show];
}

//share Via Email
- (void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView.navigationBar setTintColor:[UIColor whiteColor]];
        [mailView setSubject:currentObject[@"eventname"]];
        [mailView setMessageBody:@"Created by INTELLISPEX App!" isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
        [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [TABController presentViewController:mailView animated:YES completion:nil];
        //        [mailView release];
        
    }
    
}


//share Via Facebook

- (void)shareViaFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Created by INTELLISPEX App!"];
        [controller addURL:[NSURL URLWithString:@"http://collabro.com"]];
        [controller addImage:postImgView.image];
        
        [TABController presentViewController:controller animated:YES completion:Nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your facebook setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

//share Via Twitter
- (void)shareViaTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Created  by My  INTELLISPEX App!"];
        [tweetSheet addURL:[NSURL URLWithString:@"http://Collabro.com"]];
        [tweetSheet addImage:postImgView.image];
        
        [TABController presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Confirm your twitter setting."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)shareViaInstagram
{
    UIImage * screenshot = postImgView.image;//[[CCDirector sharedDirector] screenshotUIImage];
    // UIImage *screenshot = [UIImage imageNamed:@"splash@2x.png"];
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Screenshot.igo"];
    
    // Write image to PNG
    [UIImageJPEGRepresentation(screenshot, 1.0) writeToFile:savePath atomically:YES];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //imageToUpload is a file path with .ig file extension
        dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        dic.UTI = @"com.instagram.exclusivegram";
        dic.delegate = self;
        
        dic.annotation = [NSDictionary dictionaryWithObject:@"Uploaded using #INTELLISPEX App" forKey:@"InstagramCaption"];
        //[dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
        if (IS_IPAD) {
            [self performSelector:@selector(openDicOniPad:) withObject:nil afterDelay:0.5];
        }
        else{
            [dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
    }
    else
    {
        [OMGlobal showAlertTips:@"Please install Instagram app" title:nil];
    }
    
}
-(void)openDicOniPad:(id)sender{
    [dic presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

//Add Media After
- (void)showAddMediaAfter {
    UIActionSheet* shareAction = nil;
    shareAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text", @"Image", @"Audio", @"Video", nil];
    [shareAction showInView:self.view];
    shareAction.tag = kTag_AddMediaAfter;
}

- (void)tagFolders
{
    OMTagFolderViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagFolderVC"];
    tagListVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
    [TABController presentViewController:nav animated:YES completion:nil];
    
}


#pragma mark UIAlertView
// deletefeed result
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == kTag_Share) {
        switch (buttonIndex) {
            case 0:
            {
                
                [MBProgressHUD showMessag:@"Deleting..." toView:self.view];
                OMAppDelegate * appDel = (OMAppDelegate*)[UIApplication sharedApplication].delegate;
                
                // In Case Online Mode
                if(appDel.network_state)
                {
                    [GlobalVar getInstance].isPosting = YES;
                    [tempObejct deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [GlobalVar getInstance].isPosting = NO;
                        if (error == nil) {
                            [self loadContents];
                            
                            PFUser *eventUser = currentObject[@"user"];
                            if([eventUser.objectId isEqualToString: USER.objectId] && appDel.network_state)
                            {
                                
                            }
                            else
                            {
                                // badge feature processing after deleting one Post :for badge
                                if([currentObject[@"postedObjects"] containsObject:tempObejct])
                                {
                                    [currentObject[@"postedObjects"] removeObject:tempObejct];
                                    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if(error == nil) NSLog(@"DetailEventVC:Badge Processing - remove from one PostObj on Event Field");
                                    }];
                                }
                            }
                        }
                    }];
                }
                // In Case Offline Mode
                else
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSInteger index = -1;
                    
                    if([appDel.m_offlinePosts count]!= 0 && currentCellOfflineUrl != nil)
                    {
                        index = [appDel.m_offlinePosts indexOfObject:tempObejct];
                        [appDel.m_offlinePosts removeObject:tempObejct];
                        
                        if ([tempObejct[@"postType"] isEqualToString:@"video"]) {
                            
                            if(index != -1)
                                [appDel.m_offlinePostURLs removeObjectAtIndex:index];
                        }
                        [self loadContents];
                        
                    }
                    else if([arrForDetail count] != 0 && currentCellOfflineUrl == nil)
                    {
                        [GlobalVar getInstance].isPosting = YES;
                        [tempObejct deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [GlobalVar getInstance].isPosting = NO;
                            if (error == nil) {
                                if([currentObject[@"postedObjects"] containsObject:tempObejct]) {
                                    [currentObject[@"postedObjects"] removeObject:tempObejct];
                                }
                                [self loadContents];
                            }
                        }];
                    }
                    
                }
            }
                break;
                
            default:
                break;
        }
        
    }
    //deleteevent
    else if (alertView.tag == kTag_EventShare)
    {
        switch (buttonIndex) {
            case 0:
            {
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                
                [self.view addSubview:hud];
                [hud setLabelText:@"Deleting..."];
                [hud show:YES];
                
                [GlobalVar getInstance].isPosting = YES;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                [currentObject setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"deletedAt"];
                [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [hud hide:YES];
                    [GlobalVar getInstance].isPosting = NO;
                    if (succeeded) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
                break;
                
            default:
                break;
        }
        
    }
}

#pragma mark - Tag Folder delegate

- (void)selectFolderCancel:(OMTagFolderViewController *)fsCategoryVC
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedFolders:(OMTagFolderViewController *)tagVC didFinished:(NSMutableArray *)_dict
{
    [tagVC.navigationController dismissViewControllerAnimated:YES completion:^{
        
        [self addTagFolders:(NSMutableArray *)_dict];
    }];
}

- (void)addTagFolders:(NSMutableArray *)_dict
{
    NSString * folderNames;
    folderNames = @"";
    
    for (PFObject* folder in _dict)
    {
        NSMutableArray *Eventarr = nil;
        
        if (!(folder[@"Events"]))
            Eventarr = [[NSMutableArray alloc] init];
        else
            Eventarr = folder[@"Events"];
        
        if(![Eventarr containsObject:currentObject.objectId])
        {
            [Eventarr addObject:currentObject.objectId];
            folder[@"Events"] = Eventarr;
            
            [folder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFolderData object:nil];
                }
                else
                {
                    [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                }
                
            }];
        }
        else
        {
            folderNames = [folderNames stringByAppendingString:[NSString stringWithFormat:@"<%@>,",folder[@"Name"]]];
        }
    }
    if(![folderNames isEqualToString:@""])
    {
        NSString *msg = [NSString stringWithFormat:@"Event had already existed on %@ folder.", folderNames];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        
        if (currentMediaCell)
        {
            OMMediaCell* tmpCell = (OMMediaCell* )currentMediaCell;
            UIImageView *imgView = [[UIImageView alloc] initWithImage:tmpCell.imageViewForMedia.image];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imgView];
        }
        else
            return nil;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        if (currentMediaCell)
        {
            OMMediaCell* tmpCell = (OMMediaCell* )currentMediaCell;
            UIImageView *imgView = [[UIImageView alloc] initWithImage:tmpCell.imageViewForMedia.image];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:imgView];
        }
        else
            return nil;
    }
    return nil;
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"Full";
            break;
        case 1:
            return @"Photo Only";
            break;
        case 2:
            return @"Audio Only";
            break;
        case 3:
            return @"Video Only";
            break;
        case 4:
            return @"Text only";
            break;
        default:
            break;
    }
    
    return nil;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
        {
            is_type = nil;
        }
            break;
        case 1:
        {
            is_type = @"photo";
        }
            break;
        case 2:
        {
            is_type = @"audio";
        }
            break;
        case 3:
        {
            is_type = @"video";
            
            break;
        }
        case 4:
        {
            is_type = @"text";
            
            break;
        }
        default:
            is_type = nil;
            break;
    }
    
}

#pragma mark - QLPreviewController Delegate methods
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return pdfURL;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller{
    pdfURL = nil;
    [self onCancelForExport:nil];
}

#pragma mark Newwork connecting Check - help and Auto refresh features
-(void) callAfterSixtySecond:(NSTimer*) t {
    
    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable && appDel.network_state) {
        
        NSLog(@"There IS NO internet connection");
        appDel.network_state = NO;
        
        UIImage *btnImage = [UIImage imageNamed:@"offline_state.png"];
        [btnForNetState setImage:btnImage forState:UIControlStateNormal];
        
    } else {
        
//        NSLog(@"There IS internet connection");
//        appDel.network_state = YES;
//
//        UIImage *btnImage = [UIImage imageNamed:@"online_state.png"];
//        [btnForNetState setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (![GlobalVar getInstance].isPosting) {
        
        [self reloadContents];
        
        if (networkStatus != NotReachable && appDel.network_state) //Check both Reachability & Network Status
        {
            OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
            
            for(PFObject* post in appDel.m_offlinePosts)
            {
                //Request a background execution task to allow us to finish uploading the photo even if the app is background
                self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
                
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Auto Refresh with offline mode:Post Success!");
                        
                        [post fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            [[OMPushServiceManager sharedInstance] sendNotificationToTaggedFriends:object];
                            [appDel.m_offlinePosts removeObject:post];
                        }];
                    }
                    else
                    {
                        NSLog(@"Post Error = %@", error.description);
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
            }
        }
    }
    else
    {
        NSLog(@"Skipped Auto Refreshing due to in posting!!");
    }
}

//----------------------------------------------------------//
//---delegate method

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.row != 0) {
        return NO;
    }else return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
        if (destinationIndexPath.section == 0) {
                NSLog(@"Exception : Event Section");
            [tblForDetailList reloadData];
        }else {
            [arrForDetail exchangeObjectAtIndex:sourceIndexPath.section-1 withObjectAtIndex:destinationIndexPath.section-1];
            
            
            
            PFObject *t1 = [arrForDetail objectAtIndex:(sourceIndexPath.section-1)];
            PFObject *t2 = [arrForDetail objectAtIndex:(destinationIndexPath.section-1)];
            
            NSNumber *temp = t1[@"postOrder"];
            t1[@"postOrder"] = t2[@"postOrder"];
            t2[@"postOrder"] = temp;
            
            [t1 save];
            [t2 save];
            
            // Current Test feature. lets check these again.
            PFUser *eventUser = currentObject[@"user"];
            OMAppDelegate* appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
            if([eventUser.objectId isEqualToString: USER.objectId] && appDel.network_state)
            {
                currentObject[@"postedObjects"] = arrForDetail;
                [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil) NSLog(@"DetailEventVC: added Post objs on postedObjects on Event");
                }];
            }
            
            [tblForDetailList setEditing:!tblForDetailList.editing animated:YES];
            autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
            [tblForDetailList reloadData];
            NSLog(@"prev === %ld, to === %ld", (long)sourceIndexPath.row, (long)destinationIndexPath.row);
        }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return NO;
}

//----------------------------------------------------------------//
-(void)initializeBadges{
    [lbl_card_count removeFromSuperview];
    
    lbl_card_count = [[UILabel alloc]initWithFrame:CGRectMake(10,0, 14, 14)];
    lbl_card_count.textColor = [UIColor whiteColor];
    lbl_card_count.textAlignment = NSTextAlignmentCenter;
    lbl_card_count.text = @"0";
    lbl_card_count.layer.borderWidth = 1;
    lbl_card_count.layer.cornerRadius = 8;
    lbl_card_count.layer.masksToBounds = YES;
    lbl_card_count.layer.borderColor =[[UIColor clearColor] CGColor];
    lbl_card_count.layer.shadowColor = [[UIColor clearColor] CGColor];
    lbl_card_count.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    lbl_card_count.layer.shadowOpacity = 0.0;
    lbl_card_count.backgroundColor = [UIColor redColor];
    lbl_card_count.font = [UIFont fontWithName:@"ArialMT" size:11];
    
    [btnNotification addSubview:lbl_card_count];
    
    [lbl_card_count setHidden:YES];
    
    OMSocialEvent *temp = (OMSocialEvent*)currentObject;
    
    if (temp.badgeCount == 0) {
        
        [lbl_card_count setHidden:YES];
        btnNotification.enabled = NO;
    } else {
        [lbl_card_count setHidden:NO];
        [lbl_card_count setText:[NSString stringWithFormat:@"%lu",(long)temp.badgeCount]];
        btnNotification.enabled = YES;
    }
    
}

- (IBAction)actionShowingNewActivities:(id)sender {
    
    OMEventNotiViewController *notiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiEventVC"];
    notiVC.event = (OMSocialEvent*)currentObject;
    notiVC.curEventIndex = curEventIndex;
    notiVC.delegate = self;
    [self.navigationController pushViewController:notiVC animated:YES];
}

-(void)processBadges:(NSNotification*)not{    
    OMSocialEvent *temp = (OMSocialEvent*)[[GlobalVar getInstance].gArrEventList objectAtIndex:curEventIndex];
    
    if (temp.badgeCount == 0) {
        
        [lbl_card_count setHidden:YES];
        btnNotification.enabled = NO;
        
        if(temp.badgeNotifier > 0)
        {
            [lbl_card_count setHidden:NO];
            [lbl_card_count setText:[NSString stringWithFormat:@"%lu",(long)temp.badgeNotifier]];
            btnNotification.enabled = YES;
        }
        
    } else {
        [lbl_card_count setHidden:NO];
        [lbl_card_count setText:[NSString stringWithFormat:@"%lu",(long)temp.badgeCount]];
        btnNotification.enabled = YES;
    }
}

#pragma mark - Delegate method of OMEventNotiViewController
- (void)notificationSelected:(PFObject *)post {
    NSInteger section = [arrForDetail indexOfObject:post];
    if (section != NSNotFound) {
        [self processBadges:nil];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section+1];
        [self.tblForDetailList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
