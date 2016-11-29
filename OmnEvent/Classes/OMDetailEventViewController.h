//
//  OMDetailEventViewController.h
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"
//------------------------------
#import "UIButton+Badge.h"
#import "OMSocialEvent.h"

@interface OMDetailEventViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIDocumentInteractionControllerDelegate,MPMediaPickerControllerDelegate>
{
    
    NSMutableArray *arrForDetail;
    
    
    
    IBOutlet UIButton *btnForPhoto;
    
    IBOutlet UIButton *btnForAudio;
    
    IBOutlet UIButton *btnForVideo;
    
    UIImageView *postImgView;
    
    UIImagePickerController *imagePicker;
    MPMediaPickerController *mediaPicker;
    BOOL isVideoAdd;
    NSData *m_audioData;    
    NSData *audioDataToPlay;
    
    PFObject *tempObejct;
    NSURL *currentCellOfflineUrl;

    UITableViewCell* currentMediaCell;
    
    IBOutlet NSLayoutConstraint *DetailTableBottomHeight;
    
    IBOutlet UIButton *btnForNetState;
    IBOutlet UIButton *btnReverse;
    BOOL isActionSheetReverseSelected;
    //------------------
    IBOutlet UIButton *btnNotification;
    UILabel *lbl_card_count;
}

@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, strong) PFObject *currentObject;
@property (nonatomic, strong) NSMutableArray *arrTagedFriends;
@property (nonatomic) NSInteger curEventIndex;

- (IBAction)addContentsAction:(id)sender;

- (IBAction)changeShowOption:(id)sender;

- (IBAction)changeModeAction:(id)sender;


@end
