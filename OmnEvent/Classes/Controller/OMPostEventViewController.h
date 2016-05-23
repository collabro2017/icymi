//
//  OMPostEventViewController.h
//  Collabro
//
//  Created by Ellisa on 30/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMPostEventViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{
    
    IBOutlet UIView *viewForPost;
    
    IBOutlet UIImageView *imageViewForPostImage;
    IBOutlet UITextField *lblForTitle;
    
    IBOutlet UITextView *textViewForDescription;
    
    IBOutlet UILabel *lblForPlaceholder;
    IBOutlet UITextField *lblForLocation;
    
    IBOutlet UIButton *btnForSearchLocation;
    
    
    IBOutlet UILabel *lblForCount;
    
    NSData *mediaData;
    UIImage *thumbImageForVideo;
    
    UIImagePickerController *imagePicker;
    
    ////
    UIImage *thumbImageForAudio;
    IBOutlet NSLayoutConstraint *constraintForWidth;
    
}
@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

@property (nonatomic, strong) UIImage *imageForPost;
@property (nonatomic, strong) NSURL   *outPutURL;

@property (nonatomic, strong) NSString *postType;

@property (nonatomic, strong) NSData    *audioData;


@property (nonatomic, strong) PFObject *curObj;
@property (nonatomic) kTypeUpload       uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) kTypeRecord       audioOption;
@end
