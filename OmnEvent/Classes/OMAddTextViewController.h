//
//  OMAddTextViewController.h
//  ICYMI
//
//  Created by lion on 11/12/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTextViewControllerDelegate;

@interface OMAddTextViewController : UIViewController
@property (nonatomic, weak) id<AddTextViewControllerDelegate> delegate;
@property (nonatomic) UIImage *image;
@end

@protocol AddTextViewControllerDelegate <NSObject>
@optional
-(void)atViewController:(OMAddTextViewController *)controller didFinishDTImage:(UIImage *)dtImage;
-(void)atViewControllerDidCancel:(OMAddTextViewController *)controller;

@end
