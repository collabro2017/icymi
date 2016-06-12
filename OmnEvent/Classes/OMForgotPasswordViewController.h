//
//  OMForgotPasswordViewController.h
//  Collabro
//
//  Created by elance on 8/21/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTextField.h"

@interface OMForgotPasswordViewController : UIViewController<UIAlertViewDelegate>
{
    

    
    IBOutlet UITextField *txtForEmail;
    
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containtLeft;

- (IBAction)submitAction:(id)sender;

- (IBAction)backAction:(id)sender;


@end
