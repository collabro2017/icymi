//
//  OMPostEventViewController.m
//  Collabro
//
//  Created by Ellisa on 30/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMPostEventViewController.h"


#import <MediaPlayer/MPMoviePlayerController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>
#import <AVFoundation/AVFoundation.h>

#import <CoreLocation/CoreLocation.h>
#import "UIImage+Resize.h"

#import "OMTagListViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "Reachability.h"
#import "OMAppDelegate.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface OMPostEventViewController ()<CLLocationManagerDelegate,OMTagListViewControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQDropDownTextFieldDelegate>
{
    CLPlacemark *_placeMark;
    NSString *country;
    NSString *countryLatLong;
    NSString *city;
    NSString *state;
    CLPlacemark *placeMark;
    NSMutableArray *arrForTaggedFriend;
    NSMutableArray *arrForTaggedFriendAuthor;
    
    NSMutableArray *arrCurTaggedFriends;
    
    NSMutableArray *arrPostLookedFlags;
    
    NSMutableArray *arrSelected;
    ///
    NSString *strTemp;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation        *location;

@end

@implementation OMPostEventViewController
@synthesize uploadOption, captureOption,curObj,audioData,audioOption;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    // Do any additional setup after loading the view.
    
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [customButton addTarget:self action:@selector(tagAction) forControlEvents:UIControlEventTouchUpInside];
    [customButton setBackgroundImage:[UIImage imageNamed:@"btn_tag"] forState:UIControlStateNormal];
    
    BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    //    UIBarButtonItem *tagBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_tag"] style:UIBarButtonItemStylePlain target:self action:@selector(tagAction)];
    
    
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(uploadAction)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    if (uploadOption == kTypeUploadEvent) {
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, uploadBarButton, negativeSpacer1, barButton,nil];

    }
    else
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, uploadBarButton, negativeSpacer1,nil];

    }
    
    self.title = @"Share To";
    
    [self initializeLocationManager];
    
    arrForTaggedFriend = [NSMutableArray array];
    arrForTaggedFriendAuthor = [NSMutableArray array];
    arrSelected = [NSMutableArray array];
    arrSelected = [[GlobalVar getInstance].gArrSelectedList mutableCopy];
    
    arrCurTaggedFriends = [[NSMutableArray alloc] init];
    
    if([curObj[@"TagFriends"] count] > 0)
    {
        arrCurTaggedFriends = [curObj[@"TagFriends"] mutableCopy];
    }
    
    arrPostLookedFlags = [NSMutableArray array];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    thumbImageForAudio = [UIImage imageNamed:@"layer_audio"];
    [imageViewForPostImage setImage:thumbImageForAudio];
    imageViewForPostImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureForBg = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(changeAudioBackground:)];
    tapGestureForBg.numberOfTapsRequired = 1;
    [tapGestureForBg setDelegate:self];
    [imageViewForPostImage addGestureRecognizer:tapGestureForBg];
    
    lblForCount.text = [NSString stringWithFormat:@"%d", MAX_DESCRIPTION_LIMIT];

    
    /////
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *btnFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:btnFlexible, btnDone, nil]];
    textFieldLocationPicker.inputAccessoryView = toolbar;
    textFieldRoomItemPicker.inputAccessoryView = toolbar;
    textFieldDescriptionPicker.inputAccessoryView = toolbar;
    
    textFieldLocationPicker.delegate = self;
    textFieldRoomItemPicker.delegate = self;
    textFieldDescriptionPicker.delegate = self;
    
    textFieldLocationPicker.isOptionalDropDown = NO;
    [textFieldLocationPicker setItemList:[NSArray arrayWithObjects:@"", @"Attic (Attic1, Attic2)", @"Basement", @"Cellar", @"Crawl space", @"Elevation (A)", @"Elevation (B)", @"Elevation (C)", @"Elevation (D)", @"1st Floor", @"2nd Floor", @"3rd Floor", @"4th Floor", @"Yard", nil]];
    
    textFieldRoomItemPicker.isOptionalDropDown = NO;
    [textFieldRoomItemPicker setItemList:[NSArray arrayWithObjects:@"", @"Living Room", @"Family Room", @"Den",
@"Foyer / Entry", @"Mud Room", @"Kitchen 1",@"Kitchen 2", @"Bathroom 1", @"Bathroom 2", @"Bathroom 3", @"Half Bathroom", @"Bedroom 1", @"Bedroom 2", @"Bedroom 3", @"Bedroom 4", @"Bedroom 5", @"Bedroom 6", @"Bedroom 7", @"Office", @"Library", @"Storage 1", @"Storage 2", @"Storage 3", @"Storage 4", @"Storage 5", @"Mechanical Room 1", @"Mechanical Room 2", @"Mechanical Room 3", @"Dining Room", @"Kitchenette", @"Hallway 1", @"Hallway 2", @"Hallway 3", @"Hallway 4", @"Garage 1", @"Garage 2", @"Garage 3", @"Garage Door 1", @"Garage Door 2", @"Garage Door 3", @"Garage Door 4", @"Deck/porch/balcony/lanai 1", @"Deck/porch/balcony/lanai 2", @"Interior Stairs 1", @"Interior Stairs 2", @"Interior Stairs 3", @"Exterior Stairs 1", @"Exterior Stairs 2", @"Exterior Stairs 3", @"Roof 1", @"Roof 2", @"Roof 3", @"Roof 4", @"Roof 5", @"Driveway", @"Electrical Panel 1", @"Electrical Panel 2", @"Electrical Panel 3", @"Electrical Meter 1", @"Electrical Meter 2", @"Electrical Meter 3", @"Water Meter 1", @"Water Meter 2", @"Water Meter 3", @"Gas Meter 1", @"Gas Meter 2", @"Gas Meter 3", @"Water Heater 1", @"Water Heater 2", @"Water Heater 3", @"Boiler 1", @"Boiler 2", @"Furnace 1", @"Furnace 2", @"Furnace 3", @"A/C condenser 1", @"A/C condenser 2", @"A/C condenser 3", @"Windows", @"Gutters / Downspouts", @"Exterior Surfaces", nil]];
    
    textFieldDescriptionPicker.isOptionalDropDown = NO;
    [textFieldDescriptionPicker setItemList:[NSArray arrayWithObjects:@"", @"For Reference", @"Comment", nil]];
    strTemp = @"";

    ////-----------
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];  
    
    switch (uploadOption) {
        case kTypeUploadEvent:
        {
            if ([_postType isEqualToString:@"video"]) {
                
                if (_outPutURL) {
                    
                    [imageViewForPostImage setImage:[OMGlobal thumbnailImageForVideo:_outPutURL atTime:0.3f]];
                    thumbImageForVideo = [OMGlobal thumbnailImageForVideo:_outPutURL atTime:0.3f];                    
                    UIButton *btnForPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
                    
                    btnForPlay.center = imageViewForPostImage.center;
                    [btnForPlay setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
                    [viewForPost addSubview:btnForPlay];
                    
                }
                
                mediaData = [NSData dataWithContentsOfURL:_outPutURL];
            }
            else if ([_postType isEqualToString:@"image"])
            {
                [imageViewForPostImage setImage:_imageForPost];
                mediaData = UIImageJPEGRepresentation(_imageForPost, 0.9f);
                
            }
            
        }
            break;
            
            
        case kTypeUploadDup:
        {
         // For event thumbnail...
            if([GlobalVar getInstance].gThumbImg != nil)
            {
                PFFile *tmp = [GlobalVar getInstance].gThumbImg;
                [imageViewForPostImage setImageWithURL:[NSURL URLWithString:tmp.url] placeholderImage:[UIImage imageNamed:@"img_thumbnail"]];
            }
            else
            {
                [imageViewForPostImage setImage:[UIImage imageNamed:@"img_thumbnail"]];
            }
            
        }
            break;
        case kTypeUploadPost:
        {
            switch (captureOption) {
                case kTypeCaptureAudio:
                {
                    //[imageViewForPostImage setImage:thumbImageForAudio];
                    
                    UIButton *btnForPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                    
                    btnForPlay.center = imageViewForPostImage.center;
                    [btnForPlay setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
                    [viewForPost addSubview:btnForPlay];
                    
                }
                    break;
                case kTypeCaptureText:
                {
                    constraintForWidth.constant = 0;
                }
                    break;
                default:
                {
                    if ([_postType isEqualToString:@"video"]) {
                        
                        if (_outPutURL) {
                            
                            [imageViewForPostImage setImage:[OMGlobal thumbnailImageForVideo:_outPutURL atTime:0.3f]];
                            thumbImageForVideo = [OMGlobal thumbnailImageForVideo:_outPutURL atTime:0.3f];
                            
                            UIButton *btnForPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                            
                            btnForPlay.center = imageViewForPostImage.center;
                            [btnForPlay setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
                            [viewForPost addSubview:btnForPlay];
                            
                        }
                        
                        mediaData = [NSData dataWithContentsOfURL:_outPutURL];
                    }
                    else if ([_postType isEqualToString:@"image"])
                    {
                        [imageViewForPostImage setImage:_imageForPost];
                        mediaData = UIImageJPEGRepresentation(_imageForPost, 0.9f);
                        
                    }
                    else
                    {
                        
                    }
                    
                }
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    OMAppDelegate* del = (OMAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (del.m_fLoadingPostView)
        [lblForTitle becomeFirstResponder];
    else
        del.m_fLoadingPostView = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController)
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)initializeLocationManager
{
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; //Whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if(IS_OS_8_OR_LATER) {
        
        [locationManager requestWhenInUseAuthorization];
        //        [locationManager requestAlwaysAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    
    [self setLocationManager:locationManager];
}

- (void)backAction
{
    
    if (_outPutURL) {
        
        [OMGlobal removeImage:_outPutURL.path];
    }
    
    switch (captureOption) {
        case kTypeCaptureAudio:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case kTypeCaptureText:
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            if ([_imageArray count] > 0) {
                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            break;
    }
}

- (void)tagAction
{
    if(uploadOption == kTypeUploadDup)
    {
        
        return;
    }
    OMTagListViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagListVC"];
    tagListVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)uploadAction
{
    if ([textViewForDescription becomeFirstResponder]) {
        
        [textViewForDescription resignFirstResponder];
    }
    if ([lblForTitle becomeFirstResponder]) {
        
        [lblForTitle resignFirstResponder];
    }
    
    //------------------------------------------//
    if ([_imageArray count] > 0) {
        [self uploadBulkImages];
        
        return;
    }
    //------------------------------------------//
    
    // New Create Event and Uploading...
    [MBProgressHUD showMessag:@"Uploading..." toView:self.view];
    
    switch (uploadOption) {
        case kTypeUploadEvent:
        {
            
            PFObject *post = [PFObject objectWithClassName:@"Event"];
            PFUser *currentUser = [PFUser currentUser];
            
            post[@"user"] = currentUser;
            post[@"eventname"] = lblForTitle.text;
            post[@"username"] = USER.username;
            post[@"description"] = textViewForDescription.text;
            post[@"openStatus"] = [NSNumber numberWithInteger:1];
            post[@"TagFriends"] = arrForTaggedFriend;
            post[@"TagFriendAuthorities"] = arrForTaggedFriendAuthor;
            post[@"country"] = lblForLocation.text;
            post[@"countryLatLong"] = countryLatLong;
            post[@"postType"] = _postType;
            
            //for badge
            post[@"eventBadgeFlag"] = arrForTaggedFriend;
 
            //image upload
            
            if ([_postType isEqualToString:@"video"]) {
                
                PFFile *postFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([thumbImageForVideo resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
                post[@"thumbImage"] = postFile;
                PFFile *videoFile = [PFFile fileWithName:@"video.mov" data:mediaData];
                post[@"video"] = videoFile;
            }
            else if ([_postType isEqualToString:@"image"])
            {
                PFFile *thumbFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([_imageForPost resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
                post[@"thumbImage"] = thumbFile;
                PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(_imageForPost, 0.9f)];
                post[@"postImage"] = postFile;
                
            }else{
                
            }
            
            
            //Request a background execution task to allow us to finish uploading the photo even if the app is background
            self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            
            BOOL enable_location = NO;//[CLLocationManager locationServicesEnabled];
            
            if (enable_location) {
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if (!error) {
                        post[@"locationData"] = geoPoint;
                        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            if (succeeded) {
                                NSLog(@"Success ---- Post");
                                if (_outPutURL) {
                                    
                                    [OMGlobal removeImage:_outPutURL.path];
                                }
                                
                                [self sendPushToTaggedFriends:post];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            }
                            else
                            {
                                [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                            }
                            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                        }];
                    }
                    else
                    {
                        [self postEventWhenErrorOccured:post];
                    }
                }];
            }
            else
            {
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if (succeeded) {
                        NSLog(@"Success ---- Post");
                        if (_outPutURL) {
                            
                            [OMGlobal removeImage:_outPutURL.path];
                       }
                        [self sendPushToTaggedFriends:post];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
            }
            
        }
            break;
            
        case kTypeUploadDup:
        {
            
            PFObject *post = [PFObject objectWithClassName:@"Event"];
            
            post[@"user"] = USER;
            post[@"eventname"] = lblForTitle.text;
            post[@"username"] = USER.username;
            post[@"description"] = textViewForDescription.text;
            post[@"openStatus"] = [NSNumber numberWithInteger:1];
            
            // Using origin Event's Tag and TagAuthor values
            PFObject *temp = [GlobalVar getInstance].gEventObj;
            
            NSMutableArray *arrTemp = [NSMutableArray array];
            if(temp[@"TagFriends"])
            {
                arrTemp = [temp[@"TagFriends"] mutableCopy];
            }
            
            if([arrTemp count] > 0)
            {
                
                NSMutableArray *arrTempAuth = [NSMutableArray array];
                if(temp[@"TagFriendAuthorities"])
                {
                    arrTempAuth = [temp[@"TagFriendAuthorities"] mutableCopy];
                }
                /*
                NSInteger i = 0;
                for (NSString* objid in arrTemp) {
                    
                    if([objid isEqualToString:USER.objectId])
                    {
                        [arrTemp removeObject:objid];
                        
                        if([arrTempAuth count] > i)
                            [arrTempAuth removeObjectAtIndex:i];
                    }
                    i++;
                }
                 */
                
                post[@"TagFriends"] = arrTemp;
                post[@"TagFriendAuthorities"] = arrTempAuth;
            }
            else
            {
                post[@"TagFriends"]= arrForTaggedFriend;
                post[@"TagFriendAuthorities"] = arrForTaggedFriendAuthor;
            }
            
            
            post[@"country"] = lblForLocation.text;
            post[@"countryLatLong"] = countryLatLong;
            post[@"postType"] = _postType;
            
            //for badge
            post[@"eventBadgeFlag"] = arrTemp;
            
            if([GlobalVar getInstance].gThumbImg)
            {
                post[@"thumbImage"] = [GlobalVar getInstance].gThumbImg;
                post[@"postImage"]  = [GlobalVar getInstance].gThumbImg;
            }
            else
            {
                UIImage *def = [UIImage imageNamed:@"img_thumbnail"];
                PFFile *thumbFile = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation(def, 0.8f)];
                post[@"thumbImage"] = thumbFile;

                
                PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(def, 0.9f)];
                post[@"postImage"] = postFile;
            }
            
            post[@"postedObjects"] = [GlobalVar getInstance].gArrSelectedList;
            
            //Request a background execution task to allow us to finish uploading the photo even if the app is background
           // self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
               // [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            //}];
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
               
                if (succeeded) {
                    NSLog(@"Success New event for Dup");
                    [self sendPushToTaggedFriends:post];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                    
                    [self dupPostForNewEvent:post];
                }
                else
                {
                    [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                }
                //[[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        
        }
            break;
            
        // New Post Content Create and Uploading...
            
        case kTypeUploadPost:
        {

            [GlobalVar getInstance].isPosting = YES;
            
            PFObject *post = [PFObject objectWithClassName:@"Post"];
            
            post[@"user"]           = USER;
            post[@"targetEvent"]    = curObj; // Event obj
            post[@"title"]          = lblForTitle.text;
            post[@"description"]    = textViewForDescription.text;
            post[@"country"]        = lblForLocation.text;
            post[@"countryLatLong"] = countryLatLong;
            
            NSMutableArray *allPosts = curObj[@"postedObjects"];
            
                      
            NSNumber *postOrder = [NSNumber numberWithInt:1];
            if (self.postOrder == -1) {
                PFObject *item = allPosts.firstObject; //First Element will contain the object with highest postOrder
                
                if ([item isEqual:[NSNull null]]) {
                    postOrder = [NSNumber numberWithInt:(int)allPosts.count];
                }else{
                    int newOrder = [item[@"postOrder"] intValue] + 1;
                    postOrder = [NSNumber numberWithInt:newOrder];
                }
                
            }
            else if (allPosts.count > 0) {
                PFObject *item = allPosts[self.postOrder];
                postOrder = item[@"postOrder"];
            }
            post[@"postOrder"] = postOrder;
            
            //for badge
            arrPostLookedFlags = [arrCurTaggedFriends mutableCopy];
            PFUser *eventUser = curObj[@"user"];
            if(![eventUser.objectId isEqualToString:USER.objectId])
            {
                [arrPostLookedFlags addObject:eventUser.objectId];
                if ([arrPostLookedFlags containsObject:USER.objectId]) {
                    [arrPostLookedFlags removeObject:USER.objectId];
                }
            }
            
            NSLog(@"PostEventVC: Tagged Friend = %@", arrPostLookedFlags);
            if([arrPostLookedFlags count] > 0) post[@"usersBadgeFlag"] = arrPostLookedFlags;

            switch (captureOption) {
                case kTypeCapturePhoto:
                {
                    post[@"postType"]       = @"photo";                    
                    //image upload
                    PFFile *postFile        = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(_imageForPost, 0.7)];
                    post[@"postFile"]       = postFile;
                    PFFile *thumbFile       = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([_imageForPost resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
                    post[@"thumbImage"]     = thumbFile;
                    
                    
                }
                    break;
                case kTypeCaptureVideo:
                {
                    post[@"postType"]       = @"video";
                    PFFile *thumbFile       = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([thumbImageForVideo resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
                    post[@"thumbImage"]     = thumbFile;
                    PFFile *videoFile       = [PFFile fileWithName:@"video.mov" data:mediaData];
                    post[@"postFile"]       = videoFile;
                    
                }
                    break;
                case kTypeCaptureAudio:
                {
                    post[@"postType"]       = @"audio";
                    
                    if (audioData) {
                        PFFile *audioFile       = [PFFile fileWithName:@"audio.wav" data:audioData];
                        post[@"postFile"]       = audioFile;
                        
                        PFFile *thumbFile       = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([thumbImageForAudio resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
                        post[@"thumbImage"]     = thumbFile;
                    }
                    else
                    {
                        
                    }
                    
                }
                    break;
                case kTypeCaptureText:
                {
                    post[@"postType"]       = @"text";
                }
                    break;
                default:
                    break;
            }
            
            //Request a background execution task to allow us to finish uploading the photo even if the app is background
            
            self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            
            BOOL enable_location = NO;//[CLLocationManager locationServicesEnabled];
            
            if (enable_location) {
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if (!error) {
                        post[@"location"] = geoPoint;
                        
                        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            [GlobalVar getInstance].isPosting = NO;
                            if (succeeded) {
                               
                                NSLog(@"Success ---- Post");
                                
                                //Increment the postOrder for other posts
                                for (int i=0; i<=self.postOrder; i++) {
                                    PFObject *item = allPosts[i];
                                    [item incrementKey:@"postOrder"];
                                    [item save];
                                }
                                
                                // add one Post on Event postedObject field: for badge
                                if(![curObj[@"postedObjects"] containsObject:post])
                                {
                                    [allPosts insertObject:post atIndex:self.postOrder+1];
                                    curObj[@"postedObjects"] = allPosts;
//                                    [curObj addObject:post forKey:@"postedObjects"];
                                    [curObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                        if(error == nil) NSLog(@"PostEventVC:Badge Processing - Added one Post Obj on Event Field");
                                    }];
                                }
                                
                                if (_outPutURL) {
                                   [OMGlobal removeImage:_outPutURL.path];
                                }
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
                                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            }
                            else
                            {
                                [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                            }
                            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                        }];
                    }
                    else
                    {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [OMGlobal showAlertTips:@"An error occured in getting current location" title:nil];
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }
                }];
            }
            else
            {
                
                OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
                
                if (!appDel.network_state) {
                    
                    
                    NSLog(@"Is Offline Mode");
                    
                    [appDel.m_offlinePosts addObject:post];
                   
                    
                    if (_outPutURL != nil){
                        [appDel.m_offlinePostURLs addObject:_outPutURL];
                    } else {
                        NSURL *baseURL = [NSURL fileURLWithPath:@"file://path/to/user/"];
                        [appDel.m_offlinePostURLs addObject:baseURL];
                    }
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];

                } else {
                    
                    NSLog(@"Is Online Mode");
                    [GlobalVar getInstance].isPosting = YES;
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                        if (succeeded) {
                            NSLog(@"Success ---- Post");
                            
                            //Increment the postOrder for other posts
                            for (int i=0; i<=self.postOrder; i++) {
                                PFObject *item = allPosts[i];
                                [item incrementKey:@"postOrder"];
                                [item save];
                            }
                            
                            // add one Post on Event postedObject field: for badge
                            if(![curObj[@"postedObjects"] containsObject:post])
                            {
                                [allPosts insertObject:post atIndex:self.postOrder+1];
                                curObj[@"postedObjects"] = allPosts;
//                                [curObj addObject:post forKey:@"postedObjects"];
                                [curObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    [GlobalVar getInstance].isPosting = NO;
                                    if(error == nil) NSLog(@"PostEventVC:Badge Processing - Added one Post Obj on Event Field");
                                }];
                            }
                            else
                            {
                                [GlobalVar getInstance].isPosting = NO;
                            }
                            
                            if (_outPutURL) {
                                [OMGlobal removeImage:_outPutURL.path];
                            }
                            
                            [post fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                                [[OMPushServiceManager sharedInstance] sendNotificationToTaggedFriends:object];
                            }];
                            
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
                        }
                        else
                        {
                            [GlobalVar getInstance].isPosting = NO;
                            [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                        }
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }];
                }
            }            
        }
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------------------------------//
-(void)uploadBulkImages{
    [MBProgressHUD showMessag:@"Uploading..." toView:self.view];
    
    if ([_imageArray count] > 0){
        UIImage *tempImage = (UIImage*)[_imageArray firstObject];
        
        [GlobalVar getInstance].isPosting = YES;
        
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        
        post[@"user"]           = USER;
        post[@"targetEvent"]    = curObj; // Event obj
        post[@"title"]          = @"";
        post[@"description"]    = @"";
        post[@"country"]        = lblForLocation.text;
        post[@"countryLatLong"] = countryLatLong;
        
        NSMutableArray *allPosts = curObj[@"postedObjects"];
        NSNumber *postOrder = [NSNumber numberWithInt:1];
        if (self.postOrder == -1) {
            PFObject *item = allPosts.firstObject; //First Element will contain the object with highest postOrder
            if ([item isEqual:[NSNull null]]) {
                postOrder = [NSNumber numberWithInt:(int)allPosts.count];
            }else{
                int newOrder = [item[@"postOrder"] intValue] + 1;
                postOrder = [NSNumber numberWithInt:newOrder];
            }
        }
        else if (allPosts.count > 0) {
            PFObject *item = allPosts[self.postOrder];
            postOrder = item[@"postOrder"];
        }
        post[@"postOrder"] = postOrder;
        
        //for badge
        arrPostLookedFlags = [arrCurTaggedFriends mutableCopy];
        PFUser *eventUser = curObj[@"user"];
        if(![eventUser.objectId isEqualToString:USER.objectId])
        {
            [arrPostLookedFlags addObject:eventUser.objectId];
            if ([arrPostLookedFlags containsObject:USER.objectId]) {
                [arrPostLookedFlags removeObject:USER.objectId];
            }
        }

        NSLog(@"PostEventVC: Tagged Friend = %@", arrPostLookedFlags);
        if([arrPostLookedFlags count] > 0) post[@"usersBadgeFlag"] = arrPostLookedFlags;
        
        /**********************************************/
        post[@"postType"]       = @"photo";
        //image upload
        PFFile *postFile        = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(tempImage, 0.7)];
        post[@"postFile"]       = postFile;
        PFFile *thumbFile       = [PFFile fileWithName:@"thumb.jpg" data:UIImageJPEGRepresentation([tempImage resizedImageToSize:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE)], 0.8f)];
        post[@"thumbImage"]     = thumbFile;
        /**********************************************/
        
        //Request a background execution task to allow us to finish uploading the photo even if the app is background
        
        self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        
        BOOL enable_location = NO;//[CLLocationManager locationServicesEnabled];
        
        if (enable_location) {
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    post[@"location"] = geoPoint;
                    
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [GlobalVar getInstance].isPosting = NO;
                        if (succeeded) {
                            
                            NSLog(@"Success ---- Post");
                            
                            //Increment the postOrder for other posts
                            for (int i=0; i<=self.postOrder; i++) {
                                PFObject *item = allPosts[i];
                                [item incrementKey:@"postOrder"];
                                [item save];
                            }
                            
                            // add one Post on Event postedObject field: for badge
                            if(![curObj[@"postedObjects"] containsObject:post])
                            {
                                [allPosts insertObject:post atIndex:self.postOrder+1];
                                curObj[@"postedObjects"] = allPosts;
                                //                                    [curObj addObject:post forKey:@"postedObjects"];
                                [curObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if(error == nil) NSLog(@"PostEventVC:Badge Processing - Added one Post Obj on Event Field");
                                }];
                            }
                            
                            
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
                            //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            
                            
                            
                            [_imageArray removeObject:[_imageArray firstObject]];
                            [self uploadBulkImages];
                            
                        }
                        else
                        {
                            [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                        }
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }];
                }
                else
                {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [OMGlobal showAlertTips:@"An error occured in getting current location" title:nil];
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
            }];
        }
        else
        {
            
            OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
            
            if (!appDel.network_state) {
                
                
                NSLog(@"Is Offline Mode");
                
                [appDel.m_offlinePosts addObject:post];
                
                
                if (_outPutURL != nil){
                    [appDel.m_offlinePostURLs addObject:_outPutURL];
                } else {
                    NSURL *baseURL = [NSURL fileURLWithPath:@"file://path/to/user/"];
                    [appDel.m_offlinePostURLs addObject:baseURL];
                }
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
                
                
                [_imageArray removeObject:[_imageArray firstObject]];
                [self uploadBulkImages];
                
                
            } else {
                
                NSLog(@"Is Online Mode");
                [GlobalVar getInstance].isPosting = YES;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    if (succeeded) {
                        NSLog(@"Success ---- Post");
                        
                        //Increment the postOrder for other posts
                        for (int i=0; i<=self.postOrder; i++) {
                            PFObject *item = allPosts[i];
                            [item incrementKey:@"postOrder"];
                            [item save];
                        }
                        
                        // add one Post on Event postedObject field: for badge
                        if(![curObj[@"postedObjects"] containsObject:post])
                        {
                            [allPosts insertObject:post atIndex:self.postOrder+1];
                            curObj[@"postedObjects"] = allPosts;
                            // [curObj addObject:post forKey:@"postedObjects"];
                            [curObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                [GlobalVar getInstance].isPosting = NO;
                                if(error == nil) NSLog(@"PostEventVC:Badge Processing - Added one Post Obj on Event Field");
                            }];
                        }
                        else
                        {
                            [GlobalVar getInstance].isPosting = NO;
                        }
                        
                        if (_outPutURL) {
                            [OMGlobal removeImage:_outPutURL.path];
                        }
                        
                        [post fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            [[OMPushServiceManager sharedInstance] sendNotificationToTaggedFriends:object];
                        }];
                        
                        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
                        
                        
                        [_imageArray removeObject:[_imageArray firstObject]];
                        [self uploadBulkImages];
                        
                    }
                    else
                    {
                        [GlobalVar getInstance].isPosting = NO;
                        [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }];
            }////////////////////////////////////////////////////////////////
        }
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
    }
}
//------------------------------------------------------------------------------------------------------//

