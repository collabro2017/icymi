//
//  OMEditProfileViewController.h
//  Collabro
//
//  Created by elance on 8/15/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTextField.h"
#import "CountryPicker.h"
@interface OMEditProfileViewControllers : UIViewController<MHTextFieldDelegate,CountryPickerDelegate,UITextFieldDelegate>
{
    
    IBOutlet MHTextField *txtForFirstName;
    
    IBOutlet MHTextField *txtForLastName;
    
    IBOutlet MHTextField *txtForEmail;
    
    IBOutlet UITextField *txtForCountry;
    
    
    IBOutlet MHTextField *txtForBirth;
    
    IBOutlet UITextField *txtForGender;
    
    
    IBOutlet CountryPicker *countryPicker;
    
    UIPickerView *genderPicker;
    UIDatePicker *birthPicker;
    
    IBOutlet UIButton *btnForDone;
    
    
   
    
    IBOutlet UILabel *lblForCountry;
    
    IBOutlet UILabel *lblForGender;
    
    
    
}
- (IBAction)countrySelectAction:(id)sender;

- (IBAction)genderSelectAction:(id)sender;


- (IBAction)doneAction:(id)sender;



@end
