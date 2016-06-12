//
//  OMMyProfileViewController.h
//  Collabro
//
//  Created by Ellisa on 26/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

extern BOOL refresh_require;

@interface OMMyProfileViewController : UIViewController
{
    
    
    IBOutlet UITableView *tblForProfile;
    
    
    IBOutlet UIButton *btnForSetting;
    
    IBOutlet UIButton *btnForBack;
    
    IBOutlet UIView *viewForPopup;
    
    IBOutlet UIView *viewForLayer;
    
    __weak IBOutlet UIView *viewForCreateFolder;
    
    UIImagePickerController *imagePicker;
    
    BOOL isShowSetting;
    
    int nCurrentFolderIdx;
    NSInteger currentSegIndex;
}

@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

@property (nonatomic,readwrite) NSInteger is_type;
@property (nonatomic, strong) PFUser *targetUser;
@property (nonatomic, assign) BOOL isPushed;
@property (nonatomic, assign) BOOL isFolderCreating;

- (IBAction)settingAction:(id)sender;

- (IBAction)backAction:(id)sender;

- (IBAction)logoutAction:(id)sender;

- (IBAction)profileAction:(id)sender;

- (IBAction)createFolderAction:(id)sender;
- (IBAction)cancelCreateAction:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *m_lblFolderName;
@property (weak, nonatomic) IBOutlet UIImageView *m_FolderImgView;
- (IBAction)changeFolderImage:(id)sender;

@end
