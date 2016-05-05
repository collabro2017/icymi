//
//  OMTutorialVC.m
//  Collabro
//
//  Created by Ellisa on 7/2/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMTutorialVC.h"

@interface OMTutorialVC ()
{
    NSString *urlForVideo;
    
    MPMoviePlayerViewController *player;
}


@end

@implementation OMTutorialVC
@synthesize viewForGuide;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    urlForVideo = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"mp4"];

    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    
    _videoPlayerController.delegate = self;
    [_videoPlayerController.view setFrame:viewForGuide.bounds];
    _videoPlayerController.videoPath = urlForVideo;
//    [viewForGuide addSubview:_videoPlayerController.view];
    
    
    
    player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:urlForVideo]];
    
//    [player.view setFrame:viewForGuide.bounds];
//    [viewForGuide addSubview:player.view];
    
    [TABController presentMoviePlayerViewControllerAnimated:player];
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [_videoPlayerController playFromBeginning];
    
}

#pragma mark PBJ delegate

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
