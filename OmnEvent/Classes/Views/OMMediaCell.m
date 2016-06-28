//
//  OMMediaCell.m
//  Collabro
//
//  Created by Ellisa on 02/04/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMMediaCell.h"
#import "OMSocialEvent.h"
#import "FTWCache.h"
#import "NSString+MD5.h"


@implementation OMMediaCell
{
    NSInteger curIndex;
}
@synthesize user,delegate,currentObj, imageViewForMedia, beforeTitle, beforeDescription, curEventIndex;

- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
    
    lblForTitle.delegate = self;
    lblForDes.delegate = self;
    curEventIndex = [GlobalVar getInstance].gEventIndex;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showDetailPage:(UITapGestureRecognizer *)_gesture
{
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        [delegate performSelector:@selector(showProfile:) withObject:user];
    }
    
}

- (void)zoomImage:(UITapGestureRecognizer *)_gesture
{
    if ([delegate respondsToSelector:@selector(zoomImage:)]) {
        [delegate performSelector:@selector(zoomImage:) withObject:self];
    }
    
}

- (void)delayChangeTextColor:(NSTimer*)dt
{
    [lblForTimer setTextColor:HEXCOLOR(0x6F7179FF)];
}

- (void)setCurrentObj:(PFObject *)obj {
    
    currentObj = obj;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [imageViewForAvatar addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *gestureForZoom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
    gestureForZoom.numberOfTapsRequired = 1;
    [imageViewForMedia addGestureRecognizer:gestureForZoom];
    [imageViewForMedia setUserInteractionEnabled:YES];
    
    
    PFObject *eventObj = currentObj[@"targetEvent"];
    
    
    PFUser *eventUser = eventObj[@"user"];
    PFUser *self_user = [PFUser currentUser];

   
    NSMutableArray *arrForTagFriends = [NSMutableArray array];
    NSMutableArray *arrForTagFriendAuthorities  = [NSMutableArray array];
    
    if(eventObj[@"TagFriends"] != nil && [eventObj[@"TagFriends"] count] > 0)
    {
        arrForTagFriends = eventObj[@"TagFriends"];
    }
    if(eventObj[@"TagFriendAuthorities"] != nil && [eventObj[@"TagFriendAuthorities"] count] > 0)
    {
        arrForTagFriendAuthorities = eventObj[@"TagFriendAuthorities"];
    }
    
    if (![eventUser.objectId isEqualToString:self_user.objectId]){
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil && [arrForTagFriendAuthorities count] > 0){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                        AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    
                    break;
                }
            }
            
            if ([AuthorityValue isEqualToString:@"Full"]){
                lblForDes.enabled = YES;
                lblForTitle.enabled = YES;
            } else {
                lblForDes.enabled = NO;
                lblForTitle.enabled = NO;
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                lblForDes.enabled = YES;
                lblForTitle.enabled = YES;
            } else {
                lblForDes.enabled = NO;
                lblForTitle.enabled = NO;
            }
        }
        
    } else {
        lblForDes.enabled = YES;
        lblForTitle.enabled = YES;
    }
    
    user = currentObj[@"user"];
    
    //Display avatar image
    
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        
        if (imageViewForAvatar.image) {
            imageViewForAvatar.image = nil;
        }
        
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        
        if (avatarFile) {
            
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
        }
        
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
    }

    //display Username
    
    [lblForUsername setText:user.username];
    
    [lblForTimer setText:[OMGlobal showTime:currentObj.createdAt]];
    
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM

    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    [lblForTimer setText:str_date];
    
    [lblForTimer setTextColor:HEXCOLOR(0x6F7179FF)];

    //*******************
    
    
    
    [lblForTitle setText:currentObj[@"title"]];
    [lblForDes setText:currentObj[@"description"]];
    
    constraintForDescription.constant = [OMGlobal getBoundingOfString:currentObj[@"description"] width:lblForDes.frame.size.width].height + 40;
    
    constraintForTitle.constant = [OMGlobal getBoundingOfString:currentObj[@"title"] width:lblForTitle.frame.size.width].height;
    
    [lblForLocation setText:currentObj[@"country"]];
    
    
    // for badge processing
    NSLog(@"------Current Index-----%ld", curEventIndex);
    if(curEventIndex >= 0)
    {
        OMSocialEvent *socialTemp = [[GlobalVar getInstance].gArrEventList objectAtIndex:curEventIndex];
        
        if (socialTemp.badgeCount > 0) {
            
            [lblForTimer setTextColor:[UIColor redColor]];
            
            OMSocialEvent *socialEventObj = (OMSocialEvent*)eventObj;
            if(currentObj != nil)
            {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                temp = [currentObj[@"usersBadgeFlag"] mutableCopy];
                
                if ([temp containsObject:self_user.objectId])
                {
                    [temp removeObject:self_user.objectId];
                    currentObj[@"usersBadgeFlag"] = temp;
                    [currentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error == nil)
                        {
                            NSLog(@"DetailEventVC: Post Badge remove when open Detail view...");
                            [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(delayChangeTextColor:) userInfo: nil repeats: NO];
                        }
                    }];
                    
                    if(socialEventObj.badgeCount >= 1) socialEventObj.badgeCount -= 1;
                    [[GlobalVar getInstance].gArrEventList replaceObjectAtIndex:curEventIndex withObject:socialEventObj];
                    
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:kLoadEventDataWithGlobal object:nil];
            }
        }
    }

    
    
    
    // Display image
    
    if (imageViewForMedia.image) {
        imageViewForMedia.image = nil;
    }
    
    if (_playButton) {
        
        [_playButton removeFromSuperview];
        _playButton = nil;
    }
    
    if ([self viewWithTag:10]) {
        
        UIButton *button = (UIButton *)[self viewWithTag:10];
        
        [button removeFromSuperview];
        button = nil;
        
    }
    
    if ([imageViewForMedia viewWithTag:11]) {
        
        PCSEQVisualizer *tempEQ = (PCSEQVisualizer *)[imageViewForMedia viewWithTag:11];
        
        [tempEQ removeFromSuperview];
        tempEQ = nil;
    
    }

    [_videoPlayerController.view setHidden:YES];
    
    PFFile *postImgFile = (PFFile *)currentObj[@"thumbImage"];
    
    if (postImgFile) {
        [imageViewForMedia setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    
    if ([currentObj[@"postType"] isEqualToString:@"video"]) {
        
        [_videoPlayerController.view setHidden:NO];
        
        PFFile *videoFile = (PFFile *)currentObj[@"postFile"];
        
        if (_videoPlayerController) {
            
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
            
        }
        
        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
        _videoPlayerController.delegate = self;
        
        _videoPlayerController.view.frame = imageViewForMedia.frame;
        [self insertSubview:_videoPlayerController.view aboveSubview:imageViewForMedia];
        
        _videoPlayerController.videoPath = videoFile.url;
        if (_file != nil && _offline_url){
            NSString *urlString = [_offline_url absoluteString];
            _videoPlayerController.videoPath = urlString;            
        }
        
        _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_video_play"]];
        _playButton.center = imageViewForMedia.center;
        [self addSubview:_playButton];
        [self bringSubviewToFront:_playButton];

        ////******************   Video **************
        
        
//        __block OMMediaCell *cell = self;
//        __block PBJVideoPlayerController *controller = _videoPlayerController;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
////            [cell insertSubview:controller.view belowSubview:_btnForVideo];
//            controller.videoPath = videoFile.url;
//            [controller playFromBeginning];
//            
//        });
        
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
        
    } else if ([currentObj[@"postType"] isEqualToString:@"photo"]) {
        
        [_videoPlayerController.view setHidden:YES];
        
        if (_videoPlayerController.view) {
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
        }
        
        if (_file != nil){
            
            [imageViewForMedia setImage:[UIImage imageWithData:_file.getData]];
        }
        
        if (!postImgFile) {
            
            PFFile *postFile = (PFFile *)currentObj[@"postFile"];
            
            if (postFile) {
                [imageViewForMedia setImageWithURL:[NSURL URLWithString:postFile.url]];
            }
        }
        
    } else if ([currentObj[@"postType"] isEqualToString:@"audio"]) {
        
        [_videoPlayerController.view setHidden:YES];
        
        if (_videoPlayerController.view) {
            
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
        }
        
        PFFile *thumbImageFile = (PFFile *)currentObj[@"thumbImage"];
        
        if (thumbImageFile){
            
            if (thumbImageFile.url != nil) {
                [imageViewForMedia setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImageFile.url]]]];
            } else {
                [imageViewForMedia setImage:[UIImage imageWithData:thumbImageFile.getData]];
            }
        } else
            [imageViewForMedia setImage:[UIImage imageNamed:@"layer_audio"]];  ////audio special
        
        btnForPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        btnForPlay.tag = 10;
        btnForPlay.center = imageViewForMedia.center;
        [btnForPlay setImage:[UIImage imageNamed:@"btn_playaudio"] forState:UIControlStateNormal];
        [self addSubview:btnForPlay];
        [btnForPlay addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
        
        eq = [[PCSEQVisualizer alloc]initWithNumberOfBars:6];
        eq.tag = 11;
        //position eq in the middle of the view
        CGRect frame = eq.frame;
        frame.origin.x = (imageViewForMedia.frame.size.width - eq.frame.size.width * 1.5);
        frame.origin.y = (eq.frame.size.height * 0.5);
        eq.frame = frame;
        [imageViewForMedia addSubview:eq];
        [eq setHidden:YES];

    } else {
        
        PFFile *postFile = (PFFile *)currentObj[@"postFile"];
        
        if (postFile) {
            [imageViewForMedia setImageWithURL:[NSURL URLWithString:postFile.url]];
        }
        
        if (_file != nil){
            [imageViewForMedia setImage:[UIImage imageWithData:_file.getData]];
        }
    }
    
    //display comment count
    
    if (currentObj[@"commentsUsers"]) {
        
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"%lu",(unsigned long) [currentObj[@"commentsUsers"] count]] forState:UIControlStateNormal];
        
    } else
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    
    //display like status
    
    if (currentObj[@"likers"]) {
        likeCount = [currentObj[@"likers"] count];
    } else {
        likeCount = 0;
    }
    
    likeUserArray = [NSMutableArray array];
    likerArr = [NSMutableArray array];
    
    if (currentObj[@"likers"] && currentObj[@"likeUserArray"]) {
        
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)likeCount] forState:UIControlStateNormal];
        [likeUserArray addObjectsFromArray:currentObj[@"likers"]];
        [likerArr addObjectsFromArray:currentObj[@"likeUserArray"]];

    } else
        [btnForLikeCount setTitle:@"0" forState:UIControlStateNormal];
    
    if (currentObj[@"likers"]) {
    }
    
    if ([likeUserArray containsObject:USER.objectId]) {
        liked = YES;
    } else {
        liked = NO;
    }
    
    [self setLikeButtonStatus:liked];
}

