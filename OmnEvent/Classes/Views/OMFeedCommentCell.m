//
//  OMFeedCommentCell.m
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFeedCommentCell.h"

@implementation OMFeedCommentCell {
    NSUInteger comment_number;
    BOOL event_flag;
}
@synthesize beforeDescription, currentObj, currentUser, currentCommentObj, commentObj;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [OMGlobal setCircleView:imageViewForProfile borderColor:nil];
    commentTextView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj number:(NSUInteger)_number {
    
    [commentTextView sizeToFit];
    [lblForTime setHidden:YES];
    currentUser = user;
    currentObj = _obj;
    comment_number = _number;
    event_flag = YES;
    
    PFUser *self_user = [PFUser currentUser];
    
    if (![currentUser.objectId isEqualToString:self_user.objectId]){
        
        NSMutableArray *arrForTagFriends = [NSMutableArray array];
        NSMutableArray *arrForTagFriendAuthorities = [NSMutableArray array];
        
        if(currentObj[@"TagFriends"] != nil && [currentObj[@"TagFriends"] count] > 0)
        {
            arrForTagFriends = currentObj[@"TagFriends"];
        }
        if(currentObj[@"TagFriendAuthorities"] != nil && [currentObj[@"TagFriendAuthorities"] count] > 0)
        {
            arrForTagFriendAuthorities = currentObj[@"TagFriendAuthorities"];
        }
        
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                        AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    
                    break;
                }
            }
            if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                commentTextView.editable = YES;
            } else {
                commentTextView.editable = NO;
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                commentTextView.editable = YES;
            } else {
                commentTextView.editable = NO;
            }
        }
        
        if (commentTextView.editable) {
            
            //[MBProgressHUD showHUDAddedTo:self.superview animated:YES];
            PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
            [query whereKey:@"targetEvent" equalTo:currentObj];
            [query whereKey:@"Commenter" equalTo:currentUser];
            [query whereKey:@"Comments" equalTo:_comment];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                //[MBProgressHUD hideHUDForView:self.superview animated:YES];
                if ([objects count] == 0 || !objects) {
                    return;
                }
                currentCommentObj = objects[0];
            }];
        }
        
    } else {
        
        commentTextView.editable = YES;
        
        //[MBProgressHUD showHUDAddedTo:self.superview animated:YES];
        PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
        [query whereKey:@"targetEvent" equalTo:currentObj];
        [query whereKey:@"Commenter" equalTo:currentUser];
        [query whereKey:@"Comments" equalTo:_comment];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //[MBProgressHUD hideHUDForView:self.superview animated:YES];
            if ([objects count] == 0 || !objects) {
                return;
            }
            currentCommentObj = objects[0];
        }];
    }
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            //NSLog(@"%@",currentUser.username);
            if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
                PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
                }
                
            }
            else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
            }
            
            constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:_comment];
            
            [commentTextView setText:_comment];
            [lblForUsername setText:currentUser.username];
        }
    }];
}

// for event
- (void)newsetUser:(NSString *)user comment:(NSString *)_comment curObj:(PFObject *)_obj
       commentType:(NSInteger)curType number:(NSUInteger)_number
{
    [commentTextView sizeToFit];
    [lblForTime setHidden:YES];
    
    currentType = kTypeEventComment;
    comment_number = _number;
    event_flag = YES;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error || !objects) {
            return;
        }
        else
        {
            currentUser = (PFUser *)objects[0];
            
            currentObj = _obj;
            
            PFUser *self_user = [PFUser currentUser];
            
            if (![currentUser.objectId isEqualToString:self_user.objectId]){
                
                NSMutableArray *arrForTagFriends = [NSMutableArray array];
                NSMutableArray *arrForTagFriendAuthorities = [NSMutableArray array];
                
                if(currentObj[@"TagFriends"] != nil && [currentObj[@"TagFriends"] count] > 0)
                {
                    arrForTagFriends = currentObj[@"TagFriends"];
                }
                if(currentObj[@"TagFriendAuthorities"] != nil && [currentObj[@"TagFriendAuthorities"] count] > 0)
                {
                    arrForTagFriendAuthorities = currentObj[@"TagFriendAuthorities"];
                }
                
                
                NSString *AuthorityValue = @"";
                
                if (arrForTagFriendAuthorities != nil){
                    
                    for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                        if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                            if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                                AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                            
                            break;
                        }
                    }
                    
                    if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                        commentTextView.editable = YES;
                    } else {
                        commentTextView.editable = NO;
                    }
                    
                } else {
                    
                    if ([arrForTagFriends containsObject:self_user.objectId]){
                        commentTextView.editable = YES;
                    } else {
                        commentTextView.editable = NO;
                    }
                }
                
                if (commentTextView.editable) {
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
                    [query whereKey:@"targetEvent" equalTo:currentObj];
                    [query whereKey:@"Commenter" equalTo:currentUser];
                    [query whereKey:@"Comments" equalTo:_comment];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if ([objects count] == 0 || !objects) {
                            return;
                        }
                        currentCommentObj = objects[0];
                        
                        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (!error) {
                                
                                if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
                                    PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
                                    if (avatarFile) {
                                        [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
                                    }
                                    
                                }
                                else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
                                {
                                    [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
                                }
                                
                                constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:_comment];
                                
                                [commentTextView setText:_comment];
                                [lblForUsername setText:currentUser.username];
                            }
                        }];
                    }];
                }
                
            } else {
                commentTextView.editable = YES;
                
                //[MBProgressHUD showHUDAddedTo:self.superview animated:YES];
                PFQuery *query = [PFQuery queryWithClassName:@"EventComment"];
                [query whereKey:@"targetEvent" equalTo:currentObj];
                [query whereKey:@"Commenter" equalTo:currentUser];
                [query whereKey:@"Comments" equalTo:_comment];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    //[MBProgressHUD hideHUDForView:self.superview animated:YES];
                    if ([objects count] == 0 || !objects) {
                        return;
                    }
                    currentCommentObj = objects[0];
                    
                    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (!error) {
                            
                            
                            if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
                                PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
                                if (avatarFile) {
                                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
                                }
                                
                            }
                            else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
                            {
                                [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
                            }
                            
                            CGFloat height = [OMGlobal heightForCellWithPost:_comment];
                            constraintForCommentHeight.constant = height;
                            [commentTextView setText:_comment];
                            [lblForUsername setText:currentUser.username];
                        }
                    }];
                }];
            }
        }
    }];
}

