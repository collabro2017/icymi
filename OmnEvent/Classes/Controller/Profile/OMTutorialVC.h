//
//  OMTutorialVC.h
//  Collabro
//
//  Created by Ellisa on 7/2/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"
#import "OMBaseViewController.h"

@interface OMTutorialVC : OMBaseViewController<PBJVideoPlayerControllerDelegate>
{
    
    PBJVideoPlayerController *_videoPlayerController;

}


@property (strong, nonatomic) IBOutlet UIView *viewForGuide;

@end
