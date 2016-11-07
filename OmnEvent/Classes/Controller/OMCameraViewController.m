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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintLeft;

// Video Control View

@end

@implementation OMCameraViewController
@synthesize uploadOption,captureOption,curObj;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"Here Photo!");
    isPhotoMode = YES;
    
    defaultValue = constraintForVideoControl.constant;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self performSelectorOnMainThread:@selector(initRecorder) withObject:nil waitUntilDone:NO];
   
    [self initTopBar];
    [self initPhotoControls];
    [self initVideoControls];
    [self initFocuseView];
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self initProgressBar];
    
//    CGRect frame = imageViewForPreview.frame;
//    frame = CGRectMake(0, 0, IS_IPAD?768: 320, IS_IPAD?768: 320);
//    imageViewForPreview.frame = CGRectMake(0, 0, IS_IPAD?768: 320, IS_IPAD?768: 320);
    // for photo editing
    scrollViewForPreview.delegate = self;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [scrollViewForPreview addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [scrollViewForPreview addGestureRecognizer:twoFingerTapRecognizer];
    
   // [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(drawFocusView) userInfo:nil repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!_cropFlag) {
        [self refreshScreen];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)drawFocusView
{
    if([_recorder isAdjustingFocus])
        [self showFocusRectAtPoint:viewForCamera.center];
    else
    {
        [_recorder focusInPoint:viewForCamera.center];
        
    }
}
// for photo editing -------------

- (void)sendImageOnEditViewWithScroll:(UIImage*) image
{
    imageViewForPreview.contentMode = UIViewContentModeScaleAspectFill;
    imageViewForPreview.image = image;
    
    CGRect frame = imageViewForPreview.frame;
    frame = CGRectMake(0, 0, IS_IPAD?768: 320,IS_IPAD?768: 320);
    imageViewForPreview.frame = frame;

    scrollViewForPreview.zoomScale = 1.0;
    scrollViewForPreview.minimumZoomScale = 1.0;
    scrollViewForPreview.maximumZoomScale = 10.0f;
    scrollViewForPreview.contentSize = CGSizeMake(IS_IPAD?768: 320,IS_IPAD?768: 320);
    
    [self centerScrollViewContents];
    
}

- (void) initScrollFrame
{
    CGRect scrollViewFrame = scrollViewForPreview.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / scrollViewForPreview.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / scrollViewForPreview.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    scrollViewForPreview.minimumZoomScale = minScale;
    scrollViewForPreview.maximumZoomScale = 1.0f;
    scrollViewForPreview.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollViewForPreview.bounds.size;
    CGRect contentsFrame = imageViewForPreview.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageViewForPreview.frame = contentsFrame;
}

- (UIImage*)cropImageFromScroll:(UIScrollView *)scrollview {
    CGSize pageSize = scrollview.frame.size;
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    int offsetX = -1*scrollview.contentOffset.x;
    int offsetY = -1*scrollview.contentOffset.y;
    CGContextTranslateCTM(resizedContext, offsetX, offsetY);
    [scrollViewForPreview.layer renderInContext:resizedContext];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    return viewImage;
}

#pragma mark - UITapGuesture Selector

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:imageViewForPreview];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = scrollViewForPreview.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, scrollViewForPreview.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = scrollViewForPreview.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [scrollViewForPreview zoomToRect:rectToZoomTo animated:YES];
    
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = scrollViewForPreview.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, scrollViewForPreview.minimumZoomScale);
    [scrollViewForPreview setZoomScale:newZoomScale animated:YES];
}

#pragma mark - ScrollView Delegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return imageViewForPreview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}
//-------------------------------

- (void)refreshScreen{
    // previewlayer hide and show - Due to place pre-viewlayer for result on Video or Photo camera view.
    
    [GlobalVar getInstance].gIsPhotoPreview = YES;
    [viewForCamera setHidden:NO];
    
    btnForVideo.enabled = NO;
    btnForVideo.hidden = YES;
    btnForOk.enabled = NO;
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
                        
                        [buttonImgView setContentMode:UIViewContentModeScaleAspectFill];
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
    self.recorder = [[SBVideoRecorder alloc] initWithView:viewForCamera];
    self.recorder.isPhoto = captureOption == kTypeCaptureVideo? NO:YES;
    self.recorder.delegate = self;
    [self.recorder focusInPoint:viewForPreview.center];
    
    btnForFront.enabled = [_recorder isFrontCameraSupported];
    btnForFlash.enabled = _recorder.isTorchSupported;
}

- (void)initFocuseView {
    
    //focus rect view
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
    _focusRectView.alpha = 0;
    _focusRectView.center = viewForPreview.center;
    [viewForPreview addSubview:_focusRectView];
    
    [_focusRectView setHidden:captureOption == kTypeCaptureVideo];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFocuseTap:)];
    [viewForPreview addGestureRecognizer:singleTap];

}