- (void)configurateCell:(PFObject *)tempObj
{
    
    currentObj = tempObj;
    
    currentUser = currentObj[@"Commenter"];
    
    if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
        }
        
    }
    else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
    }
    
    constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:currentObj[@"Comments"]];
    [commentTextView setText:currentObj[@"Comments"]];
    [lblForUsername setText:currentUser.username];
    
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
    
    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    [lblForTime setText:str_date];
    
}

// for post comment cell
- (void)configCell:(PFObject *)tempObj EventObject:(PFObject *) eventObject commentType:(NSInteger)curType
{
    
    currentType = curType;
    //currentType = kTypePostComment;
    currentObj = tempObj;
    
    arrEventTagFriends = [NSMutableArray array];
    if(eventObject != nil)
    {
        arrEventTagFriends = [eventObject[@"TagFriends"] mutableCopy];
    }
    
    //comment_number = -1;
    event_flag = NO;
    
    currentUser = currentObj[@"Commenter"];
    
    PFUser *self_user = [PFUser currentUser];
    
    if (![currentUser.objectId isEqualToString:self_user.objectId]){
        
        NSMutableArray *arrForTagFriends = [NSMutableArray array];
        NSMutableArray *arrForTagFriendAuthorities = [NSMutableArray array];
        
        if(eventObject[@"TagFriends"] != nil && [eventObject[@"TagFriends"] count] > 0)
        {
            arrForTagFriends = eventObject[@"TagFriends"];
        }
        if(eventObject[@"TagFriendAuthorities"] != nil && [eventObject[@"TagFriendAuthorities"] count] > 0)
        {
            arrForTagFriendAuthorities = eventObject[@"TagFriendAuthorities"];
        }
        
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                        AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    
                    break;
                }
            }
            
            
            if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                commentTextView.editable = YES;
                
            } else {
                commentTextView.editable = NO;
                
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                commentTextView.editable = YES;
                
            } else {
                commentTextView.editable = NO;
            }
        }
        
        commentTextView.editable = NO;
    } else {
        commentTextView.editable = YES;
    }
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            [lblForUsername setText:currentUser.username];
            
            if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
                PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
                }
                
            }
            else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
            }
        }
        
        constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:currentObj[@"Comments"]];
        [commentTextView setText:currentObj[@"Comments"]];
        
        //******************
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
        [lblForTime setText:str_date];
        
    }];
}

