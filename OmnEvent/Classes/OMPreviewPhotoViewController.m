//
//  OMPreviewPhotoViewController.m
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMPreviewPhotoViewController.h"
@interface OMPreviewPhotoViewController ()

@end

@implementation OMPreviewPhotoViewController
@synthesize imageForPreview;
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
    
    txtForDes.delegate = self;
    [self.navigationController setNavigationBarHidden:YES];
    [OMGlobal setCircleView:imageViewForProfile borderColor:[UIColor purpleColor]];
    PFUser *currentUser = [PFUser currentUser];
    PFFile *profileImgFile = (PFFile *)currentUser[@"ProfileImage"];
    
    if (profileImgFile) {
        [OMGlobal setImageURLWithAsync:profileImgFile.url positionView:self.view displayImgView:imageViewForProfile];
    }

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [imageViewForPreview setImage:imageForPreview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark  UITextView  Delegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    if (![textView hasText])
    {
        [textView addSubview:lblForPlaceholder];
        [UIView animateWithDuration:0.15f animations:^{
            lblForPlaceholder.alpha = 1.0f;
        }];
    }
    else if ([[textView subviews] containsObject:lblForPlaceholder])
    {
//        [lblForPlaceholder removeFromSuperview];
        [UIView animateWithDuration:0.15f animations:^{
            lblForPlaceholder.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [lblForPlaceholder removeFromSuperview];
        }];
    }
//    NSUInteger max_num = MAXIUM_NUM;
//    countLbl.text = [NSString stringWithFormat:@"%d",max_num - textView.text.length];
//    if ([countLbl.text isEqualToString:@"0"])
//    {
//        countLbl.textColor = [UIColor redColor];
//    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    return [self isAcceptableTextLength:textView.text.length + text.length - range.length];
//}
//
//- (BOOL)isAcceptableTextLength:(NSUInteger)length
//{
//    return length <= MAXIUM_NUM;
//}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (![textView hasText])
    {
        [textView addSubview:lblForPlaceholder];
//        [textView addSubview:yepLbl];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)postAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    PFUser *currentUser = [PFUser currentUser];
    
    post[@"user"] = currentUser;
    post[@"description"] = txtForDes.text;
    post[@"PostType"] = @"photo";
    
    //image upload
    PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(self.imageForPreview, 0.7)];
    post[@"image"] = postFile;
    
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
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (succeeded) {
                NSLog(@"Success ---- Post");
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadPhotoData object:nil];
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

- (IBAction)tagAction:(id)sender {
}
@end