- (void)setLikeButtonStatus:(BOOL) _status {
    
    if (_status) {
        
        liked = YES;
        [btnForLike setImage:[UIImage imageNamed:@"btn_like_selected"] forState:UIControlStateNormal];
        
    } else {
        liked = NO;
        [btnForLike setImage:[UIImage imageNamed:@"btn_like_unselected"] forState:UIControlStateNormal];
    }
}

- (void)playVideo {
    [_videoPlayerController playFromBeginning];
}

#pragma mark - PBJ Delegate
- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer {
    
    _playButton.alpha = 1.0f;
    _playButton.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _playButton.hidden = YES;
    }];
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer {
    _playButton.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {
    
//    [self addSubview:videoPlayer.view];
//    [videoPlayer.view setFrame:imageViewForMedia.bounds];

}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer {
    
    switch (videoPlayer.playbackState) {
        case PBJVideoPlayerPlaybackStateStopped:
        {
            [btnForVideoPlay setHidden:NO];
            [GlobalVar getInstance].isPosting = NO;

        }
            break;
        case PBJVideoPlayerPlaybackStatePlaying:
        {
            [btnForVideoPlay setHidden:YES];
            [GlobalVar getInstance].isPosting = YES;
        }
            break;
        case PBJVideoPlayerPlaybackStatePaused:
        {
            [btnForVideoPlay setHidden:NO];
            [GlobalVar getInstance].isPosting = NO;

        }
            break;
        case PBJVideoPlayerPlaybackStateFailed:
        {
            [GlobalVar getInstance].isPosting = NO;
        }
            break;
        default:
            break;
    }
}

- (void)playAudio {
    
    [GlobalVar getInstance].isPosting = YES;
    if (audioPlayer.isPlaying || [[btnForPlay imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"btn_pauseaudio"]]) {
        
        [audioPlayer stop];
        [btnForPlay setImage:[UIImage imageNamed:@"btn_playaudio"] forState:UIControlStateNormal];
        [eq stop];
        [eq setHidden:YES];
        
        [GlobalVar getInstance].isPosting = NO;
        
    } else {
        
        PFFile *audioFile = (PFFile *)currentObj[@"postFile"];
        
        if (audioFile) {
            
            NSData *fetchedData = nil;
            if (audioFile.url != nil){
                fetchedData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:audioFile.url]];
            } else {
                fetchedData = audioFile.getData;
            }
            
            
            if (audioPlayer) {
                [audioPlayer stop]; //data is an iVar holding any existing playing music
                audioPlayer = nil;
            }
            
            audioPlayer = [[AVAudioPlayer alloc] initWithData:fetchedData error:nil];
           
            /* 
            // Cached Data tried for Speed....
            NSString *key = [audioFile.url MD5Hash];
            NSData *fetchedData = [FTWCache objectForKey:key];
            if(fetchedData)
            {
                audioPlayer = [[AVAudioPlayer alloc] initWithData:fetchedData error:nil];
            }
            else
            {
                NSData *data;
                if (audioFile.url != nil){
                    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioFile.url]];
                }
                else{
                    data = audioFile.getData;
                }
                [FTWCache setObject:data forKey:key];
                audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
                NSLog(@"Cached Data loading....");
            }
             */
            
          
            audioPlayer.delegate = self;
            [audioPlayer play];
            
            [btnForPlay setImage:[UIImage imageNamed:@"btn_pauseaudio"] forState:UIControlStateNormal];
            [eq setHidden:NO];
            
            [eq start];
        }
    }
    