- (void)configPostCell:(PFObject *)comObj PostObject:(PFObject*)postObj EventObject:(PFObject *)eventObject CommentType:(NSInteger)curType
{
    currentType = curType;
    //currentType = kTypePostComment;
    
    currentObj = postObj;
    commentObj = comObj;
    
    arrEventTagFriends = [NSMutableArray array];
    if(eventObject != nil)
    {
        arrEventTagFriends = [eventObject[@"TagFriends"] mutableCopy];
    }
    
    //comment_number = -1;
    event_flag = NO;
    
    currentUser = commentObj[@"Commenter"];
    
    PFUser *self_user = [PFUser currentUser];
    
    if (![currentUser.objectId isEqualToString:self_user.objectId]){
        
        NSMutableArray *arrForTagFriends = [NSMutableArray array];
        NSMutableArray *arrForTagFriendAuthorities = [NSMutableArray array];
        
        if(eventObject[@"TagFriends"] != nil && [eventObject[@"TagFriends"] count] > 0)
        {
            arrForTagFriends = eventObject[@"TagFriends"];
        }
        if(eventObject[@"TagFriendAuthorities"] != nil && [eventObject[@"TagFriendAuthorities"] count] > 0)
        {
            arrForTagFriendAuthorities = eventObject[@"TagFriendAuthorities"];
        }
        
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    if([arrForTagFriendAuthorities count] >= [arrForTagFriends count])
                        AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    
                    break;
                }
            }
            
            
            if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                commentTextView.editable = YES;
                
            } else {
                commentTextView.editable = NO;
                
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                commentTextView.editable = YES;
                
            } else {
                commentTextView.editable = NO;
            }
        }
        
        commentTextView.editable = NO;
    } else {
        commentTextView.editable = YES;
    }
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            [lblForUsername setText:currentUser.username];
            
            if ([currentUser[@"loginType"] isEqualToString:@"email"] || [currentUser[@"loginType"] isEqualToString:@"gmail"]) {
                PFFile *avatarFile = (PFFile *)currentUser[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
                }
                
            }
            else if ([currentUser[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:currentUser[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
            }
        }
        
        constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:commentObj[@"Comments"]];
        [commentTextView setText:commentObj[@"Comments"]];
        
        //******************
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        //-----------------------------------------------------------------------
        //NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
        NSString *str_date = [dateFormat stringFromDate:commentObj.createdAt];
        //-----------------------------------------------------------------------
        [lblForTime setText:str_date];
        
    }];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == commentTextView)
    {
        beforeDescription = commentTextView.text;
        
        if ([commentTextView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
            
            
            CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin
                                                             toView:textView.superview.superview.superview.superview];
            
            NSDictionary *userInfo = @{
                                       @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                       @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y+30] stringValue],
                                       @"textFieldHeight": [[NSNumber numberWithFloat:textView.inputAccessoryView.frame.size.height] stringValue]
                                       };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (![beforeDescription isEqualToString:commentTextView.text] && commentTextView.text.length > 0) {
            
            if (event_flag) {
                
                // In Case User comments
                currentCommentObj[@"Comments"] = commentTextView.text;
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                
                tempArray = currentObj[@"commentsArray"];
                [tempArray removeObjectAtIndex:comment_number];
                [tempArray insertObject:commentTextView.text atIndex:comment_number];
                
                [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
                
                [currentCommentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [currentObj setObject:tempArray forKey:@"commentsArray"];
                        
                        [currentObj saveInBackgroundWithBlock:^(BOOL _succeeded, NSError *_error) {
                            [MBProgressHUD hideAllHUDsForView:self.superview animated:YES];
                            
                            if (_succeeded) {
                                NSLog(@"EventCommentCell: Updated the Comments and descriptions");
                                
                                // Let's add badge feature in here.
                                //for badge
                                if(currentType == kTypeEventComment)
                                {
                                    NSMutableArray * arrPostLookedFlags = [NSMutableArray array];
                                    arrPostLookedFlags = [currentObj[@"TagFriends"] mutableCopy];
                                    PFUser *eventUser = currentObj[@"user"];
                                    
                                    if(![eventUser.objectId isEqualToString:USER.objectId])
                                    {
                                        [arrPostLookedFlags addObject:eventUser.objectId];
                                        if ([arrPostLookedFlags containsObject:USER.objectId]) {
                                            [arrPostLookedFlags removeObject:USER.objectId];
                                        }
                                    }
                                    currentObj[@"eventBadgeFlag"] = arrPostLookedFlags;
                                    
                                    OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
                                    if(appDel.network_state)
                                    {
                                        NSLog(@"Badge for description for event of Post Added");
                                        [currentObj saveInBackground];
                                    }
                                    
                                }
                                
                                [commentTextView resignFirstResponder];
                                
                                if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
                                    CGPoint bottomPosition = [textView convertPoint:textView.frame.origin
                                                                             toView:textView.superview.superview.superview.superview];
                                    
                                    NSDictionary *userInfo = @{
                                                               @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                                               @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                                               };
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
                                }
                            } else if (_error) {
                                
                                [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                                [currentCommentObj deleteEventually];
                            }
                        }];
                        
                    } else if (error) {
                        [OMGlobal showAlertTips:error.localizedDescription title:@"Oops!"];
                    }
                    
                }];
            }
            
            // Others comments
            else
            {
                commentObj[@"Comments"] = commentTextView.text;
                [commentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"EventCommentCell: Updated other comments");
                    
                    // Let's add badge feature in here.
                    if (currentType == kTypePostComment)
                    {
                        PFUser *eventUser = currentObj[@"user"];
                        
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
                            [currentObj saveEventually];
                        }
                        
                    }
                }];
                
                [commentTextView resignFirstResponder];
                
                if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
                    CGPoint bottomPosition = [textView convertPoint:textView.frame.origin
                                                             toView:textView.superview.superview.superview.superview];
                    
                    NSDictionary *userInfo = @{
                                               @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                               @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                               };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
                }
            }
        }
        else
        {
            [commentTextView resignFirstResponder];
            
            if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
                CGPoint bottomPosition = [textView convertPoint:textView.frame.origin
                                                         toView:textView.superview.superview.superview.superview];
                
                NSDictionary *userInfo = @{
                                           @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                           @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                           };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
            }
        }
        
        return NO;
    }
    else if (textView.text.length < MAX_COMMENT_LIMIT || [text isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

@end
