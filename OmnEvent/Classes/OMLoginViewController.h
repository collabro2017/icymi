//
//  OMLoginViewController.h
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTextField.h"

@interface OMLoginViewController : UIViewController<UITextFieldDelegate>
{
    
    IBOutlet UITextField *txtForUsername;
    
    IBOutlet UITextField *txtForPassword;
    
    IBOutlet NSLayoutConstraint *constraintForHeight;
    
    //
    
    
    IBOutlet UIButton *btnForLogin;
    
    IBOutlet UIButton *btnForForgot;
    
}


- (IBAction)signInAction:(id)sender;

- (IBAction)forgotPasswordAction:(id)sender;
- (IBAction)backAction:(id)sender;


@end