//    if ([delegate respondsToSelector:@selector(playAudio:)]) {
//        
//        [delegate performSelector:@selector(playAudio:) withObject:currentObj];
//        
//    }

}

- (void)stopAudio {
    
    if (audioPlayer.isPlaying) {
        audioPlayer = nil;

        [audioPlayer stop];
        [btnForPlay setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
        [eq stop];
        [eq setHidden:YES];
        [GlobalVar getInstance].isPosting = NO;
    }
}

- (void)stopVideo {
    [_videoPlayerController stop];
}

#pragma mark - AVAudio Player Delegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [btnForPlay setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [eq stop];
    [eq setHidden:YES];
}

- (IBAction)likeAction:(id)sender {
    
    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)--likeCount] forState:UIControlStateNormal];
        [likeUserArray removeObject:USER.objectId];
        [likerArr removeObject:USER];
        [currentObj setObject:likeUserArray forKey:@"likers"];
        [currentObj setObject:likerArr forKey:@"likeUserArray"];
        [currentObj saveInBackground];
    } else {
        [self setLikeButtonStatus:YES];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)++likeCount] forState:UIControlStateNormal];
        [likeUserArray addObject:USER.objectId];
        [likerArr addObject:USER];
        [currentObj setObject:likeUserArray forKey:@"likers"];
        [currentObj setObject:likerArr forKey:@"likeUserArray"];

        [currentObj saveInBackground];
    }
}

