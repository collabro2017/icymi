//
//  OMCameraViewController.m
//  Collabro
//
//  Created by Ellisa on 15/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ProgressBar.h"
#import "SBCaptureToolKit.h"
#import "SBVideoRecorder.h"
#import "DeleteButton.h"
#import "UIImage+Resize.h"

#import "OMPostEventViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define TIMER_INTERVAL 0.05f

#define TAG_ALERTVIEW_CLOSE_CONTROLLER 10086

#define TAG_TOP_BUTTON          100
#define TAG_PHOTO_BUTTON        200
#define TAG_VIDEO_BUTTON        300


@interface OMCameraViewController () {
    
    BOOL isPhotoMode;
    CGFloat defaultValue;
    
    int second;
    int min;
    int hour;
    
}


@property (strong, nonatomic) SBVideoRecorder   *recorder;
@property (strong, nonatomic) ProgressBar       *progressBar;
@property (strong, nonatomic) DeleteButton      *deleteButton;
@property (strong, nonatomic) UIButton          *okButton;

@property (assign, nonatomic) BOOL initialized;
@property (assign, nonatomic) BOOL isProcessingData;

@property (strong, nonatomic) UIImageView *focusRectView;

// Video Control View

@end

@implementation OMCameraViewController
@synthesize uploadOption,captureOption,curObj;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isPhotoMode = YES;
    
    defaultValue = constraintForVideoControl.constant;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
   
    [self initTopBar];
    [self initPhotoControls];
    [self initVideoControls];
    
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self initProgressBar];
    
    [self performSelectorOnMainThread:@selector(initRecorder) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshScreen];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
}

- (void)refreshScreen{
    // previewlayer hide and show - Due to place pre-viewlayer for result on Video or Photo camera view.
    
    [GlobalVar getInstance].gIsPhotoPreview = YES;
    [_recorder.preViewLayer setHidden:NO];
    
    btnForVideo.enabled = NO;
    btnForVideo.hidden = YES;
}

- (void)initTopBar {
    
    //Close Button
    [btnForClose setImage:[UIImage imageNamed:@"record_close_normal.png"] forState:UIControlStateNormal];
    [btnForClose setImage:[UIImage imageNamed:@"record_close_disable.png"] forState:UIControlStateDisabled];
    [btnForClose setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateSelected];
    [btnForClose setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateHighlighted];
    
    //switch button
    
    [btnForFront setImage:[UIImage imageNamed:@"record_lensflip_normal.png"] forState:UIControlStateNormal];
    [btnForFront setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
    [btnForFront setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateSelected];
    [btnForFront setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateHighlighted];
    btnForFront.enabled = [_recorder isFrontCameraSupported];

    //Flash button
    
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_normal.png"] forState:UIControlStateNormal];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_disable.png"] forState:UIControlStateDisabled];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateHighlighted];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateSelected];
    btnForFlash.enabled = _recorder.isTorchSupported;

}

- (void)initPhotoControls {
    
    [self setupAlbumbutton];
    
    // photo camera button
    [btnForCamera setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot"] forState:UIControlStateNormal];
    
    // video button
    [btnForVideo setImage:[UIImage imageNamed:@"g_tabbar_ic_video_down"] forState:UIControlStateNormal];
    
    switch (captureOption) {
        case kTypeCaptureAll:
        {
            [btnForVideo setHidden:YES];

        }
            break;
        case kTypeCaptureVideo:
        {
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            
            isPhotoMode = !isPhotoMode;
            [self hideVideoControllView:isPhotoMode];
            
        }
            break;
        case kTypeCapturePhoto:
        {
            //[btnForVideo setHidden:YES];
            
        }
        default:
            break;
    }
}

- (void)setupAlbumbutton {
    
    [OMGlobal setCircleView:btnForAlbum borderColor:nil];
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        
        if (group) {
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            if (group.numberOfAssets > 0) {
                
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    if (result) {
                        
                        //Retrieve the image orientation from the ALAsset
                        
                        UIImageOrientation orientation = UIImageOrientationUp;
                        
                        NSNumber *orientationValue = [result valueForProperty:@"ALAssetPropertyOrientation"];
                        
                        if (orientationValue) {
                            
                            orientation = [orientationValue intValue];
                        }
                        
                        ALAssetRepresentation *repr = [result defaultRepresentation];
                        
                        //This is the most recent saved photo
                        
                        UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage] scale:1 orientation:orientation];
                        
                        
                        UIImageView *buttonImgView = [[UIImageView alloc] initWithFrame:btnForAlbum.bounds];
                        
                        [buttonImgView setContentMode:UIViewContentModeScaleToFill];
                        [buttonImgView setImage:img];
                        
                        
                        [btnForAlbum addSubview:buttonImgView];
                        
                        
                        // We only need the first (most recent) photo -- stop the enumeration
                        
                        *stop = YES;
                        
                    }
                    
                }];
                
            }
            
        }
        
    } failureBlock:^(NSError *error) {
        
        NSLog(@"Occured error when get most recent photo");
        
    }];
    

}

