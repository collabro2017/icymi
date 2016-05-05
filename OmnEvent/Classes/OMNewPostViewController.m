//
//  OMNewPostViewController.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMNewPostViewController.h"

@interface OMNewPostViewController ()

@end

@implementation OMNewPostViewController
@synthesize object,postType,imageViewForPost,imageForPost;
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
    [self.navigationController setNavigationBarHidden:YES];
    
    txtForStatus.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (postType) {
        
        [txtForStatus setHidden:YES];
        [lblForPlaceholder setHidden:YES];
        [imageViewForPost setHidden:NO];
        [imageViewForPost setImage:imageForPost];
    }
    else
    {
        [txtForStatus setHidden:NO];
        [lblForPlaceholder setHidden:NO];
        
        [txtForStatus addSubview:lblForPlaceholder];
        [lblForPlaceholder setFrame:CGRectMake(3, 3, lblForPlaceholder.frame.size.width, lblForPlaceholder.frame.size.height)];
        imageViewForTxtBack.layer.borderColor = [[UIColor blackColor]CGColor];
        imageViewForTxtBack.layer.borderWidth = 1.0f;
        imageViewForTxtBack.layer.cornerRadius = 5.0f;
        [imageViewForPost setHidden:YES];
    }
    
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
        [lblForPlaceholder removeFromSuperview];
        [UIView animateWithDuration:0.15f animations:^{
            lblForPlaceholder.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [lblForPlaceholder removeFromSuperview];
        }];
    }
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

- (IBAction)tagFriendsAction:(id)sender {
}

- (IBAction)submitAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    PFUser *currentUser = [PFUser currentUser];
    
    post[@"user"] = currentUser;
    post[@"targetEvent"] = object;

    switch (postType) {
        case 1:
        {
            post[@"postType"] = @"photo";
            
            //image upload
            PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(imageForPost, 0.7)];
            post[@"postFile"] = postFile;
            
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
        case 0:
        {
            post[@"postType"] = @"text";
            
            post[@"description"] = txtForStatus.text;
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    
                }
            }];
        }
            break;
        default:
            break;
    }
    

    
}

- (IBAction)backHomeAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
