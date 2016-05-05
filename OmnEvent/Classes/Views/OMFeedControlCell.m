//
//  OMFeedControlCell.m
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFeedControlCell.h"

@implementation OMFeedControlCell
@synthesize user,delegate;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentObj:(PFObject *)obj
{
    _currentObj = obj;
    
    //display comment count
    
    
    if (_currentObj[@"commenters"]) {
        
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"%lu",(unsigned long) [_currentObj[@"commenters"] count]] forState:UIControlStateNormal];

    }
    else
        [btnForCommentCount setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];

    
    
    //display like status
    
    if (_currentObj[@"likers"]) {
        likeCount = [_currentObj[@"likers"] count];

    }
    else
    {
        likeCount = 0;
    }
    
    likeUserArray = [NSMutableArray array];
    
    if (_currentObj[@"likers"]) {
        
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",likeCount] forState:UIControlStateNormal];
    }
    else
        [btnForLikeCount setTitle:@"0" forState:UIControlStateNormal];
    
    if (_currentObj[@"likers"]) {
        [likeUserArray addObjectsFromArray:_currentObj[@"likers"]];
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
        [_currentObj setObject:likeUserArray forKey:@"likers"];
        [_currentObj saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)++likeCount] forState:UIControlStateNormal];
        [likeUserArray addObject:USER.objectId];
        [_currentObj setObject:likeUserArray forKey:@"likers"];
        [_currentObj saveEventually];
    }
}

- (IBAction)showLikersAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showLikers)]) {
        [delegate performSelector:@selector(showLikers) withObject:_currentObj];
    }

}

- (IBAction)commentAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showComments:)]) {
        
        [delegate performSelector:@selector(showComments:) withObject:_currentObj];
    }
}

- (IBAction)showCommentersAction:(id)sender {
}

- (IBAction)moreAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(shareEvent:)]) {
        [delegate performSelector:@selector(shareEvent:) withObject:_currentObj];
    }

}
@end
