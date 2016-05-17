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
    MPMoviePlayerViewController *playVC;
}


@end

@implementation OMTutorialVC
@synthesize viewForGuide;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    urlForVideo = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"mp4"];
    
    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    _videoPlayerController.delegate = self;
    //[_videoPlayerController.view setFrame:viewForGuide.bounds];
    _videoPlayerController.videoPath = urlForVideo;
    [_videoPlayerController playFromBeginning];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
}

#pragma mark PBJ delegate

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"delegate log1 === ");
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"delegate log2 === ");
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"delegate log3 === ");
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"delegate log4 === ");
    
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
