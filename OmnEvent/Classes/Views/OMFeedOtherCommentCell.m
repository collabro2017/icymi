//
//  OMFeedOtherCommentCell.m
//  ICYMI
//
//  Created by lion on 4/25/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMFeedOtherCommentCell.h"

@implementation OMFeedOtherCommentCell

- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:_imageViewForProfile borderColor:nil];   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj
{
    [_lblForDes sizeToFit];
    [_lblForTime setHidden:YES];
    _currentUser = user;
    _currentObj = _obj;
    
    [_currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"%@",_currentUser.username);
            if ([_currentUser[@"loginType"] isEqualToString:@"email"]) {
                PFFile *avatarFile = (PFFile *)_currentUser[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:_imageViewForProfile];
                }
                
            }
            else if ([_currentUser[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:_currentUser[@"profileURL"] positionView:self displayImgView:_imageViewForProfile];
            }
            
            _constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:_comment];
            
            [_lblForDes setText:_comment];
            [_lblForUsername setText:_currentUser.username];
        }
    }];
}

- (void)configurateCell:(PFObject *)tempObj
{
    
    _currentObj = tempObj;
    
    _currentUser = _currentObj[@"Commenter"];
    
    if ([_currentUser[@"loginType"] isEqualToString:@"email"]) {
        PFFile *avatarFile = (PFFile *)_currentUser[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:_imageViewForProfile];
        }
        
    }
    else if ([_currentUser[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:_currentUser[@"profileURL"] positionView:self displayImgView:_imageViewForProfile];
    }
    
    
    _constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:_currentObj[@"Comments"]];
    [_lblForDes setText:_currentObj[@"Comments"]];
    [_lblForUsername setText:_currentUser.username];
    //******************
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
    
    NSString *str_date = [dateFormat stringFromDate:_currentObj.createdAt];
    NSLog(@"str_date = %@",str_date);
    [_lblForTime setText:str_date];
    
}

- (void)configCell:(PFObject *)tempObj
{
    _currentObj = tempObj;
    
    _currentUser = _currentObj[@"Commenter"];
    
    [_currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            [_lblForUsername setText:_currentUser.username];
            
            if ([_currentUser[@"loginType"] isEqualToString:@"email"]) {
                PFFile *avatarFile = (PFFile *)_currentUser[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:_imageViewForProfile];
                }
                
            }
            else if ([_currentUser[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:_currentUser[@"profileURL"] positionView:self displayImgView:_imageViewForProfile];
            }
            
        }
        _constraintForCommentHeight.constant = [OMGlobal heightForCellWithPost:_currentObj[@"Comments"]];
        [_lblForDes setText:_currentObj[@"Comments"]];
        //******************
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //    [dateFormat setDateFormat:@"EEE, MMM dd yyyy hh:mm a"];//Wed, Dec 14 2011 1:50 PM
        [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
        
        NSString *str_date = [dateFormat stringFromDate:_currentObj.createdAt];
        NSLog(@"str_date = %@",str_date);
        [_lblForTime setText:str_date];       
        
    }];
}

@end