- (void)dupPostForNewEvent:(PFObject*)targetEvent
{
    
    if([arrSelected count] <= 0)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[GlobalVar getInstance].gArrPostList removeAllObjects];
        [[GlobalVar getInstance].gArrSelectedList removeAllObjects];
        NSLog(@"dup success %i", (int)[arrSelected count]);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else
    {
        PFObject *postObj = [arrSelected lastObject];
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        
        post[@"user"]           = postObj[@"user"];
        post[@"targetEvent"]    = targetEvent;
        if(postObj[@"title"] != nil)
        {
            post[@"title"] = postObj[@"title"];
        }
        else
        {
            post[@"title"] = @"";
        }
        
        if(postObj[@"description"] != nil)
        {
            post[@"description"] = postObj[@"description"];
        }
        else
        {
            post[@"description"] = @"";
        }
        
        if(postObj[@"country"] != nil)
        {
            post[@"country"] = postObj[@"country"];
        }
        else
        {
            post[@"country"] = @"";
        }
        
        
        NSMutableArray *tmp = [NSMutableArray array];
        if([targetEvent[@"TagFriends"] count] > 0)
        {
            tmp = targetEvent[@"TagFriends"];
            if([tmp containsObject:USER.objectId])
            {
                [tmp removeObject:USER.objectId];
            }
            
            post[@"usersBadgeFlag"] = tmp;
        }
        
        
        post[@"postType"]       = postObj[@"postType"];
        if(postObj[@"postFile"])
        {
            post[@"postFile"] = postObj[@"postFile"];
        }
        if(postObj[@"thumbImage"])
        {
            post[@"thumbImage"] = postObj[@"thumbImage"];
        }
        
//        if(postObj[@"commentsUsers"] && [postObj[@"commentsUsers"] count]>0)
//        {
//            post[@"commentsUsers"]  = postObj[@"commentsUsers"];
//        }
//        
//        if(postObj[@"commentsArray"] && [postObj[@"commentsArray"] count]>0)
//        {
//            post[@"commentsArray"]  = postObj[@"commentsArray"];
//        }
        
//        if(postObj[@"likers"] && [postObj[@"likers"] count]>0)
//        {
//            post[@"likers"]  = postObj[@"likers"];
//        }
//        if(postObj[@"likeUserArray"] && [postObj[@"likeUserArray"] count]>0)
//        {
//            post[@"likeUserArray"]  = postObj[@"likeUserArray"];
//        }
      
        
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (error == nil) {
                
                if([arrSelected count] > 0)
                {
                    NSLog(@"dup success %i", (int)[arrSelected count]);
                    [arrSelected removeLastObject];
                    [self dupPostForNewEvent:targetEvent];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [[GlobalVar getInstance].gArrPostList removeAllObjects];
                    [[GlobalVar getInstance].gArrSelectedList removeAllObjects];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
            else
            {
                if([arrSelected count] > 0)
                {
                    [arrSelected removeLastObject];
                    [self dupPostForNewEvent:targetEvent];
                }
            }
        }];
    }
}

