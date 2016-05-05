//
//  OMDetailHeaderCell.m
//  Collabro
//
//  Created by XXX on 4/4/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMDetailHeaderCell.h"

@implementation OMDetailHeaderCell
@synthesize user,delegate;
- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [imageViewForAvatar addGestureRecognizer:gesture];

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

- (void)setCurrentObj:(PFObject *)obj
{
    
    _currentObj = obj;
    
    user = _currentObj[@"user"];
    
    //Display avatar image
    if (imageViewForAvatar.image) {
        imageViewForAvatar.image = nil;
    }
    
    if ([user[@"loginType"] isEqualToString:@"email"]) {
        
        
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        
        if (avatarFile) {
            
            [imageViewForAvatar setImageWithURL:[NSURL URLWithString:avatarFile.url]];
            
        }
        
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        
        [imageViewForAvatar setImageWithURL:[NSURL URLWithString:user[@"profileURL"]]];
    }
    
    //display Username
    
    [lblForUsername setText:user.username];
    
    //    [_lblForTime setText:[OMGlobal showTime:_currentObj.createdAt]];
    //    _constraintForHeight.constant = [OMGlobal heightForCellWithPost:_currentObj[@"description"]];
    //    [_lblForDes setText:_currentObj[@"description"]];
    
    //    if (_currentObj[@"country"]) {
    //
    //        [_lblForLocation setText:_currentObj[@"country"]];
    //    }
    //    else
    //        [_lblForLocation setText:@"Unknown"];
    
    
    if (imageViewForPost.image) {
        
        imageViewForPost.image = nil;
    }
    
    PFFile *postImgFile = (PFFile *)_currentObj[@"thumbImage"];
    if (postImgFile) {
        
        [imageViewForPost setImageWithURL:[NSURL URLWithString:postImgFile.url]];
    }
    //
    
    
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
    likerArr = [NSMutableArray array];

    likeUserArray = [NSMutableArray array];
    
    if (_currentObj[@"likers"]) {
        
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",likeCount] forState:UIControlStateNormal];
        
    }
    else
        [btnForLikeCount setTitle:@"0" forState:UIControlStateNormal];
    
    if (_currentObj[@"likers"]) {
        [likeUserArray addObjectsFromArray:_currentObj[@"likers"]];
        [likerArr addObjectsFromArray:_currentObj[@"likeUserArray"]];

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
        [likerArr removeObject:USER];
        [_currentObj setObject:likerArr forKey:@"likeUserArray"];
        [_currentObj setObject:likeUserArray forKey:@"likers"];
        [_currentObj saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)++likeCount] forState:UIControlStateNormal];
        [likeUserArray addObject:USER.objectId];
        [likerArr addObject:USER];

        [_currentObj setObject:likeUserArray forKey:@"likers"];
        [_currentObj setObject:likerArr forKey:@"likeUserArray"];
        [_currentObj saveEventually];
    }
}

- (IBAction)showLikersAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showLikersOfEvent:)]) {
        [delegate performSelector:@selector(showLikersOfEvent:) withObject:_currentObj];
    }

}

- (IBAction)commentAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showEventComments:)]) {
        
        [delegate performSelector:@selector(showEventComments:) withObject:_currentObj];
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
