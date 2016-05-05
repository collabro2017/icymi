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
@synthesize beforeDescription, currentObj, currentUser, currentCommentObj;

- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:imageViewForProfile borderColor:nil];
    
    lblForDes.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj number:(NSUInteger)_number {
    
    [lblForDes sizeToFit];
    [lblForTime setHidden:YES];
    currentUser = user;
    currentObj = _obj;
    comment_number = _number;
    event_flag = YES;
    
    PFUser *self_user = [PFUser currentUser];
    
    if (![currentUser.objectId isEqualToString:self_user.objectId]){
        
        NSMutableArray *arrForTagFriends = currentObj[@"TagFriends"];
        NSMutableArray *arrForTagFriendAuthorities = currentObj[@"TagFriendAuthorities"];
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    break;
                }
            }
            
            if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                lblForDes.enabled = YES;
            } else {
                lblForDes.enabled = NO;
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                lblForDes.enabled = YES;
            } else {
                lblForDes.enabled = NO;
            }
        }
        
        if (lblForDes.enabled){
            
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
        
        lblForDes.enabled = YES;
        
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
            if ([currentUser[@"loginType"] isEqualToString:@"email"]) {
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

            [lblForDes setText:_comment];
            [lblForUsername setText:currentUser.username];
        }
    }];
}

- (void)newsetUser:(NSString *)user comment:(NSString *)_comment curObj:(PFObject *)_obj
{
    [lblForDes sizeToFit];
    [lblForTime setHidden:YES];
    
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
                
                NSMutableArray *arrForTagFriends = currentObj[@"TagFriends"];
                NSMutableArray *arrForTagFriendAuthorities = currentObj[@"TagFriendAuthorities"];
                
                NSString *AuthorityValue = @"";
                
                if (arrForTagFriendAuthorities != nil){
                    
                    for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                        if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                            AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                            break;
                        }
                    }
                    
                    if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                        lblForDes.enabled = YES;
                    } else {
                        lblForDes.enabled = NO;
                    }
                    
                } else {
                    
                    if ([arrForTagFriends containsObject:self_user.objectId]){
                        lblForDes.enabled = YES;
                    } else {
                        lblForDes.enabled = NO;
                    }
                }
                
                if (lblForDes.enabled){
                    
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
                                NSLog(@"%@",currentUser.username);
                                if ([currentUser[@"loginType"] isEqualToString:@"email"]) {
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
                                
                                [lblForDes setText:_comment];
                                [lblForUsername setText:currentUser.username];
                            }
                        }];
                    }];
                }
                
            } else {
                lblForDes.enabled = YES;
                
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
                            
                            NSLog(@"%@",currentUser.username);
                            if ([currentUser[@"loginType"] isEqualToString:@"email"]) {
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
                            
                            [lblForDes setText:_comment];
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
    
    if ([currentUser[@"loginType"] isEqualToString:@"email"]) {
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
    [lblForDes setText:currentObj[@"Comments"]];
    [lblForUsername setText:currentUser.username];
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
    
    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    NSLog(@"str_date = %@",str_date);
    [lblForTime setText:str_date];
    
}

- (void)configCell:(PFObject *)tempObj EventObject:(PFObject *) eventObject{
    
    currentObj = tempObj;
    //comment_number = -1;
    event_flag = NO;
    
    currentUser = currentObj[@"Commenter"];
    
    PFUser *self_user = [PFUser currentUser];
    
    if (![currentUser.objectId isEqualToString:self_user.objectId]){
        
        NSMutableArray *arrForTagFriends = eventObject[@"TagFriends"];
        NSMutableArray *arrForTagFriendAuthorities = eventObject[@"TagFriendAuthorities"];
        
        NSString *AuthorityValue = @"";
        
        if (arrForTagFriendAuthorities != nil){
            
            for (NSUInteger i = 0 ;i < arrForTagFriends.count; i++) {
                if ([[arrForTagFriends objectAtIndex:i] isEqualToString:self_user.objectId]){
                    AuthorityValue = [arrForTagFriendAuthorities objectAtIndex:i];
                    break;
                }
            }
            
            if ([AuthorityValue isEqualToString:@"Full"] || [AuthorityValue isEqualToString:@"Comment Only"]){
                lblForDes.enabled = YES;
                
            } else {
                lblForDes.enabled = NO;
                
            }
            
        } else {
            
            if ([arrForTagFriends containsObject:self_user.objectId]){
                lblForDes.enabled = YES;
                
            } else {
                lblForDes.enabled = NO;
            }
        }
        
        lblForDes.enabled = NO;
    } else {
        lblForDes.enabled = YES;
    }
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
       
        if (!error) {
            
            [lblForUsername setText:currentUser.username];

            if ([currentUser[@"loginType"] isEqualToString:@"email"]) {
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
        [lblForDes setText:currentObj[@"Comments"]];
        //******************
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        
        NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
        NSLog(@"str_date = %@",str_date);
        [lblForTime setText:str_date];
        
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == lblForDes)
    {
        beforeDescription = lblForDes.text;
        
        if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
            //NSLog(@" UITableView---");
            
            CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];        
            
            NSDictionary *userInfo = @{
                                       @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                       @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y] stringValue],
                                       @"textFieldHeight": [[NSNumber numberWithFloat:textField.inputAccessoryView.frame.size.height] stringValue]
                                       };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
        }
    }   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == lblForDes) {
        
        if (![beforeDescription isEqualToString:lblForDes.text] && lblForDes.text.length > 0){
            
            if (event_flag){
                
                currentCommentObj[@"Comments"] = lblForDes.text;
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                
                tempArray = currentObj[@"commentsArray"];
                [tempArray removeObjectAtIndex:comment_number];
                [tempArray insertObject:lblForDes.text atIndex:comment_number];
                
                [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
                
                [currentCommentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [currentObj setObject:tempArray forKey:@"commentsArray"];
                        
                        [currentObj saveInBackgroundWithBlock:^(BOOL _succeeded, NSError *_error) {
                            [MBProgressHUD hideAllHUDsForView:self.superview animated:YES];
                            
                            if (_succeeded) {
                                NSLog(@"Successful Save");
                                
                                [lblForDes resignFirstResponder];
                                
                                if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
                                    CGPoint bottomPosition = [textField convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
                                    
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
            } else {
                currentObj[@"Comments"] = lblForDes.text;
                [currentObj saveEventually];
                
                [lblForDes resignFirstResponder];
                
                if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
                    CGPoint bottomPosition = [textField convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
                    
                    NSDictionary *userInfo = @{
                                               @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                               @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                               };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
                }
            }
        }
    }
    
    return YES;
}

@end
