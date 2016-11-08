//
//  OMCameraViewController.m
//  Collabro
//
//  Created by Ellisa on 15/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMCameraPhotoViewController.h"

#import "UIImage+Resize.h"
#import "OMPostEventViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#define TAG_ALERTVIEW_CLOSE_CONTROLLER 10086

#define TAG_TOP_BUTTON          100
#define TAG_PHOTO_BUTTON        200
#define TAG_VIDEO_BUTTON        300


@interface OMCameraPhotoViewController ()

@property (nonatomic, weak) id<UIImagePickerControllerDelegate> delegate;
@property (strong, nonatomic) UIImageView       *focusRectView;

@end

@implementation OMCameraPhotoViewController
@synthesize uploadOption,captureOption,curObj;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self initViewItems];
    
    [self performSelectorOnMainThread:@selector(initRecorder) withObject:nil waitUntilDone:NO];
    
    imageViewForPreview.frame = CGRectMake(0, 0, IS_IPAD?768: 320, IS_IPAD?768: 320);
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

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
    
}
#pragma mark -rotate(only when this controller is presented, the code below effect)-
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshScreen];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

// for photo editing -

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

- (UIImage*)cropImageFromScroll:(UIScrollView *)scrollview
{
    
    CGSize pageSize = scrollview.frame.size;
    UIGraphicsBeginImageContext(pageSize);
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
    
    btnForVideo.enabled = NO;
    btnForVideo.hidden = YES;
   
}

- (void)initViewItems{
    
    
//-----------------------------//
    // Top bar view
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

    // TODO
    btnForFront.enabled = YES;

    //Flash button
    
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_normal.png"] forState:UIControlStateNormal];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_disable.png"] forState:UIControlStateDisabled];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateHighlighted];
    [btnForFlash setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateSelected];
    //TODO
    btnForFlash.enabled = YES;
    
//-----------------------------//
    // Photo controls
    [self setupAlbumbutton];
    
    // photo camera button
    [btnForCamera setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot"] forState:UIControlStateNormal];
    
    // video button
    [btnForVideo setImage:[UIImage imageNamed:@"g_tabbar_ic_video_down"] forState:UIControlStateNormal];
    
    [btnForVideo setHidden:YES];
    [btnForVideo setEnabled:NO];
 
    
    [btnForVideo setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_normal_bg.png"] forState:UIControlStateNormal];
    [btnForVideo setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_highlighted_bg.png"] forState:UIControlStateHighlighted];
    [btnForVideo setImage:[UIImage imageNamed:@"record_icon_hook_normal.png"] forState:UIControlStateNormal];

}

- (void)initRecorder {
    /*
     self.recorder = [[SBVideoRecorder alloc] init];
     _recorder.delegate = self;
     _recorder.preViewLayer.frame = viewForPreview.bounds;
    */
    
    CGRect frame = viewForPreview.frame;
    viewForCamera.frame = frame;
    [viewForPreview addSubview:viewForCamera];
    [viewForCamera setHidden:NO];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        return ;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imagePicker.delegate = self;
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    
    imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    imagePicker.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
    imagePicker.showsCameraControls = NO;
    
    //viewForCamera.frame = imagePickerController.cameraOverlayView.frame;
    imagePicker.cameraOverlayView = viewForCamera;
    imagePickerController = imagePicker;
    //[self presentViewController:imagePickerController animated:NO completion:nil];
    
    
    //focus rect view
//    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
//    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
//    _focusRectView.alpha = 0;
//    _focusRectView.center = viewForPreview.center;
//    [viewForPreview addSubview:_focusRectView];
//    
//    [_focusRectView setHidden:NO];
//    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFocuseTap:)];
//    [viewForPreview addGestureRecognizer:singleTap];
    
    //TODO
    btnForFront.enabled = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    btnForFlash.enabled = [UIImagePickerController isFlashAvailableForCameraDevice:imagePickerController.cameraDevice];
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



- (void)setFocuseTap:(UITapGestureRecognizer*)recognizer
{
    if(captureOption == kTypeCaptureVideo) return;
    
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if (CGRectContainsPoint(imageViewForPreview.frame, location)) {

        [self showFocusRectAtPoint:location];
        
       // TODO Focus processing
        
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


// Take a Photo
- (void)capturePhoto {

    // Take a photo processing
    UIGraphicsBeginImageContext(viewForPreview.frame.size);
    [viewForPreview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [infoDictionary setValue:temp forKey:UIImagePickerControllerOriginalImage];
    
    [_delegate imagePickerController:imagePickerController didFinishPickingMediaWithInfo:[NSDictionary dictionaryWithDictionary:infoDictionary]];
    [imagePickerController dismissViewControllerAnimated:NO completion:nil];
    
    [MBProgressHUD showMessag:@"Processing..." toView:self.view];
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

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [MBProgressHUD showMessag:@"Processing..." toView:self.view];
    [picker dismissViewControllerAnimated:YES completion:^{
        
        //TODO - camera view have to hide
        [viewForCamera setHidden:YES];
        
        //[imageViewForPreview setImage:image];
        // for photo editing
        [self sendImageOnEditViewWithScroll:image];
        infoDictionary = [NSMutableDictionary dictionaryWithDictionary:info];
        
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
    
    //[delegate imagePickerControllerDidCancel:picker];
}


- (void)captureManagerStillImageCaptured:(UIImage *)image {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //TODO - Camera view have to hide
    [viewForCamera setHidden:YES];
     _focusRectView.hidden = NO;
    //[imageViewForPreview setImage:image];
    // for phote editing
    [self sendImageOnEditViewWithScroll:image];
    btnForVideo.enabled = YES;
    btnForVideo.hidden = NO;
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
            [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
             break;
            
        case TAG_TOP_BUTTON + 1:
        {
            
           // button.selected = !button.selected;
            
            if (imagePickerController.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff)
            {
                if ([UIImagePickerController isFlashAvailableForCameraDevice:imagePickerController.cameraDevice])
                {
                    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
                    btnForFlash.selected = YES;
                    btnForFlash.enabled = YES;
                }
                
            }
            else
            {
                imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                btnForFlash.selected = NO;
                btnForFlash.enabled = NO;
            }
            
            
        }
            break;
        case TAG_TOP_BUTTON + 2:
        {
            
            /*
            button.selected = !button.selected;
            if (button.selected) {
                
                if (btnForFlash.selected) {
                    
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
                btnForFlash.enabled = YES;
            }
            */
            
            if (imagePickerController.cameraDevice  == UIImagePickerControllerCameraDeviceFront) {
                if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                }
            } else {
                if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                    if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront]) {
                        btnForFlash.selected = NO;
                        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                    }
                    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
            }
 
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
            if([GlobalVar getInstance].gIsPhotoPreview) {
                [self capturePhoto];
            }
            else
            {
               //TODO - Camera view show
                [viewForCamera setHidden:NO];
                
                btnForVideo.enabled = NO;
                btnForVideo.hidden = YES;
                    
            }
            [GlobalVar getInstance].gIsPhotoPreview = ![GlobalVar getInstance].gIsPhotoPreview;
                
        }
            break;
            
        case TAG_PHOTO_BUTTON + 1:
        {
            //Show Album View Controller
            if(imagePickerController)
            {
                
            }
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
        }
            break;
        case TAG_PHOTO_BUTTON + 2:
        {
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




@end
