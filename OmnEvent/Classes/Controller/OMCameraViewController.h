//
//  OMCameraViewController.h
//  Collabro
//
//  Created by Ellisa on 15/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SBCaptureDefine.h"
#import "SBVideoRecorder.h"

@class DeleteButton;

@interface OMCameraViewController : UIViewController<SBVideoRecorderDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate> {
    
    //Tool Bar
    
    IBOutlet UIView *viewForToolbar;
    
    IBOutlet UIButton *btnForClose;
    IBOutlet UIButton *btnForFlash;
    IBOutlet UIButton *btnForFront;
    
    //Camera View
    
    IBOutlet UIView *viewForCamera;
    IBOutlet UIView *viewForPreview;
    IBOutlet UIImageView *imageViewForPreview;
    IBOutlet UILabel *lblForTimer;
    
    // for photo editing
    IBOutlet UIScrollView *scrollViewForPreview;
    
    //Bottom Bar
    
    IBOutlet UIImageView *imageViewForRedTimer;
    IBOutlet UIView *viewForBottomBar;
    
    IBOutlet UIButton *btnForCamera;
    
    IBOutlet UIButton *btnForAlbum;
    
    IBOutlet UIButton *btnForVideo;
    
    
    //Video Control
    
    
    IBOutlet UIView *viewForVideoControls;
    IBOutlet UIButton *btnForRecord;
    IBOutlet DeleteButton *btnForDelete;
    IBOutlet UIButton *btnForOk;
    IBOutlet NSLayoutConstraint *constraintForVideoControl;
    //
    
    UIImagePickerController *imagePicker;
    
    MBProgressHUD *hud;
}

@property (nonatomic, assign) BOOL addVideoMode;
@property (nonatomic, strong) NSString *postMode;

@property (nonatomic) kTypeUpload      uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) PFObject          *curObj;
@property (nonatomic, assign) int       postOrder;

- (IBAction)topButtonsAction:(id)sender;
- (IBAction)bottomButtonsAction:(id)sender;

@end
