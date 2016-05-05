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

#define MAXIUM_NUM              140;
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface OMPostEventViewController ()<CLLocationManagerDelegate,OMTagListViewControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CLPlacemark *_placeMark;
    NSString *country;
    NSString *city;
    NSString *state;
    CLPlacemark *placeMark;
    
    
    NSMutableArray *arrForTaggedFriend;
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
            else
            {
                
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
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
    }
}

- (void)tagAction
{
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
            post[@"country"] = lblForLocation.text;
            post[@"postType"] = _postType;
            
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
        case kTypeUploadPost:
        {
            PFObject *post = [PFObject objectWithClassName:@"Post"];
            post[@"user"] = USER;
            post[@"targetEvent"] = curObj;
            post[@"title"]          = lblForTitle.text;
            post[@"description"]    = textViewForDescription.text;
            post[@"country"] = lblForLocation.text;

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
            
            BOOL enable_location = NO;
            
            if (enable_location) {
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if (!error) {
                        post[@"location"] = geoPoint;
                        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            if (succeeded) {
                                NSLog(@"Success ---- Post");
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
                //Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                //NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                
                OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
                
                if (!appDel.network_state)  {
                    
                    NSLog(@"There IS NO internet connection");
                    
                    [appDel.m_offlinePosts addObject:post];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

                } else {
                    NSLog(@"There IS internet connection");
                    
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        if (succeeded) {
                            NSLog(@"Success ---- Post");
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

- (void)postEventWhenErrorOccured:(PFObject *)_post
{
    [_post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            NSLog(@"Success ---- Post");
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

- (void)selectedCells:(OMTagListViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:^{
        arrForTaggedFriend = [_dict copy];
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
        }
        else
        {
            [lblForLocation setText:@"Unknown"];
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
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.returnKeyType = UIReturnKeyNext;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textViewForDescription becomeFirstResponder];
    
    return NO;
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (![textView hasText]) {
        
        //        [lblForPlaceholder setHidden:NO];
        
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
    
    NSUInteger max_num = MAXIUM_NUM;
    
    lblForCount.text = [NSString stringWithFormat:@"%lu",max_num - textView.text.length];
    
    if ([lblForCount.text isEqualToString:@"0"]) {
        
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
    return length <= MAXIUM_NUM;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end