//
//  OMPhotoEditViewController.m
//  Collabro
//
//  Created by Ellisa on 29/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMPhotoEditViewController.h"
#import "OMPostEventViewController.H"

@interface OMPhotoEditViewController ()

@end

@implementation OMPhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_editFlag) {
        [imageViewForPreview setImage:_preImage];
    }
    
}
/*
-(void)viewDidLayoutSubviews{
    
    float rate = _preImage.size.width/_preImage.size.height;
    float height = IS_IPAD?768: 320;
    CGSize scrollFrame = CGSizeMake(height * rate, height);
    scrollView.contentSize = scrollFrame;
    scrollView.scrollEnabled = YES;
    
    imageViewForPreview.frame = CGRectMake(0, 0, height * rate, height);
    imageViewForPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    imageViewForPreview.contentMode = UIViewContentModeScaleAspectFit;

}
*/
- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)nextAction:(id)sender {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    OMPostEventViewController *postEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostEventVC"];
    
    [postEventVC setImageForPost:imageViewForPreview.image];
    [postEventVC setPostType:@"image"]; //Post Type  :  image , video, audio
    
    [postEventVC setUploadOption:_uploadOption];
    [postEventVC setCaptureOption:_captureOption];
    [postEventVC setCurObj:_curObj];
    [postEventVC setPostOrder:_postOrder];
    
    [self.navigationController pushViewController:postEventVC animated:YES];
    
}
//*******************************************************************

#pragma mark - Crop Action methods
- (IBAction)cropAction:(id)sender {
    _editFlag = YES;
    
    UIImage *image = imageViewForPreview.image;
    PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:image];
    photoTweaksViewController.delegate = self;
    photoTweaksViewController.autoSaveToLibray = NO;
    photoTweaksViewController.maxRotationAngle = M_PI_4;
    
    [self.navigationController pushViewController:photoTweaksViewController animated:YES];
}

#pragma mark - PhotoTweaksViewControllerDelegate methods
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [controller.navigationController popViewControllerAnimated:YES];
    imageViewForPreview.image = croppedImage;
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
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


- (IBAction)penAndTextAction:(id)sender {
    _editFlag = YES;
    
    OMDrawTextViewController *dtConroller = [self.storyboard instantiateViewControllerWithIdentifier:@"DrawTextVC"];
    dtConroller.delegate = self;
    UIImage *image = imageViewForPreview.image;
    dtConroller.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dtConroller];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)addTextAction:(id)sender {
    _editFlag = YES;
    
    OMAddTextViewController *dtConroller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTextVC"];
    dtConroller.delegate = self;
    UIImage *image = imageViewForPreview.image;
    dtConroller.image = image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dtConroller];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - AddTextViewControllerDelegate methods
- (void)atViewController:(OMAddTextViewController *)controller didFinishDTImage:(UIImage *)dtImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    CGRect frame = imageViewForPreview.frame;
    frame = CGRectMake(0, 0, IS_IPAD?768: 320,IS_IPAD?768: 320);
    imageViewForPreview.frame = frame;
    imageViewForPreview.image = dtImage;
    
}

- (void)atViewControllerDidCancel:(OMAddTextViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
//*******************************************************************/
@end
