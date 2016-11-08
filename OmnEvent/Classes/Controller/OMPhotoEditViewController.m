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
- (IBAction)cropAction:(id)sender {
    _editFlag = YES;
    
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

//*******************************************************************/
@end
