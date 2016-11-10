//
//  OMPhotoEditViewController.h
//  Collabro
//
//  Created by Ellisa on 29/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
/////
//#import "PECropViewController.h"
#import "OMDrawTextViewController.h"
#import "PhotoTweaksViewController.h"
/////

@interface OMPhotoEditViewController : UIViewController<PhotoTweaksViewControllerDelegate, DrawTextViewControllerDelegate>
{
    //Top Bar
    
    IBOutlet UIView *viewForTopBar;
    
    IBOutlet UIButton *btnForBack;
    
    IBOutlet UIButton *btnForNext;
    
    IBOutlet UILabel *lblForTitle;
    
    
    
    //Preview
    
    IBOutlet UIView *viewForPreview;
    
    IBOutlet UIImageView *imageViewForPreview;
    // Bottom View
    
    
    IBOutlet UIView *viewForBottom;
    
    
}

- (IBAction)backAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)cropAction:(id)sender;
- (IBAction)penAndTextAction:(id)sender;


@property (strong, nonatomic) UIImage *preImage;

@property (nonatomic) kTypeUpload      uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) PFObject          *curObj;
@property (nonatomic, assign) int       postOrder;
@property (nonatomic, strong) NSString *postType;
@property (nonatomic) BOOL editFlag;
@end
