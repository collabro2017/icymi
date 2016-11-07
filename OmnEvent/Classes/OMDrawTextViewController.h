//
//  OMDrawTextViewController.h
//  ICYMI
//
//  Created by lion on 11/6/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawTextViewControllerDelegate;

@interface OMDrawTextViewController : UIViewController

@property (nonatomic, weak) id<DrawTextViewControllerDelegate> delegate;
@property (nonatomic) UIImage *image;

@end

@protocol DrawTextViewControllerDelegate <NSObject>
@optional
-(void)dtViewController:(OMDrawTextViewController *)controller didFinishDTImage:(UIImage *)dtImage;
-(void)dtViewControllerDidCancel:(OMDrawTextViewController *)controller;

@end
