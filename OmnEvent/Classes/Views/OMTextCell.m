//
//  OMTextCell.m
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMTextCell.h"
#import "OMSocialEvent.h"

@implementation OMTextCell
@synthesize user,currentObj,delegate, beforeTitle, beforeDescription, curEventIndex;

- (void)awakeFromNib {
    // Initialization code
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
    
    lblForTitle.delegate = self;
    lblForDes.delegate = self;
    
    constraintForHeight.constant = 100;
    curEventIndex = [GlobalVar getInstance].gEventIndex;
    
    [self.superview layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentObj:(PFObject *)obj
{
    currentObj = obj;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [imageViewForAvatar addGestureRecognizer:gesture];
    
    PFObject *eventObj = currentObj[@"targetEvent"];
    
    PFUser *eventUser = eventObj[@"user"];
    PFUser *self_user = [PFUser currentUser];
    
    // for badge processing
    if(curEventIndex  >= 0)
    {
        OMSocialEvent *socialTemp = [[GlobalVar getInstance].gArrEventList objectAtIndex:curEventIndex];
        
        if (socialTemp.badgeCount > 0 ) {
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
                        }
                    }];
                    
                    if(socialEventObj.badgeCount >= 1) socialEventObj.badgeCount -= 1;
                    [[GlobalVar getInstance].gArrEventList replaceObjectAtIndex:curEventIndex withObject:socialEventObj];
                }
            }
        }
    }
    
    NSMutableArray *arrForTagFriends = eventObj[@"TagFriends"];
    NSMutableArray *arrForTagFriendAuthorities = eventObj[@"TagFriendAuthorities"];
    
//    NSLog(@"-------- userid %@", eventUser.objectId);
//    NSLog(@"-------- self_userid %@", self_user.objectId);
    
    if (![eventUser.objectId isEqualToString:self_user.objectId]){
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    break;
                }
            }
            
            if ([AuthorityValue isEqualToString:@"Full"]){
                
                lblForDes.editable = YES;
                //lblForDes.enabled = YES;
                lblForTitle.editable = YES;
            } else {
                lblForDes.editable = NO;
                //lblForDes.enabled = NO;
                lblForTitle.editable = NO;
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                lblForDes.editable = YES;
                //lblForDes.enabled = YES;
                lblForTitle.editable = YES;
            } else {
                lblForDes.editable = NO;
                //lblForDes.enabled = NO;
                lblForTitle.editable = NO;
            }
        }
        
    } else {
        lblForDes.editable = YES;
        //lblForDes.enabled = YES;
        lblForTitle.editable = YES;
    }
    
    user = currentObj[@"user"];
    
    //Display avatar image
    
    if ([user[@"loginType"] isEqualToString:@"email"]) {
        
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
    
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
    
    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    [lblForTime setText:str_date];
    
    
    [lblForTitle setText:currentObj[@"title"]];
    constraintForHeight.constant = [OMGlobal heightForCellWithPost:currentObj[@"description"]];
    
    [lblForDes setText:currentObj[@"description"]];
    
    // Display image
    
    //display comment count
    
    
    if (currentObj[@"commentsUsers"]) {
        
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"%lu",(unsigned long) [currentObj[@"commentsUsers"] count]] forState:UIControlStateNormal];
        
    }
    else
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    
    
    
    //display like status
    
    if (currentObj[@"likers"]) {
        likeCount = [currentObj[@"likers"] count];
        
    }
    else
    {
        likeCount = 0;
    }
    
    likeUserArray = [NSMutableArray array];
    
    if (currentObj[@"likers"]) {
        
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)likeCount] forState:UIControlStateNormal];
        [likeUserArray addObjectsFromArray:currentObj[@"likers"]];
        
    }
    else
        [btnForLikeCount setTitle:@"0" forState:UIControlStateNormal];
    
    if (currentObj[@"likers"]) {
    }
    if ([likeUserArray containsObject:USER.objectId]) {
        liked = YES;
    }
    else
    {
        liked = NO;
    }
    [self setLikeButtonStatus:liked];
    
}

