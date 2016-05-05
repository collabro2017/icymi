//
//  OMNewEventPostViewController.m
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMNewEventPostViewController.h"
#import "OMTagListViewController.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface OMNewEventPostViewController ()<OMTagListViewControllerDelegate>
{
    NSMutableArray *arrForTagFriends;
    NSMutableArray *arrForTagFriendAuthorities;
}

@end

@implementation OMNewEventPostViewController
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }
}
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
    arrForTagFriends = [NSMutableArray array];
    arrForTagFriendAuthorities = [NSMutableArray array];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [imageViewForThumb addGestureRecognizer:gestureRecognizer];
    
    txtForEventName.delegate = self;
    txtForDescription.delegate = self;

    
    [txtForDescription addSubview:lblForPlaceholder];
    [lblForPlaceholder setFrame:CGRectMake(3, 3, lblForPlaceholder.frame.size.width, lblForPlaceholder.frame.size.height)];
    // Do any additional setup after loading the view.
    
    [self keyboardShowHideAnimationSetting];
}

- (void)keyboardShowHideAnimationSetting
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didShowKeyboard:(NSNotification *)_notification
{
    
}

- (void)willHideKeyboard:(NSNotification *)_notification
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tapPhoto
{
    UIActionSheet *photoSelectSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Picture" otherButtonTitles:@"Choose from Album", nil];
    [photoSelectSheet showInView:self.view];
}

#pragma mark 

- (void)selectedCells:(OMTagListViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict
{
    [fsCategoryVC.navigationController dismissViewControllerAnimated:YES completion:^{
        
        arrForTagFriends = [_dict copy];
    }];
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    switch (buttonIndex) {
        case 3:
        {
            
        }
            break;
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark UIImagePickerController  Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [imageViewForThumb setImage:image];
        [lblForTap setHidden:YES];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITextField delegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
////    [textField resignFirstResponder];
//    
//    [txtForDescription becomeFirstResponder];
//    return YES;
//}
//
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

- (IBAction)tagFriendAction:(id)sender {
    
    OMTagListViewController *tagListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TagListVC"];
    tagListVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tagListVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
    
}

- (IBAction)doneAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFObject *post = [PFObject objectWithClassName:@"Event"];
    PFUser *currentUser = [PFUser currentUser];
    
    post[@"user"] = currentUser;
    post[@"eventname"] = txtForEventName.text;
    post[@"description"] = txtForDescription.text;
    post[@"openStatus"] = [NSNumber numberWithInteger:1];
    post[@"TagFriends"] = arrForTagFriends;
    post[@"TagFriendAuthorities"] = arrForTagFriendAuthorities;
//    post[@"PostType"] = @"event";
    
    //image upload
    PFFile *postFile = [PFFile fileWithName:@"image.jpg" data:UIImageJPEGRepresentation(imageViewForThumb.image, 0.7)];
    post[@"thumbImage"] = postFile;
    
    //Request a background execution task to allow us to finish uploading the photo even if the app is background
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    BOOL enable_location = NO;
    
    if (enable_location) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                post[@"country"] = geoPoint;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if (succeeded) {
                        NSLog(@"Success ---- Post");
                        
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

- (IBAction)backAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
