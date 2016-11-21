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

@interface OMPanoViewController : UIViewController <MonitorDelegate, UIGestureRecognizerDelegate>
{
    ShooterView *_shooterView;
    PLITInfoView *_infoView;
    UIActivityIndicatorView *_activityInd;
    NSInteger _numShots;
    UITapGestureRecognizer *_tapRecognizer;
    NSTimer *_vibrationTimer;
}

@property (nonatomic) kTypeUpload      uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) PFObject          *curObj;
@property (nonatomic, assign) int       postOrder;
@property (nonatomic, strong) NSString *postType;
@property (nonatomic) BOOL editFlag;

@end