- (void)setLikeButtonStatus:(BOOL) _status
{
    
    if (_status) {
        
        liked = YES;
        [btnForLike setImage:[UIImage imageNamed:@"btn_like_selected"] forState:UIControlStateNormal];
        
    }
    else
    {
        liked = NO;
        [btnForLike setImage:[UIImage imageNamed:@"btn_like_unselected"] forState:UIControlStateNormal];
        
    }
}

- (IBAction)likeAction:(id)sender {
    
    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)--likeCount] forState:UIControlStateNormal];
        [likeUserArray removeObject:USER.objectId];
        [currentObj setObject:likeUserArray forKey:@"likers"];
        [currentObj saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)++likeCount] forState:UIControlStateNormal];
        [likeUserArray addObject:USER.objectId];
        [currentObj setObject:likeUserArray forKey:@"likers"];
        [currentObj saveEventually];
    }
    
}

- (IBAction)showLikersAction:(id)sender {
    
    
}

- (IBAction)commentAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showComments:)]) {
        
        [delegate performSelector:@selector(showComments:) withObject:currentObj];
    }
    
}

- (IBAction)showCommentersAction:(id)sender {
}

- (IBAction)moreAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(sharePostText:)]) {
        [delegate performSelector:@selector(sharePostText:) withObject:currentObj];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (textView == lblForDes)
    {
        beforeDescription = lblForDes.text;
    }
    
    if (textView == lblForTitle){
        beforeTitle = lblForTitle.text;
    }
    
    if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        //NSLog(@" UITableView---");
        
        CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:textView.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y+30] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textView.inputAccessoryView.frame.size.height] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]){
        
        if (textView == lblForDes)
        {
            if (![beforeDescription isEqualToString:lblForDes.text] && lblForDes.text.length > 0){
                currentObj[@"description"] = lblForDes.text;
                
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
                    NSLog(@"Badge for description of Post Added");
                    [currentObj saveInBackground];
                }
                
                
                //NSUInteger line_no = [lblForDes.text length] / 28;
                //constraintForHeight.constant = 16 * line_no;
                
                //constraintForHeight.constant = 100;
                //[self.superview layoutIfNeeded];
            }
            
            [lblForDes resignFirstResponder];
        }
        
        if (textView == lblForTitle){
            
            if (![beforeTitle isEqualToString:lblForTitle.text] && lblForTitle.text.length > 0){
                currentObj[@"title"] = lblForTitle.text;
                
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
                    NSLog(@"Badge for title of Post Added");
                    [currentObj saveInBackground];
                }
                //constraintForTitleHeight.constant = 100;
                //[self.superview layoutIfNeeded];
            }
            [lblForTitle resignFirstResponder];
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
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
//    if (textField == lblForTitle)
//    {
//        beforeTitle = lblForTitle.text;
//    }
//    
////    if (textField == lblForDes)
////    {
////        beforeDescription = lblForDes.text;
////    }
//    
//    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
//        //NSLog(@" UITableView---");
//        
//        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
//        
//        NSDictionary *userInfo = @{
//                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
//                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y] stringValue],
//                                   @"textFieldHeight": [[NSNumber numberWithFloat:textField.inputAccessoryView.frame.size.height] stringValue]
//                                   };
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
//    if (textField == lblForTitle)
//    {
//        if (![beforeTitle isEqualToString:lblForTitle.text] && lblForTitle.text.length > 0){
//            currentObj[@"title"] = lblForTitle.text;
//            [currentObj saveEventually];
//        }
//        [lblForTitle resignFirstResponder];
//    }
//    
//    
//    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
//        CGPoint bottomPosition = [textField convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
//        
//        NSDictionary *userInfo = @{
//                                   @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
//                                   @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
//                                   };
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
//    }
    
    return YES;
}


@end
