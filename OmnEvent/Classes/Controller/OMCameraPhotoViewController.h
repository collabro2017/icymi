//
//  OMCameraViewController.h
//  Collabro
//
//  Created by Ellisa on 15/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface OMCameraPhotoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate> {

    
    
    //Tool Bar
    
    IBOutlet UIView   *viewForToolbar;
    IBOutlet UIButton *btnForClose;
    IBOutlet UIButton *btnForFlash;
    IBOutlet UIButton *btnForFront;
    
    //Camera View
    
    IBOutlet UIView      *viewForPreview;
    IBOutlet UIImageView *imageViewForPreview;
    IBOutlet UIView *viewForCamera;
   
     // for photo editing
    IBOutlet UIScrollView *scrollViewForPreview;
    
    //Bottom Bar
    
    IBOutlet UIView   *viewForBottomBar;
    IBOutlet UIButton *btnForCamera;
    IBOutlet UIButton *btnForAlbum;
    IBOutlet UIButton *btnForVideo;
    
    UIImagePickerController *imagePickerController;
    NSMutableDictionary *infoDictionary;
    
    MBProgressHUD *hud;
}

@property (nonatomic, strong) NSString *postMode;

@property (nonatomic) kTypeUpload       uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) PFObject          *curObj;

- (IBAction)topButtonsAction:(id)sender;
- (IBAction)bottomButtonsAction:(id)sender;

@end
