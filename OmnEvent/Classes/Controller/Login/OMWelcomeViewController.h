//
//  OMWelcomeViewController.h
//  Collabro
//
//  Created by Ellisa on 19/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMWelcomeViewController : UIViewController<GIDSignInDelegate, GIDSignInUIDelegate>{
    
    IBOutlet UIButton *btnForLogin;
    
    IBOutlet UIButton *btnForSignUp;
    
    IBOutlet UIButton *btnForFB;
    
}

- (IBAction)loginWithFBAction:(id)sender;



@end
