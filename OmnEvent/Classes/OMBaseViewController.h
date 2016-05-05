//
//  OMBaseViewController.h
//  OmnEvent
//
//  Created by elance on 7/29/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AMScrollingNavbarViewController.h"

@interface OMBaseViewController : UIViewController<SlideNavigationControllerDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
 
    BOOL show;
    
}

- (void)initializeNavigationBar;
- (void)showSearchButton;

- (void)changeTitle:(NSString *)_title;

@end
