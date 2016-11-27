//
//  OMPanoViewController.h
//  ICYMI
//
//  Created by lion on 11/20/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMD_LITE.h"
@class PLITInfoView;

@protocol OMPanoViewControllerDelegate <NSObject>

-(void)didFinishCapture:(UIImage*)image;

@end

@interface OMPanoViewController : UIViewController <MonitorDelegate, UIGestureRecognizerDelegate>
{
    ShooterView *_shooterView;
    PLITInfoView *_infoView;
    UIActivityIndicatorView *_activityInd;
    NSInteger _numShots;
    UITapGestureRecognizer *_tapRecognizer;
    NSTimer *_vibrationTimer;
}

@property (nonatomic) id<OMPanoViewControllerDelegate> delegate;

@end