- (void)initVideoControls {
    
    
    if (isPhotoMode) {
        
        [imageViewForRedTimer setHidden:YES];
        [lblForTimer setHidden:YES];
    }
    else
    {
        [imageViewForRedTimer setHidden:NO];
        [lblForTimer setHidden:NO];
    }
    [OMGlobal setCircleView:imageViewForRedTimer borderColor:nil];

    
    //ok Button
    

    btnForOk.enabled = NO;
    
    [btnForOk setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_normal_bg.png"] forState:UIControlStateNormal];
    [btnForOk setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_highlighted_bg.png"] forState:UIControlStateHighlighted];
    [btnForOk setImage:[UIImage imageNamed:@"record_icon_hook_normal.png"] forState:UIControlStateNormal];
    [btnForOk addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
    [btnForOk setHidden:YES];
    
    btnForVideo.enabled = NO;
    btnForVideo.hidden = YES;
    
    [btnForVideo setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_normal_bg.png"] forState:UIControlStateNormal];
    [btnForVideo setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_highlighted_bg.png"] forState:UIControlStateHighlighted];
    [btnForVideo setImage:[UIImage imageNamed:@"record_icon_hook_normal.png"] forState:UIControlStateNormal];
    
    //Delete Button
    [btnForDelete setButtonStyle:DeleteButtonStyleDisable];
    [btnForDelete addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    // Record Button
    [btnForRecord setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot.png"] forState:UIControlStateNormal];
    [btnForRecord addTarget:self action:@selector(recordVideo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initRecorder {
    
    self.recorder = [[SBVideoRecorder alloc] init];
    _recorder.delegate = self;
    _recorder.preViewLayer.frame = viewForPreview.bounds;
    
    [viewForPreview.layer addSublayer:_recorder.preViewLayer];
    
    //focus rect view
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
    _focusRectView.alpha = 0;
    [viewForPreview addSubview:_focusRectView];
    
    
    btnForFront.enabled = [_recorder isFrontCameraSupported];
    btnForFlash.enabled = _recorder.isTorchSupported;
}


- (void)initProgressBar {
    
    self.progressBar = [ProgressBar getInstance];
    [SBCaptureToolKit setView:_progressBar toOriginY:(viewForToolbar.frame.size.height + viewForPreview.frame.size.height)];
    
    [self.view addSubview:_progressBar];
    [_progressBar startShining];
    
    [_progressBar setHidden:YES];
}

- (void)initDeleteButton {
    
    if (_isProcessingData) {
        return;
    }
}

- (void) updateLayoutWithAnimate:(BOOL)animate showProgress:(BOOL)_bool {
    
    if (animate) {
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.5f
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:1
                            options:(UIViewAnimationOptionCurveEaseOut)
                         animations:^{[self.view layoutIfNeeded];}
                         completion:^(BOOL finished) {
                             
                             [_progressBar setHidden:_bool];
                             [lblForTimer setHidden:_bool];
                             [imageViewForRedTimer setHidden:_bool];
                             
                             if (captureOption == kTypeCaptureAll) {
                                 if (_bool) {
                                     
                                     [btnForClose setImage:[UIImage imageNamed:@"record_close_normal"] forState:UIControlStateNormal];
                                 }
                                 else
                                 {
                                     [btnForClose setImage:[UIImage imageNamed:@"btn_back_profile"] forState:UIControlStateNormal];
                                     
                                 }

                             }
                             
                            
                         }];
        
    }
}

//  Hide/Show Video Control Views

- (void)hideVideoControllView:(BOOL)_bool {

    if (_bool) {
        constraintForVideoControl.constant = defaultValue;
        [self updateLayoutWithAnimate:YES showProgress:_bool];
    } else {
        constraintForVideoControl.constant = 0;
        [self updateLayoutWithAnimate:YES showProgress:_bool];
    }
}

// Take a Photo
- (void)capturePhoto {
    
    [_recorder captureStillImage];    
    [MBProgressHUD showMessag:@"Processing..." toView:self.view];
}

//Record Video
- (void)recordVideo:(UIButton *)sender {
    
    if (_recorder.isRecording) {
        [_recorder stopCurrentVideoRecording];
    } else {
        NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
        [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    if (_isProcessingData) {
//        return;
//    }
//    
//    if (btnForDelete.style == DeleteButtonStyleDelete) {
//        [btnForDelete setButtonStyle:DeleteButtonStyleNormal];
//        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
//        return;
//    }
//    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:btnForRecord.superview];
//    if (CGRectContainsPoint(btnForRecord.frame, touchPoint)) {
//        NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
//        [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
//    }
//    
    touchPoint = [touch locationInView:self.view];
    if (CGRectContainsPoint(_recorder.preViewLayer.frame, touchPoint)) {
        //[self showFocusRectAtPoint:touchPoint];
        [_recorder focusInPoint:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}
//When Tap Delete Button

- (void)pressDeleteButton {
    
    if (btnForDelete.style == DeleteButtonStyleNormal) {
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [btnForDelete setButtonStyle:DeleteButtonStyleDelete];
    } else if (btnForDelete.style == DeleteButtonStyleDelete) {
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        
        if ([_recorder getVideoCount] > 0) {
            [btnForDelete setButtonStyle:DeleteButtonStyleNormal];
        } else {
            [btnForDelete setButtonStyle:DeleteButtonStyleDisable];
        }
    }
}

//When Tap Ok Button

- (void)pressOKButton {
    
    if (_isProcessingData) {
        return;
    }
    
    self.isProcessingData = YES;
    
    [_recorder stopCurrentVideoRecording];
}

//Delete all video

- (void)dropTheVideo
{
    [_recorder deleteAllVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Delete the last Video

- (void)deleteLastVideo {
    
    if ([_recorder getVideoCount] > 0) {
        [_recorder deleteLastVideo];
    }
}

// Show PostViewController
- (void)showPostView:(UIImage *)_image {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIImage *image = [_image resizedImageToSize:CGSizeMake(POSTIMAGE_SIZE, POSTIMAGE_SIZE)];
    
    OMPostEventViewController *postEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostEventVC"];
    
    [postEventVC setImageForPost:image];
    [postEventVC setPostType:@"image"]; //Post Type  :  image , video, audio
    
    [postEventVC setUploadOption:uploadOption];
    [postEventVC setCaptureOption:captureOption];
    [postEventVC setCurObj:curObj];
    
    [self.navigationController pushViewController:postEventVC animated:YES];

}

- (void)showPreviewForVideo:(NSURL *)_url
{
    
    [_progressBar setLastProgressToWidth:0];
    
    OMPostEventViewController *postEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostEventVC"];
    [postEventVC setOutPutURL:_url];
    [postEventVC setPostType:@"video"]; //Post Type  :  image , video, audio
    [postEventVC setUploadOption:uploadOption];
    [postEventVC setCaptureOption:captureOption];
    [postEventVC setCurObj:curObj];
    
    [self.navigationController pushViewController:postEventVC animated:YES];
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
     [MBProgressHUD showMessag:@"Processing..." toView:self.view];

    [picker dismissViewControllerAnimated:YES completion:^{
        
        [_recorder.preViewLayer setHidden:YES];
        [imageViewForPreview setImage:image];
        btnForVideo.enabled = YES;
        btnForVideo.hidden = NO;
        [GlobalVar getInstance].gIsPhotoPreview = NO;
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    }];
}
#pragma mark - SBVideoRecorderDelegate

//Capture Image

- (void)captureManager:(SBVideoRecorder *)videoRecorder didFailWithError:(NSError *)error
{
    NSLog(@"Video Recoder Error!");
}

- (void)captureManagerStillImageCaptured:(SBVideoRecorder *)videoRecorder image:(UIImage *)image {

    self.isProcessingData = NO;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [_recorder stopCurrentVideoRecording];

    // Hide the previewlayer when get image or video for new Event/Post
    [_recorder.preViewLayer setHidden:YES];
    
    _focusRectView.hidden = NO;
    [imageViewForPreview setImage:image];
    btnForVideo.enabled = YES;
    btnForVideo.hidden = NO;

}

//Record Video

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self showPreviewForVideo:outputFileURL];
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
    } else {
        NSLog(@" %@", outputFileURL);
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(incrementTime:) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateRecordView) object:nil];
        
        second = 0;
        min = 0;
        hour = 0;
        //        imageViewForRedTimer.hidden = YES;
        lblForTimer.text = [NSString stringWithFormat:@"%02d:%02d", min,second];
        
        [MBProgressHUD showMessag:@"Processing..." toView:self.view];
        [_recorder mergeVideoFiles];
        
    }
    
//    [_progressBar startShining];
    
//    if (totalDur >= MAX_VIDEO_DUR) {
//        [self pressOKButton];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [self showPreviewForVideo:outputFileURL];
//    }

}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur {
    
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];
    
    btnForOk.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error {
    if (error) {
        NSLog(@": %@", error);
    } else {
        NSLog(@"file URL: %@", fileURL);
        NSLog(@": %f", totalDur);
    }
    
    if ([_recorder getVideoCount] > 0) {
        [btnForDelete setStyle:DeleteButtonStyleNormal];
    } else {
        [btnForDelete setStyle:DeleteButtonStyleDisable];
    }
    
    btnForOk.enabled = (totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL {
    
    [self.progressBar addProgressView];
    [_progressBar stopShining];
    
//    [btnForDelete setButtonStyle:DeleteButtonStyleNormal];
    
    lblForTimer.text = [NSString stringWithFormat:@"%02d:%02d",min,second];
    imageViewForRedTimer.hidden = NO;
    [self performSelector:@selector(incrementTime:) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(animateRecordView) withObject:nil afterDelay:0.5];
    btnForRecord.enabled = YES;

}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
#endif

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//Focus RectView
- (void)showFocusRectAtPoint:(CGPoint)point
{
    _focusRectView.alpha = 1.0f;
    _focusRectView.center = point;
    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [_focusRectView.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                _focusRectView.alpha = 0;
            }];
        });
    }];
}


- (IBAction)topButtonsAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case TAG_TOP_BUTTON:
        {
            //Close Camera View
            
            switch (captureOption) {
                case kTypeCaptureAll:
                {
                    if (isPhotoMode) {
                        
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        }];
                        
                    }
                    else
                    {
                        [_recorder deleteAllVideo];
                        isPhotoMode = !isPhotoMode;
                        [self hideVideoControllView:isPhotoMode];
                    }


                }
                    break;
                case kTypeCapturePhoto:
                {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    }];
                }
                    break;
                case kTypeCaptureVideo:
                {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    }];
                }
                    break;
                default:
                    break;
            }
           

        }
            break;
        case TAG_TOP_BUTTON + 1:
        {
            //
            
            button.selected = !button.selected;
            [_recorder openTorch:button.selected];
        }
            break;
        case TAG_TOP_BUTTON + 2:
        {
            button.selected = !button.selected;
            
            if (button.selected) {
                
                if (btnForFlash.selected) {
                    
                    [_recorder openTorch:NO];
                    btnForFlash.selected = NO;
                    btnForFlash.enabled = NO;
                }
                else
                {
                    btnForFlash.enabled = NO;
                }
            }
            else
            {
                btnForFlash.enabled = [_recorder isFrontCameraSupported];
            }
            [_recorder switchCamera];
        }
            break;
        default:
            break;
    }
}