- (void)postEventWhenErrorOccured:(PFObject *)_post
{
    [_post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            NSLog(@"Success ---- Post");
            
            // add one Post on Event postedObjects field: for badge
            if(![curObj[@"postedObjects"] containsObject:_post])
            {
                [curObj addObject:_post forKey:@"postedObjects"];
                [curObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil) NSLog(@"PostEventVC:Badge Processing - Added one Post Obj on Event Field");
                }];
            }

           if (_outPutURL) {
                
                [OMGlobal removeImage:_outPutURL.path];
                
            }
            [self sendPushToTaggedFriends:_post];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [OMGlobal showAlertTips:@"Uploading Failed." title:nil];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
}

#pragma mark - Push

- (void)sendPushToTaggedFriends:(PFObject *)_post
{
    [[OMPushServiceManager sharedInstance] sendGroupInviteNotification:@"user tagged" groupId:@"" userList:_post[@"TagFriends"]];
}

#pragma mark - Delegate

// Event tagged Friend add
- (void)selectedCells:(OMTagListViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:^{
        arrForTaggedFriend = [_dict copy];
        
        int i = 0;
        [arrForTaggedFriendAuthor removeAllObjects];
        while (i < [arrForTaggedFriend count] ) {
            [arrForTaggedFriendAuthor addObject:@"Full"];
            i++;
        }
        
    }];
}

