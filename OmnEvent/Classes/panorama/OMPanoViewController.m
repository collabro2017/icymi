//
//  OMPanoViewController.m
//  ICYMI
//
//  Created by lion on 11/20/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMPanoViewController.h"
#import "OMPhotoEditViewController.h"

#import "PLITViewerVC.h"
#import "PLITViewerVC+Controls.h"
#import "PLITInfoView.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define TXT_HOLD_DEVICE_VERTICAL NSLocalizedString(@"Hold your device vertically", @"")
#define TXT_MOVE_LEFT_RIGHT NSLocalizedString(@"Rotate left or right or tap to restart", @"")
#define TXT_KEEP_MOVING NSLocalizedString(@"Tap to finish when ready or continue rotating", @"")
#define TXT_TAP_TO_START NSLocalizedString(@"Tap anywhere to start", @"")

@interface OMPanoViewController ()

- (void)willEnterForeground:(NSNotification*)notification;

- (void)userTapped:(UIGestureRecognizer*)gs;
- (void)start:(id)sender;
- (void)restart:(id)sender;
- (void)stop:(id)sender;

- (void)savePanorama;

@end

@implementation OMPanoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Monitor instance].delegate = self;
    
    CGRect frame  = [[UIScreen mainScreen] bounds];
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
        frame.size.height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    UIView *aView = [[UIView alloc] initWithFrame:frame];
    [aView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.view = aView;
    
    _shooterView = [[ShooterView alloc] initWithFrame:frame];
    [aView addSubview:_shooterView];
    
    CGRect infoViewFrame;
    CGRect infoViewSubFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        infoViewFrame = CGRectMake(15.f, (frame.size.height-100.f)/2.f, frame.size.width-30.f, 100.f);
        infoViewSubFrame = CGRectOffset(CGRectInset(infoViewFrame, 35, 0), 35, frame.size.height-infoViewFrame.origin.y-infoViewFrame.size.height-20.f);
    }
    else
    {
        infoViewFrame = CGRectMake(frame.size.width/2.f-200.f, (frame.size.height-100.f)/2.f, 400.f, 100.f);
        infoViewSubFrame = CGRectOffset(infoViewFrame, 0, frame.size.height-infoViewFrame.origin.y-infoViewFrame.size.height-20.f);
    }
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.delegate = self;
    [_shooterView addGestureRecognizer:_tapRecognizer];
    
    _activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityInd.hidesWhenStopped = YES;
    [_activityInd stopAnimating];
    _activityInd.center = aView.center;
    [aView addSubview:_activityInd];
    
    _infoView = [[PLITInfoView alloc] initWithFrame:infoViewFrame];
    [_infoView setSubFrame:infoViewSubFrame];
    [_infoView setText:TXT_HOLD_DEVICE_VERTICAL];
    [_shooterView insertSubview:_infoView atIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidAppear:(BOOL)animated
{
    _shooterView.hidden = NO;
    [self restart:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [_activityInd stopAnimating];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _shooterView.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)willEnterForeground:(NSNotification*)notification
{
    _shooterView.hidden = NO;
    [self restart:nil];
}

#pragma mark -
#pragma mark controls

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSArray *arr = _shooterView.flashControls;
    for (UIView* v in arr)
        if (v==touch.view)
            return NO;
    arr = _shooterView.exposureControls;
    for (UIView* v in arr)
        if (v==touch.view)
            return NO;
    return YES;
}

- (void)userTapped:(UIGestureRecognizer*)gs
{
    if (_numShots==1)
        [self restart:gs];
    else if (_numShots>1)
        [self stop:gs];
    else
        [self start:gs];
    
}

- (void)start:(id)sender
{
    [[Monitor instance] startShooting];
    _numShots = 0;
    
    [_infoView setText:TXT_MOVE_LEFT_RIGHT];
    [_infoView switchToSubFrame];
}

- (void)restart:(id)sender
{
    [[Monitor instance] restart];
    _numShots = -1;
}

- (void)stop:(id)sender
{
    if (_numShots>1)
        [[Monitor instance] finishShooting];
}

#pragma mark -
#pragma mark DMD

- (void)takingPhoto
{
    UIView *camView = self.view;
    self.view.window.backgroundColor = [UIColor whiteColor];
    camView.alpha = 0.1f;
    [UIView animateWithDuration:0.6 animations:^{
        camView.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.view.window.backgroundColor = [UIColor blackColor];
    }];
}

- (void)photoTaken
{
    _numShots += 1;
    if (_numShots==2)
        [_infoView setText:TXT_KEEP_MOVING];
}

- (void)shootingCompleted
{
    _shooterView.hidden = YES;
    [_activityInd startAnimating];
}

- (void)stitchingCompleted:(NSDictionary *)dict
{
    [self savePanorama];
    
    
    /*
     PLITViewerVC *viewer = [[PLITViewerVC alloc] init];
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewer];
     [self presentViewController:nav animated:YES completion:^{
     //		[viewer setupNavigationController:nav];
     [_activityInd stopAnimating];
     }];
     
     //*/
}

- (void)deviceVerticalityChanged:(NSNumber *)isVertical
{
    _tapRecognizer.enabled = [isVertical boolValue];
    if ([isVertical boolValue])
    {
        if (![[Monitor instance] isShooting])
        {
            [_infoView setText:TXT_TAP_TO_START];
            [_infoView switchToMainFrame];
        }
        else
        {
            if (_numShots==1)
                [_infoView setText:TXT_MOVE_LEFT_RIGHT];
            else
                [_infoView setText:TXT_KEEP_MOVING];
            [_infoView switchToSubFrame];
        }
    }
    else
    {
        [_infoView setText:TXT_HOLD_DEVICE_VERTICAL];
        [_infoView switchToMainFrame];
    }
}

#pragma mark -
#pragma mark -

- (void)savePanorama
{
    NSString *TMP_DIR  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DMD_tmp"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:TMP_DIR withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *ename = [TMP_DIR stringByAppendingPathComponent:@"equi.jpeg"];
    [[Monitor instance] genEquiAt:ename withHeight:800 andWidth:0 andMaxWidth:0];
    
    //*
    //--------------------------------//
    
    OMPhotoEditViewController *photoEditVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoEditVC"];
    
    [photoEditVC setPreImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:ename]]];
    [photoEditVC setPostType:@"image"];
    
    [photoEditVC setUploadOption:self.uploadOption];
    [photoEditVC setCaptureOption:self.captureOption];
    [photoEditVC setCurObj:self.curObj];
    [photoEditVC setPostOrder:_postOrder];
    
    [self.navigationController pushViewController:photoEditVC animated:YES];
    //--------------------------------//
    //*/
    /*
     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
     [library writeImageDataToSavedPhotosAlbum:[NSData dataWithContentsOfFile:ename] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
     if (assetURL)
     {
     [[[UIAlertView alloc] initWithTitle:nil message:@"Image saved to camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]  show];
     }
     else if (error)
     {
     if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError)
     {
     [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Permission needed to access camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
     }
     }
     }];
     //*/
}

@end
