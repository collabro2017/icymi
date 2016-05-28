//
//  OMCustomProfileInfoView.m
//  Collabro
//
//  Created by Ellisa on 27/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMCustomProfileInfoView.h"
#import "OMOtherProfileViewController.h"

@implementation OMCustomProfileInfoView
@synthesize delegate,user;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [OMGlobal setCircleView:_imageViewForAvatar borderColor:[UIColor whiteColor]];
}

- (void)setUserInfo:(NSString *)_avatarUrl name:(NSString *)_name location:(NSString *)_location
{
    
}

- (IBAction)changeTypeAction:(id)sender {
    
    NSInteger index = ((UISegmentedControl *)sender).selectedSegmentIndex;
    if ([delegate respondsToSelector:@selector(changeType:)]) {
        
        [delegate performSelector:@selector(changeType:) withObject:[NSNumber numberWithInteger:index]];
    }
}

- (IBAction)addFriendAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(addFriendMainUser:)]) {
        
        [delegate performSelector:@selector(addFriendMainUser:) withObject:[NSNumber numberWithBool:isFriend]];
    }

}

- (void)setUser:(PFUser *)currentUser
{
    user =  currentUser;
    
    if ([user.objectId isEqualToString:USER.objectId]) {
        
        [_segmentControlForType setTitle:@"Info" forSegmentAtIndex:1];
        
    }
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            
            [_imageViewForAvatar setImageWithURL:[NSURL URLWithString:avatarFile.url] placeholderImage:nil];
        
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
      
        [_imageViewForAvatar setImageWithURL:[NSURL URLWithString:user[@"profileURL"]] placeholderImage:nil];
    }

    _lblForUsername.text = user.username;
    
    if ([user objectForKey:@"City"]) {
        
        _lblForLocation.text = [user objectForKey:@"City"];

    }
    else
        _lblForLocation.text = @"Unknown";
    
    
    
    if ([user.objectId isEqualToString:USER.objectId]) {
        
        [_btnForFriend setHidden:YES];
        
    }
    else
    {
        NSInteger nType = [(OMOtherProfileViewController*)[self delegate] userType];
        
        if (nType == 2)
        {
            [_btnForFriend setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateNormal];
            isFriend = YES;
        }
        else if (nType == 1)
        {
            [_btnForFriend setImage:[UIImage imageNamed:@"btn_addmutalfriend"] forState:UIControlStateNormal];
            isFriend = NO;
            
        }
        else
        {
            [_btnForFriend setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateNormal];
            isFriend = NO;
        }
    }
    
    
}

- (void)showAddFriendButton:(PFObject *)obj tempArray:(NSMutableArray *)arr
{
    
}

- (void)changeButtonState:(BOOL)_bool
{
    
    if (_bool) {
        
        if ([[_btnForFriend imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"btn_friend"]]) {
            
            [_btnForFriend setImage:[UIImage imageNamed:@"btn_addfriend"] forState:UIControlStateNormal];
            isFriend = NO;
        }
        else
        {
            [_btnForFriend setImage:[UIImage imageNamed:@"btn_friend"] forState:UIControlStateNormal];
            
            isFriend = YES;
        }
        
        
    }
}

@end
