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
    CGRect originFrame;
}

@synthesize user,delegate,currentObj, imageViewForMedia, beforeTitle, beforeDescription, curEventIndex;
@synthesize curPostIndex, checkMode;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
    
    txtViewForTitle.delegate = self;
    txtViewForDes.delegate = self;
}

- (IBAction)onCheckBtn:(id)sender {
    UIButton* tmp = (UIButton*)sender;
    NSLog(@"Check Tag === %d", [tmp tag]);
    
    if([[GlobalVar getInstance].gArrPostList count] > 0)
    {
        PFObject *selectedObj = [[GlobalVar getInstance].gArrPostList objectAtIndex:[tmp tag]];
        
        if([[GlobalVar getInstance].gArrSelectedList containsObject:selectedObj])
        {
            [[GlobalVar getInstance].gArrSelectedList removeObject:selectedObj];
            [btnCheckForExport setImage:[UIImage imageNamed:@"btn_uncheck_icon"] forState:UIControlStateNormal];
        }
        else
        {
            [[GlobalVar getInstance].gArrSelectedList addObject:selectedObj];
            [btnCheckForExport setImage:[UIImage imageNamed:@"btn_check_icon"] forState:UIControlStateNormal];
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showDetailPage:(UITapGestureRecognizer *)_gesture
{
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kExportCancel object:nil];
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
    
    //PFObject *object = obj;
    //currentObj = obj;
    
    [btnCheckForExport setTag:curPostIndex];
    [btnForVideoPlay setHidden:YES];
    
    
    if([[GlobalVar getInstance].gArrPostList count] > 0)
    {
        PFObject *selectedObj = [[GlobalVar getInstance].gArrPostList objectAtIndex:curPostIndex];
        
        if([[GlobalVar getInstance].gArrSelectedList containsObject:selectedObj])
        {
            [btnCheckForExport setImage:[UIImage imageNamed:@"btn_check_icon"] forState:UIControlStateNormal];
        }
        else
        {
            [btnCheckForExport setImage:[UIImage imageNamed:@"btn_uncheck_icon"] forState:UIControlStateNormal];
        }
    }
    [btnCheckForExport setHidden:!checkMode];
    

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [imageViewForAvatar addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *gestureForZoom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
    gestureForZoom.numberOfTapsRequired = 1;
    [imageViewForMedia addGestureRecognizer:gestureForZoom];
    [imageViewForMedia setUserInteractionEnabled:YES];
    
    
    PFObject *eventObj = obj[@"targetEvent"];
    
    
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
                txtViewForTitle.editable = YES;
                txtViewForDes.editable = YES;
            } else {
                txtViewForTitle.editable = NO;
                txtViewForDes.editable = NO;
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                txtViewForTitle.editable = YES;
                txtViewForDes.editable = YES;
            } else {
                txtViewForTitle.editable = NO;
                txtViewForDes.editable = NO;
            }
        }
        
    } else {
        txtViewForTitle.editable = YES;
        txtViewForDes.editable = YES;
    }
    
    user = obj[@"user"];
    
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
    
    [lblForTimer setText:[OMGlobal showTime:obj.createdAt]];
    
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM

    NSString *str_date = [dateFormat stringFromDate:obj.createdAt];
    [lblForTimer setText:str_date];
    
    [lblForTimer setTextColor:HEXCOLOR(0x6F7179FF)];

    //*******************
    
    txtViewForTitle.text = obj[@"title"];
    txtViewForDes.text = obj[@"description"];
    
    constraintForTitle.constant = [OMGlobal getBoundingOfString:currentObj[@"title"] width:txtViewForTitle.frame.size.width].height + 20;
    constraintForDescription.constant = [OMGlobal getBoundingOfString:currentObj[@"description"] width:txtViewForDes.frame.size.width].height + 30;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_GEOCODE_ENABLED"]) {
        if (obj[@"countryLatLong"] && ![obj[@"countryLatLong"] isEqualToString:@""]) {
            lblForLocation.text = obj[@"countryLatLong"];
        }
        else {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:obj[@"country"] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (placemarks.count > 0) {
                    CLPlacemark *placemark = placemarks.firstObject;
                    CLLocationCoordinate2D location = placemark.location.coordinate;
                    
                    int latSeconds = (int)(location.latitude * 3600);
                    int latDegrees = latSeconds / 3600;
                    latSeconds = ABS(latSeconds % 3600);
                    int latMinutes = latSeconds / 60;
                    latSeconds %= 60;
                    
                    int longSeconds = (int)(location.longitude * 3600);
                    int longDegrees = longSeconds / 3600;
                    longSeconds = ABS(longSeconds % 3600);
                    int longMinutes = longSeconds / 60;
                    longSeconds %= 60;
                    
                    NSString* result = [NSString stringWithFormat:@"%d°%d'%d\"%@ %d°%d'%d\"%@",
                                        ABS(latDegrees),
                                        latMinutes,
                                        latSeconds,
                                        latDegrees >= 0 ? @"N" : @"S",
                                        ABS(longDegrees),
                                        longMinutes,
                                        longSeconds,
                                        longDegrees >= 0 ? @"E" : @"W"];
                    lblForLocation.text = result;
                    
                    obj[@"countryLatLong"] = result;
                    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            NSLog(@"=========================================== Success!!!");
                        }else{
                            NSLog(@"=========================================== Error : %@", error.localizedDescription);
                        }
                    }];
                }
            }];
        }
    } else {
        [lblForLocation setText:obj[@"country"]];
    }
    
    // for badge processing
    
    if(curEventIndex >= 0)
    {
        OMSocialEvent *socialTemp = [[GlobalVar getInstance].gArrEventList objectAtIndex:curEventIndex];
        
        if (socialTemp.badgeCount > 0) {
            
            OMSocialEvent *socialEventObj = (OMSocialEvent*)eventObj;
            if(obj != nil)
            {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                temp = [obj[@"usersBadgeFlag"] mutableCopy];
                
                if ([temp containsObject:self_user.objectId])
                {
                    [GlobalVar getInstance].isPosting = YES;
                    [lblForTimer setTextColor:[UIColor redColor]];
                    
                    [temp removeObject:self_user.objectId];
                    obj[@"usersBadgeFlag"] = temp;
                    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error == nil)
                        {
                            NSLog(@"DetailEventVC: Post Badge remove when open Detail view...");
                            [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(delayChangeTextColor:) userInfo: nil repeats: NO];
                            [GlobalVar getInstance].isPosting = NO;
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
    
    PFFile *postImgFile = (PFFile *)obj[@"thumbImage"];
    
    if (postImgFile) {
        [imageViewForMedia setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    
    if ([obj[@"postType"] isEqualToString:@"video"]) {
        [btnForVideoPlay setHidden:NO];
        [_videoPlayerController.view setHidden:NO];
        
        PFFile *videoFile = (PFFile *)obj[@"postFile"];
        
        if (_videoPlayerController) {
            
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
            
        }
        
        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
        _videoPlayerController.delegate = self;
        
        _videoPlayerController.view.frame = imageViewForMedia.frame;
        [viewForMedia addSubview:_videoPlayerController.view];
        
        _videoPlayerController.videoPath = videoFile.url;
        if (_file != nil && _offline_url){
            NSString *urlString = [_offline_url absoluteString];
            _videoPlayerController.videoPath = urlString;            
        }
        
        [viewForMedia bringSubviewToFront:btnForVideoPlay];
        [viewForMedia bringSubviewToFront:btnCheckForExport];
        
    } else if ([obj[@"postType"] isEqualToString:@"photo"]) {
        
        [btnForVideoPlay setHidden:YES];
        [_videoPlayerController.view setHidden:YES];
        
        if (_videoPlayerController.view) {
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
        }
        
        if (_file != nil){
            
            [imageViewForMedia setImage:[UIImage imageWithData:_file.getData]];
        }
        
        if (!postImgFile) {
            
            PFFile *postFile = (PFFile *)obj[@"postFile"];
            
            if (postFile) {
                [imageViewForMedia setImageWithURL:[NSURL URLWithString:postFile.url]];
            }
        }
        
    } else if ([obj[@"postType"] isEqualToString:@"audio"]) {
        
        [_videoPlayerController.view setHidden:YES];
        [btnForVideoPlay setHidden:YES];

        if (_videoPlayerController.view) {
            
            [_videoPlayerController.view removeFromSuperview];
            _videoPlayerController = nil;
        }
        
        PFFile *thumbImageFile = (PFFile *)obj[@"thumbImage"];
        
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
        [viewForMedia addSubview:btnForPlay];
        
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
        
        PFFile *postFile = (PFFile *)obj[@"postFile"];
        
        if (postFile) {
            [imageViewForMedia setImageWithURL:[NSURL URLWithString:postFile.url]];
        }
        
        if (_file != nil){
            [imageViewForMedia setImage:[UIImage imageWithData:_file.getData]];
        }
    }
    
    //display comment count
    
    if (obj[@"commentsUsers"]) {
        
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"%lu",(unsigned long) [obj[@"commentsUsers"] count]] forState:UIControlStateNormal];
        
    } else
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    
    //display like status
    
    if (currentObj[@"likers"]) {
        likeCount = [obj[@"likers"] count];
    } else {
        likeCount = 0;
    }
    
    likeUserArray = [NSMutableArray array];
    likerArr = [NSMutableArray array];
    
    if (obj[@"likers"] && obj[@"likeUserArray"]) {
        
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)likeCount] forState:UIControlStateNormal];
        [likeUserArray addObjectsFromArray:obj[@"likers"]];
        [likerArr addObjectsFromArray:obj[@"likeUserArray"]];

    } else
        [btnForLikeCount setTitle:@"0" forState:UIControlStateNormal];
    
    if (obj[@"likers"]) {
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

#pragma mark - Delegate methods of UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == txtViewForTitle) {
        beforeTitle = txtViewForTitle.text;
    }
    
    if (textView == txtViewForDes) {
        beforeDescription = txtViewForDes.text;
    }
    
    if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:textView.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y + 40] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textView.inputAccessoryView.frame.size.height] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        if (textView == txtViewForTitle) {
            if (![beforeTitle isEqualToString:txtViewForTitle.text] && txtViewForTitle.text.length > 0){
                currentObj[@"title"] = txtViewForTitle.text;
                
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
            
            [txtViewForTitle resignFirstResponder];
        }
        
        if (textView == txtViewForDes) {
            if (![beforeDescription isEqualToString:txtViewForDes.text] && txtViewForDes.text.length > 0){
                currentObj[@"description"] = txtViewForDes.text;
                
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
            
            [txtViewForDes resignFirstResponder];
        }
        
        if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
            CGPoint bottomPosition = [textView convertPoint:textView.frame.origin toView:textView.superview.superview.superview.superview];
            
            NSDictionary *userInfo = @{
                                       @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                       @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                       };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
        }
    }
    else {
        if ([textView isEqual:txtViewForTitle] && (textView.text.length < MAX_TITLE_LIMIT || [text isEqualToString:@""])) {
            return YES;
        }
        else if ([textView isEqual:txtViewForDes] && (textView.text.length < MAX_DESCRIPTION_LIMIT || [text isEqualToString:@""])) {
            return YES;
        }
    }
    
    return NO;
}

@end
