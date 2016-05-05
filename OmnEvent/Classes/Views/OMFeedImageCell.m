//
//  OMFeedImageCell.m
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFeedImageCell.h"

@implementation OMFeedImageCell

- (void)awakeFromNib {
    // Initialization code
//    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
//    _videoPlayerController.delegate = self;
//    _videoPlayerController.view.frame = _imageViewForPhoto.bounds;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentObj:(PFObject *)obj
{
    if (_imageViewForPhoto.image) {
        
        _imageViewForPhoto.image = nil;
    }
    [_btnForVideo setHidden:YES];
    [_imageViewForPhoto setHidden:NO];

//    [_videoPlayerController.view setHidden:YES];

    _currentObj = obj;
    PFFile *postImgFile = (PFFile *)_currentObj[@"thumbImage"];
    if (postImgFile) {
        [_imageViewForPhoto setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }    
    
    if ([_currentObj[@"postType"] isEqualToString:@"video"]) {
        
       
    }
//
//        double delayInSeconds = 0.0001f;
//        
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
//        
//       
//        dispatch_after(popTime, dispatch_get_main_queue(), ^{
//           
//            
//        });
//    }
    else if ([_currentObj[@"postType"] isEqualToString:@"image"])
    {
        [_btnForVideo setHidden:YES];
        
        [_videoPlayerController.view setHidden:YES];
        if (_videoPlayerController.view) {
        
            [_videoPlayerController.view removeFromSuperview];
        }

    }
    else
    {
        [_videoPlayerController.view setHidden:YES];
        if (_videoPlayerController.view) {
            
            [_videoPlayerController.view removeFromSuperview];
        }


    }
}

- (void)playVideo
{
    [_videoPlayerController playFromBeginning];
}

- (void)showControls
{
    [_btnForVideo setHidden:YES];
    [_imageViewForPhoto setHidden:YES];
//    [_videoPlayerController.view setHidden:NO];

}
#pragma mark - PBJ Delegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{

}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    
    switch (videoPlayer.playbackState) {
        case PBJVideoPlayerPlaybackStateStopped:
        {
//            [_btnForVideo setHidden:NO];
//            [_imageViewForPhoto setHidden:NO];

        }
            break;
        case PBJVideoPlayerPlaybackStatePlaying:
        {
            [self performSelector:@selector(showControls) withObject:nil afterDelay:.3f];

            
        }
            break;
        case PBJVideoPlayerPlaybackStatePaused:
        {
        
        }
            break;
               case PBJVideoPlayerPlaybackStateFailed:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
//    [self performSelector:@selector(showControls) withObject:nil afterDelay:1.f];


}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [self performSelector:@selector(playVideo) withObject:nil afterDelay:0.05f];
}
- (IBAction)playVideoAction:(id)sender {
}

///

- (void)playVideo:(NSString *)_link
{
        [_btnForVideo setHidden:NO];
        [_videoPlayerController.view setHidden:NO];
        PFFile *videoFile = (PFFile *)_currentObj[@"video"];
    
        if (_videoPlayerController) {
            [_videoPlayerController stop];
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
            
        }
        else
        {
            _videoPlayerController = [[PBJVideoPlayerController alloc] init];
            _videoPlayerController.delegate = self;
            _videoPlayerController.view.frame = _imageViewForPhoto.bounds;
            
        }
    
        __block OMFeedImageCell *cell = self;
        __block PBJVideoPlayerController *controller = _videoPlayerController;
    
    double delayInSeconds = 0.0001f;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
    
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        
        [viewForPre insertSubview:controller.view belowSubview:_imageViewForPhoto];
        controller.videoPath = _link;
        [controller playFromBeginning];

        
    });

//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
//        });

}

- (void)stopVideo
{
    [_videoPlayerController stop];
    
//    [_videoPlayerController.view removeFromSuperview];
//    _videoPlayerController = nil;
//    
//    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
//    _videoPlayerController.delegate = self;
//    _videoPlayerController.view.frame = _imageViewForPhoto.bounds;

    [_btnForVideo setHidden:NO];
    [_imageViewForPhoto setHidden:NO];
    
    

}
@end
