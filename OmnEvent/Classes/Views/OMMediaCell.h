//
//  OMMediaCell.h
//  Collabro
//
//  Created by Ellisa on 02/04/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"
#import "PCSEQVisualizer.h"

@interface OMMediaCell : UITableViewCell<PBJVideoPlayerControllerDelegate,AVAudioPlayerDelegate, UITextFieldDelegate>
{
    PBJVideoPlayerController *_videoPlayerController;
    UIImageView *_playButton;
    
    UIButton *btnForPlayState;
    UIButton *btnForPlay;
    PCSEQVisualizer* eq;
    AVAudioPlayer *audioPlayer;
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UIButton *btnCheckForExport;
    
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForTimer;
    
    //IBOutlet UILabel *lblForTitle;
    
    IBOutlet UITextField *lblForTitle;
    
    //IBOutlet UILabel *lblForDes;
    
    IBOutlet UITextField *lblForDes;
    
    IBOutlet UIView *viewForControl;
    
    IBOutlet UIButton *btnForLike;
    
    IBOutlet UIButton *btnForLikeCount;
    
    
    IBOutlet UIButton *btnForComment;
    
    IBOutlet UIButton *btnForCommentCount;
    
    IBOutlet UILabel *lblForLocation;
    
    IBOutlet UIButton *btnForMore;
    
    IBOutlet UIButton *btnForVideoPlay;
    
    IBOutlet UIView *viewForMedia;
    
    NSMutableArray *likeUserArray;
    NSMutableArray *likerArr;
    
    NSInteger likeCount;
    NSInteger commentCount;
    BOOL liked;
    
    IBOutlet NSLayoutConstraint *constraintForTitle;
    
    IBOutlet NSLayoutConstraint *constraintForDescription;
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;
@property (strong, nonatomic) PFFile   *file;
@property (strong, nonatomic) NSURL    *offline_url;
@property (readwrite) NSInteger curEventIndex;
@property (readwrite) NSInteger curPostIndex;
@property (readwrite) BOOL checkMode;

@property (strong, nonatomic) NSString *beforeTitle;
@property (strong, nonatomic) NSString *beforeDescription;

@property (strong, nonatomic)    IBOutlet UIImageView *imageViewForMedia;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrainImageRight;

- (IBAction)likeAction:(id)sender;
- (IBAction)showLikersAction:(id)sender;

- (IBAction)commentAction:(id)sender;

- (IBAction)showCommentersAction:(id)sender;

- (IBAction)moreAction:(id)sender;
- (IBAction)playAction:(id)sender;

- (void)playAudio;
- (void)stopAudio;
- (void)stopVideo;

@end