- (void)selectDidCancel:(OMTagListViewController *)fsCategoryVC
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CLLocationMangerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *someLocation = [locations objectAtIndex:0];
    NSLog(@"%f",someLocation.horizontalAccuracy);
    
    if (someLocation.horizontalAccuracy < 0)
    {
        // No Signal
        NSLog(@"No Signal.");
        
    }
    else if (someLocation.horizontalAccuracy > 163)
    {
        // Poor Signal
        NSLog(@"Poor Signal.");
    }
    else if (someLocation.horizontalAccuracy > 48)
    {
        // Average Signal
        NSLog(@"Average Signal.");
    }
    else
    {
        // Full Signal
        NSLog(@"Full Signal.");
        
    }
    
    CLGeocoder          *geocoder;
    
    __block CLPlacemark *_placemark = nil;
    __block NSString *strCountry,*strCity;
    __block NSString *strState;
    geocoder        = [[CLGeocoder alloc] init];
    
    //    CLLocation *currentLocation = newLocation;
    
    
    [geocoder reverseGeocodeLocation:someLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0) {
            
            _placemark = [placemarks lastObject];
            
            NSLog(@"%@",_placemark.addressDictionary);
            
            NSDictionary *dic = _placemark.addressDictionary;
            strCountry = [dic objectForKey:@"Country"];
            strState    = [dic objectForKey:@"State"];
            strCity   = [dic objectForKey:@"Name"];
            
            
            country = strCountry;
            city    = strCity;
            state   = strState;
            
            lblForLocation.text = [NSString stringWithFormat:@"%@, %@, %@",strCity,strState,strCountry];
            
            //Conver the location to DMS notation
            CLLocationCoordinate2D location = someLocation.coordinate;
            
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
            
            countryLatLong = [NSString stringWithFormat:@"%d°%d'%d\"%@ %d°%d'%d\"%@",
                              ABS(latDegrees), latMinutes, latSeconds, latDegrees >= 0 ? @"N" : @"S",
                              ABS(longDegrees), longMinutes, longSeconds, longDegrees >= 0 ? @"E" : @"W"];
        }
        else
        {
            [lblForLocation setText:@"Unknown"];
            countryLatLong = @"Unknown";
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Invalid Position");
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:lblForTitle]) {
        if (textField.text.length < MAX_TITLE_LIMIT || [string isEqualToString:@""]) {
            return YES;
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyNext;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![strTemp isEqualToString:@""]) {
        if (![strTemp isEqualToString:@""]) {
            
            if ([lblForTitle.text isEqualToString:@""]) {
                lblForTitle.text = [NSString stringWithFormat:@"%@%@%@", lblForTitle.text, strTemp, @";"];
            }
            else{
                NSString *lastChar = [lblForTitle.text substringFromIndex:[lblForTitle.text length] - 1];
                if ([lastChar isEqualToString:@";"]) {
                    lblForTitle.text = [NSString stringWithFormat:@"%@%@%@", lblForTitle.text, strTemp, @";"];
                }else{
                    lblForTitle.text = [NSString stringWithFormat:@"%@%@%@%@", lblForTitle.text, @";", strTemp, @";"];
                }
                
            }
            strTemp = @"";
        }
        
    }

    [self clearSelectListText];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textViewForDescription becomeFirstResponder];
    
    return NO;
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (![textView hasText]) {
        
        [UIView animateWithDuration:0.15f animations:^{
            [lblForPlaceholder setHidden:NO];
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        [UIView animateWithDuration:0.15f animations:^{
            [lblForPlaceholder setHidden:YES];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    NSUInteger max_num = MAX_DESCRIPTION_LIMIT;
    
    lblForCount.text = [NSString stringWithFormat:@"%u",max_num - textView.text.length];
    
    if ([lblForCount.text isEqualToString:@"0"]) {
        
        if ([textViewForDescription becomeFirstResponder]) {
            
            [textViewForDescription resignFirstResponder];
        }
        if ([lblForTitle becomeFirstResponder]) {
            
            [lblForTitle resignFirstResponder];
        }

        lblForCount.textColor = [UIColor redColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if (![textView hasText]) {
        
        [UIView animateWithDuration:0.15f animations:^{
            [lblForPlaceholder setHidden:NO];
        } completion:^(BOOL finished) {
            
        }];
        
        
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [self isAcceptableTextLength:textView.text.length + text.length - range.length];
}

- (BOOL)isAcceptableTextLength:(NSUInteger )length
{
    return length <= MAX_DESCRIPTION_LIMIT;
}

#pragma mark UIGestureRecognizer Delegate

- (void) changeAudioBackground: (id)sender
{
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{

        thumbImageForAudio = image;
        [imageViewForPostImage setImage:thumbImageForAudio];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//-------
-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item
{
    //NSLog(@"%@: %@",NSStringFromSelector(_cmd),item);
    strTemp = item;
}

-(BOOL)textField:(nonnull IQDropDownTextField*)textField canSelectItem:(nullable NSString*)item
{
    NSLog(@"%@: %@",NSStringFromSelector(_cmd),item);
    return YES;
}

-(IQProposedSelection)textField:(nonnull IQDropDownTextField*)textField proposedSelectionModeForItem:(nullable NSString*)item
{
    NSLog(@"%@: %@",NSStringFromSelector(_cmd),item);
    return IQProposedSelectionBoth;
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    if (![strTemp isEqualToString:@""]) {
        if (![strTemp isEqualToString:@""]) {
            
            if ([lblForTitle.text isEqualToString:@""]) {
                lblForTitle.text = [NSString stringWithFormat:@"%@%@%@", lblForTitle.text, strTemp, @";"];
            }
            else{
                NSString *lastChar = [lblForTitle.text substringFromIndex:[lblForTitle.text length] - 1];
                if ([lastChar isEqualToString:@";"]) {
                    lblForTitle.text = [NSString stringWithFormat:@"%@%@%@", lblForTitle.text, strTemp, @";"];
                }else{
                    lblForTitle.text = [NSString stringWithFormat:@"%@%@%@%@", lblForTitle.text, @";", strTemp, @";"];
                }
                
            }
            strTemp = @"";
        }

    }
    
    [self clearSelectListText];
    [self.view endEditing:YES];
}
-(void)clearSelectListText{
    textFieldLocationPicker.text = @"";
    textFieldDescriptionPicker.text = @"";
    textFieldRoomItemPicker.text = @"";
}
//-------
//The event handling method.
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    
    if ([textViewForDescription becomeFirstResponder]) {
        
        [textViewForDescription resignFirstResponder];
    }
    if ([lblForTitle becomeFirstResponder]) {
        
        [lblForTitle resignFirstResponder];
    }

}

@end
