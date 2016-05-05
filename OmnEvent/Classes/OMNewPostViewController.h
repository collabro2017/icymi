//
//  OMNewPostViewController.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMNewPostViewController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    
    IBOutlet UIImageView *imageViewForTxtBack;
  
    IBOutlet UILabel *lblForPlaceholder;
    IBOutlet UITextView *txtForStatus;
}

@property (assign,nonatomic) NSInteger postType;
@property (nonatomic,strong) UIImage *imageForPost;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewForPost;
@property (nonatomic, strong) PFObject *object;

@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

- (IBAction)tagFriendsAction:(id)sender;

- (IBAction)submitAction:(id)sender;

- (IBAction)backHomeAction:(id)sender;
@end
