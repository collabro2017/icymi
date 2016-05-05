//
//  OMNewEventPostViewController.h
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMNewEventPostViewController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    
    
    IBOutlet UIImageView *imageViewForThumb;
    
    IBOutlet UITextField *txtForEventName;
    
    IBOutlet UITextField *txtForDate;
    
    
    IBOutlet UITextField *txtForCountry;
    
    
    IBOutlet UILabel *lblForTap;
    IBOutlet UITextView *txtForDescription;
    
    IBOutlet UILabel *lblForPlaceholder;
    
    
}
@property (assign, nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;


- (IBAction)tagFriendAction:(id)sender;

- (IBAction)doneAction:(id)sender;

- (IBAction)backAction:(id)sender;




@end
