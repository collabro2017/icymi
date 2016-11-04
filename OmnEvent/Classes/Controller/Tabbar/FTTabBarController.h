//
//  FTTabBarController.h
//  Forty
//
//  Created by Ellisa on 15/12/14.
//  Copyright (c) 2014 Linus Olander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMGlobal.h"
@class PopUpMenuView;

@interface FTTabBarController : UIViewController
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    IBOutlet UIButton *btnForAvatar;
    
    IBOutlet UIView *tabView;
    
    
    
    IBOutlet UILabel *lblForNotification;
    
    
    IBOutlet NSLayoutConstraint *constraintForNotificationHeight;
    
}

- (IBAction)showTutorialVideoAction:(id)sender;

@property (nonatomic, strong) PopUpMenuView *popupView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;


@property (strong, nonatomic)       NSString *destinationIdentifier;

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *placeholderView;

@property (nonatomic, strong) UIViewController *oldViewController;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *tabBarButtons;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintWidthTabbar;

- (IBAction)tabBarAction:(id)sender;


- (IBAction)showMessageAction:(id)sender;

- (void)newPostAction:(int)_uploadOption mediaKind:(int)_captureOption currentObject:(PFObject *)_curObj postOrder:(int)_postOrder;

- (void)postAudio:(int)_uploadOption mediaKind:(int)_captureOption currentObject:(PFObject *)_curObj
        audioData:(NSData *)_audioData postOrder:(int)_postOrder;

- (void) setSelectedIndex:(int)index;

- (void)hideTabView:(BOOL) _hidden;

- (void)signOut;

@end