- (IBAction)bottomButtonsAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case TAG_PHOTO_BUTTON:
        {
            
            //Capture Action : if camera button -> Photo , else video button //
            if (isPhotoMode) {
                
                if([GlobalVar getInstance].gIsPhotoPreview) {
                    [self capturePhoto];
                }
                else
                {
                    [_recorder.preViewLayer setHidden:NO];
                    btnForVideo.enabled = NO;
                    btnForVideo.hidden = YES;
                    
                }
                [GlobalVar getInstance].gIsPhotoPreview = ![GlobalVar getInstance].gIsPhotoPreview;
                
            }
        }
            break;
        case TAG_PHOTO_BUTTON + 1:
        {
            //Show Album View Controller

            imagePicker.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case TAG_PHOTO_BUTTON + 2:
        {
            //Photo mode -> Switch Video or Photo
            //isPhotoMode = !isPhotoMode;
            //[self hideVideoControllView:isPhotoMode];
            [self nextButton];
        }
            break;
        default:
            break;
    }
}

// Custom Button Actions

- (void)nextButton {
    
    [self showPostView:[OMGlobal croppedImage:imageViewForPreview.image]];
}

#pragma mark - helper functions
// Timer Methods

-(void)incrementTime:(id)obj {
    
    second ++;
    
    if (second== 11) {
        second = 0;
        
        [_recorder stopCurrentVideoRecording];
        return;
        
    }
    lblForTimer.text = [NSString stringWithFormat:@"%02d:%02d", min,second];
    [self performSelector:@selector(incrementTime:) withObject:nil afterDelay:1.0];
    
}

-(void)animateRecordView {
    
    imageViewForRedTimer.hidden = !imageViewForRedTimer.hidden ;
    [self performSelector:@selector(animateRecordView) withObject:nil afterDelay:0.5];
}



@end
