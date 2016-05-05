//
//  OMChangePasswordViewController.h
//  Collabro
//
//  Created by Ellisa on 17/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMChangePasswordViewController : UITableViewController<UITextFieldDelegate>
{
    
    IBOutlet UITextField *txtForCurrentPassword;
    
    IBOutlet UITextField *txtForNewPassword;
    
    IBOutlet UITextField *txtForConfirmPassword;
    
}

@end
