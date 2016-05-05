//
//  OMPreviewPhotoViewController.h
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMPreviewPhotoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{
    
    
    IBOutlet UIImageView *imageViewForProfile;
    IBOutlet UITextView *txtForDes;
    
    IBOutlet UIImageView *imageViewForPreview;
    
    IBOutlet UILabel *lblForTag;
    
    IBOutlet UILabel *lblForPlaceholder;
    
}


@property (nonatomic,strong) UIImage *imageForPreview;
@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

- (IBAction)cancelAction:(id)sender;

- (IBAction)postAction:(id)sender;

- (IBAction)tagAction:(id)sender;

@end
