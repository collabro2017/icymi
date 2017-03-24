//
//  OMFriendCell.m
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFriendCell.h"

@implementation OMFriendCell

@synthesize user,delegate,searchMode;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
    ges.numberOfTapsRequired = 1;
    
    [imageViewForAvatar setUserInteractionEnabled:YES];
    
    [imageViewForAvatar addGestureRecognizer:ges];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)animateIndicatorView:(BOOL)_bool
{
    if (_bool) {
        
        [btnForFriendStatus setHidden:YES];
        [indicator startAnimating];
    }
    else
    {
        [indicator stopAnimating];
        [btnForFriendStatus setHidden:NO];

    }
}

- (void)changeButtonState:(BOOL)_bool
{
    
    if (_bool) {
        
        if ([[btnForFriendStatus imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"btn_friend"]]) {
            
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateNormal];
            friendType = 0;
        }
        else
        {
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateNormal];
            
            friendType = 2;
        }
    }
}

- (IBAction)addFriendAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(addFriend:)]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"user"] = user;
        dic[@"friendType"] = [NSNumber numberWithInt:friendType];
        dic[@"index"] = [NSNumber numberWithInteger:index];
        dic[@"cell"] = self;
        dic[@"searchMode"] = [NSNumber numberWithBool:searchMode];
        [delegate performSelector:@selector(addFriend:) withObject:dic];
    }

}
- (void)setCurrentObj:(PFObject *)obj tempFriendArray:(NSMutableArray *)_tempArr tempObjectArray:(NSMutableArray *)_tempObjectArr rowIndex:(NSInteger)_index searchMode:(BOOL)_searchMode
{   
    _currentObj = obj;
    tempArrayFriend = _tempArr;
    user = (PFUser *)_currentObj;
    index = _index;
    searchMode = _searchMode;
    [lblForUsername setText:user.username];
    imageViewForAvatar.image = [UIImage imageNamed:@""];
    
    if (user[@"Location"] != NULL) [lblForLocation setText:user[@"Location"]];
    
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
    }
    
    NSInteger i = 0;
    if ([user.objectId isEqualToString:USER.objectId]) {
        
        [btnForFriendStatus setHidden:YES];

    }
    
    for (PFUser *cUser in tempArrayFriend) {
        
        if ([cUser.objectId isEqualToString:user.objectId]) {
            i ++;
        }
        
    }
    
    if (i > 0) {
        BOOL isFoundFriend = NO;
        
        for(PFObject* obj in _tempObjectArr)
        {
            
            PFUser *fromUser = (PFUser *)[obj objectForKey:@"FromUser"];
            PFUser *toUser = (PFUser *)[obj objectForKey:@"ToUser"];
            
            if ([fromUser.objectId isEqualToString:kIDOfCurrentUser] && [toUser.objectId isEqualToString:user.objectId] )
            {
                isFoundFriend = YES;
                break;
            }
        }
        
        if (isFoundFriend)
        {
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateNormal];
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateSelected];
        
            friendType = 2;
            return;
        }
        else
        {
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addmutalfriend"] forState:UIControlStateNormal];
            [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addmutalfriend"] forState:UIControlStateSelected];
            
            friendType = 1;
            return;
        }
        
    } else
    {
        [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateNormal];
        [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateSelected];
        
        friendType = 0;
        return;
    }
    
}

- (void)setCurrentObj:(PFObject *)obj
{
    _currentObj = obj;
    user = (PFUser *)_currentObj;
    [lblForUsername setText:user.username];
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
    }

    [btnForFriendStatus setHidden:YES];
    
}

- (void)setCurrentObj:(PFObject *)obj ofProfileView:(BOOL)_bool {
    
    _currentObj = obj;
    user = (PFUser *)_currentObj[@"ToUser"];
    searchMode = YES;

    [lblForUsername setText:user.username];
    
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
        }
    } else if ([user[@"loginType"] isEqualToString:@"facebook"]) {
        
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
    }
    
    if ([user.objectId isEqualToString:USER.objectId]) {
        [btnForFriendStatus setHidden:YES];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    
    [query whereKey:@"ToUser" equalTo:user];
    [query whereKey:@"FromUser" equalTo:USER];
    [query includeKey:@"ToUser"];
    [query includeKey:@"FromUser"];
    [self animateIndicatorView:YES];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [self animateIndicatorView:NO];
        if (!error) {
            
            if (objects.count != 0 && objects) {
                
                [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateNormal];
                friendType = 2;

            }
            else
            {
                [btnForFriendStatus setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateNormal];
                friendType = 0;

            }
            
        }
        
    }];


}

- (void)showProfile
{
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"user"] = user;
        dic[@"friendType"] = [NSNumber numberWithInt:friendType];
        [delegate performSelector:@selector(showProfile:) withObject:dic];
    }

}
@end
