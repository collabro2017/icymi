//
//  OMSignUpViewController.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTextField.h"

@interface OMSignUpViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    
    UIImagePickerController *picker;
    
    IBOutlet UITextField *txtForUsername;
    
    IBOutlet UITextField *txtForEmail;
    
    IBOutlet UITextField *txtForPassword;
    
    IBOutlet UITextField *txtForConfirmPassword;
    
    IBOutlet UIImageView *imgViewForAvatar;
    
    UIImage *avatarImg;
    
    
    
    IBOutlet UITextField *txtForLastname;
    
    IBOutlet UITextField *txtForFirstname;
    
    
    //
    
    
    IBOutlet NSLayoutConstraint *constraintForTopspace;
    
    IBOutlet UIView *viewForHead;
    
    IBOutlet UIView *viewForBottom;
}
@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

- (IBAction)registerAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