- (void)setFocuseTap:(UITapGestureRecognizer*)recognizer
{
    if(captureOption == kTypeCaptureVideo) return;
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if (CGRectContainsPoint(_recorder.preViewLayer.frame, location)) {
        [self showFocusRectAtPoint:location];
        [_recorder focusInPoint:location];
    }
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
        [_progressBar startShining];
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
   // UITouch *touch = [touches anyObject];
    
   // CGPoint touchPoint = [touch locationInView:viewForPreview];
//    if (CGRectContainsPoint(btnForRecord.frame, touchPoint)) {
//        NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
//        [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
//    }
//    
   // touchPoint = [touch locationInView:self.view];
   // if (CGRectContainsPoint(_recorder.preViewLayer.frame, touchPoint)) {
   //     [self showFocusRectAtPoint:touchPoint];
   //     [_recorder focusInPoint:touchPoint];
   // }
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
    
    [_progressBar stopShining];
    [_progressBar setLastProgressToWidth:0];

    if (_recorder.isRecording) {
        [_recorder stopCurrentVideoRecording];
    }
    
    [MBProgressHUD showMessag:@"Processing..." toView:self.view];
    [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(mergeProcessWithDelay) userInfo: nil repeats: NO];
    
}
// Added some delay to protect the crash when processing just with recorded Video
- (void) mergeProcessWithDelay
{
    [_recorder mergeVideoFiles];
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
    [postEventVC setPostOrder:_postOrder];
    
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
    [postEventVC setPostOrder:_postOrder];
    
    [self.navigationController pushViewController:postEventVC animated:YES];
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    float temp;
    if (image.size.height>image.size.width) {
        temp = image.size.height;
    }
    else
        temp = image.size.width;
    
    
    [MBProgressHUD showMessag:@"Processing..." toView:self.view];

    [picker dismissViewControllerAnimated:YES completion:^{
        
        [viewForCamera setHidden:YES];
        
        //[imageViewForPreview setImage:image];
        // for photo editing
        [self sendImageOnEditViewWithScroll:image];
        
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
    NSLog(@"Video Recording Error!");
}

- (void)captureManagerStillImageCaptured:(SBVideoRecorder *)videoRecorder image:(UIImage *)image {

    
    self.isProcessingData = NO;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    [_recorder stopCurrentVideoRecording];

    // Hide the previewlayer when get image or video for new Event/Post
    //[_recorder.preViewLayer setHidden:YES];
    [viewForCamera setHidden:YES];
    
    _focusRectView.hidden = NO;
    
    //[imageViewForPreview setImage:image];
    // for phote editing
    [self sendImageOnEditViewWithScroll:image];
    
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
    
    if (!error)
    {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(incrementTime:) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateRecordView) object:nil];
        
        second = 0;
        min = 0;
        hour = 0;
        
        lblForTimer.text = [NSString stringWithFormat:@"%02d:%02d", min,second];
        
        [_progressBar stopShining];
        [_progressBar setLastProgressToWidth:0];

        if(videoDuration > MIN_VIDEO_DUR && videoDuration < MAX_VIDEO_DUR)
        {
            if(_recorder.isRecording)
                [_recorder stopCurrentVideoRecording];
        }
        if(videoDuration >= MAX_VIDEO_DUR)
        {
            [self pressOKButton];
        }
    }
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur {
    
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_DUR * _progressBar.frame.size.width];
    btnForOk.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error {
    
    if ([_recorder getVideoCount] > 0) {
        [btnForDelete setStyle:DeleteButtonStyleNormal];
    } else {
        [btnForDelete setStyle:DeleteButtonStyleDisable];
    }
    
    btnForOk.enabled = (totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL {
    
    [self.progressBar addProgressView];
    
//  [btnForDelete setButtonStyle:DeleteButtonStyleNormal];
    
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
    //if(_focusRectView.alpha != 0.0f) return;
        
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
                    if(_recorder.isRecording) [_recorder stopCurrentVideoRecording];
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
            if(![_recorder isRecording])[_recorder switchCamera];
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
            NSLog(@"Here Capture!!!");
            //Capture Action : if camera button -> Photo , else video button //
            if (isPhotoMode) {
                
                if([GlobalVar getInstance].gIsPhotoPreview) {
                    [self capturePhoto];
                }
                else
                {
                    
                    [viewForCamera setHidden:NO];
                    [_recorder initCameraView:viewForCamera];
                    
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
    
    //[self showPostView:[OMGlobal croppedImage:imageViewForPreview.image]];
    [self showPostView:[self cropImageFromScroll:scrollViewForPreview]];
}

#pragma mark - helper functions
// Timer Methods

-(void)incrementTime:(id)obj {
    
    second ++;
    
    if(second > MIN_VIDEO_DUR)
    {
        btnForOk.enabled = YES;
    }
    
    if (second >= MAX_VIDEO_DUR) {
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

//*******************************************************************
#pragma mark - PECropViewControllerDelegate methods
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    imageViewForPreview.image = croppedImage;
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Crop Action methods
- (IBAction)actionCropPhoto:(id)sender {
    _cropFlag = YES;
    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = imageViewForPreview.image;
    
    UIImage *image = imageViewForPreview.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    */
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - DrawTextViewControllerDelegate methods
- (void)dtViewController:(OMDrawTextViewController *)controller didFinishDTImage:(UIImage *)dtImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    CGRect frame = imageViewForPreview.frame;
    frame = CGRectMake(0, 0, IS_IPAD?768: 320,IS_IPAD?768: 320);
    imageViewForPreview.frame = frame;
    imageViewForPreview.image = dtImage;
    
}

- (void)dtViewControllerDidCancel:(OMDrawTextViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)actionDrawText:(id)sender {
    _cropFlag = YES;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    OMDrawTextViewController *dtConroller = [mainStoryboard instantiateViewControllerWithIdentifier:@"dtViewController"];
    dtConroller.delegate = self;
    UIImage *image = imageViewForPreview.image;
    dtConroller.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dtConroller];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];

}


//*******************************************************************/

@end
