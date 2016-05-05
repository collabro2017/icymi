//
//  OMFeedImageCell.h
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"

@interface OMFeedImageCell : UITableViewCell<PBJVideoPlayerControllerDelegate>
{
    PBJVideoPlayerController *_videoPlayerController;
    
    UIButton *btnForPlayState;

    IBOutlet UIView *viewForPre;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewForPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnForVideo;



@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;


- (IBAction)playVideoAction:(id)sender;

- (void)playVideo:(NSString *)_link;
- (void)stopVideo;

@end
