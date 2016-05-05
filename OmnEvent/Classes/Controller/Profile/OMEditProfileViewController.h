//
//  OMEditProfileViewController.h
//  Collabro
//
//  Created by Ellisa on 31/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMEditProfileViewController : UITableViewController<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    //Avatar
    
    IBOutlet UIImageView *imageViewForAvatar;
  
    // name
    
    IBOutlet UITextField *txtForName;
    
    // Username
    
    IBOutlet UITextField *txtForUsername;
    
    //Email
    
    IBOutlet UITextField *txtForEmail;
    //Bio
    IBOutlet UITextField *txtForBio;
    // Gender
    
    IBOutlet UITextField *txtForGender;
    
    // Age
    IBOutlet UITextField *txtForAge;
    
    //City
    
    IBOutlet UITextField *txtForCity;
    
    //State
    
    IBOutlet UITextField *txtForState;
    
    // Postal Code
    
    IBOutlet UITextField *txtForPostalCode;
    
    
    // Country
    IBOutlet UITextField *txtForCountry;
    // Phone
    
    IBOutlet UITextField *txtForPhonenumber;
    
    IBOutlet UITextField *txtForVisiblity;
    
    IBOutlet UITextField *txtForSecurity;
    
    IBOutlet UITextField *txtForAnswer;
    
    BOOL avatarChanged;
    
    UIImage *changedAvatarImage;
    
    UIImagePickerController *imagePicker;
    
    PFObject* pfSelQuery;
}

@end