- (IBAction)showLikersAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showLikersOfPost:)]) {
        [delegate performSelector:@selector(showLikersOfPost:) withObject:currentObj];
    }

}

- (IBAction)commentAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showComments:)]) {
        [delegate performSelector:@selector(showComments:) withObject:currentObj];
    }

}

- (IBAction)showCommentersAction:(id)sender {
}

- (IBAction)moreAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(sharePost:)]) {
        
        [delegate performSelector:@selector(sharePost:) withObject:self];
    }

}

- (IBAction)playAction:(id)sender {
    
    switch (_videoPlayerController.playbackState) {
        case PBJVideoPlayerPlaybackStateStopped:
        {
            [btnForVideoPlay setHidden:YES];
            
            [_videoPlayerController playFromBeginning];
           
            
        }
            break;
        case PBJVideoPlayerPlaybackStatePlaying:
        {
           
            [btnForVideoPlay setHidden:NO];
            [_videoPlayerController pause];
        }
            break;
        case PBJVideoPlayerPlaybackStatePaused:
        {
            
            [btnForVideoPlay setHidden:YES];
            [_videoPlayerController playFromCurrentTime];
            
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == lblForTitle) {
        beforeTitle = lblForTitle.text;
    }
    
    if (textField == lblForDes) {
        beforeDescription = lblForDes.text;
    }
    
    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y + 40] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textField.inputAccessoryView.frame.size.height] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == lblForTitle) {
        if (![beforeTitle isEqualToString:lblForTitle.text] && lblForTitle.text.length > 0){
            currentObj[@"title"] = lblForTitle.text;
            
            
            NSLog(@"Media Cell: Add and Change Post content title");
            
            // for badge
            PFUser *eventUser = currentObj[@"user"];
            NSMutableArray *arrEventTagFriends = [NSMutableArray array];
            PFObject *eventObj = currentObj[@"targetEvent"];
            arrEventTagFriends = eventObj[@"TagFriends"];
            if(![eventUser.objectId isEqualToString:USER.objectId])
            {
                [arrEventTagFriends addObject:eventUser.objectId];
                if ([arrEventTagFriends containsObject:USER.objectId]) {
                    [arrEventTagFriends removeObject:USER.objectId];
                }
            }
            
            currentObj[@"usersBadgeFlag"] = arrEventTagFriends;
            NSLog(@"Badge for comments of Post Added");
            
            OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
            if(appDel.network_state)
            {
                [currentObj saveInBackground];
            }
            
        }
        
        [lblForTitle resignFirstResponder];
    }
    
    if (textField == lblForDes){
        
        if (![beforeDescription isEqualToString:lblForDes.text] && lblForDes.text.length > 0){
            currentObj[@"description"] = lblForDes.text;
            
            NSLog(@"Media Cell: Add and Change Post content Description");
            
            // for badge
            PFUser *eventUser = currentObj[@"user"];
            NSMutableArray *arrEventTagFriends = [NSMutableArray array];
            PFObject *eventObj = currentObj[@"targetEvent"];
            arrEventTagFriends = eventObj[@"TagFriends"];
            if(![eventUser.objectId isEqualToString:USER.objectId])
            {
                [arrEventTagFriends addObject:eventUser.objectId];
                if ([arrEventTagFriends containsObject:USER.objectId]) {
                    [arrEventTagFriends removeObject:USER.objectId];
                }
            }
            
            currentObj[@"usersBadgeFlag"] = arrEventTagFriends;
           
            
            OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
            if(appDel.network_state)
            {
                 NSLog(@"Badge for comments of Post Added");
                [currentObj saveInBackground];
            }
        }
        
        [lblForDes resignFirstResponder];
    }
    
    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        CGPoint bottomPosition = [textField convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
    }
    
    return YES;
}

@end
