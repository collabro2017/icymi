//
//  OMTagFriendCell.m
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMTagFriendCell.h"

@implementation OMTagFriendCell
@synthesize user,object;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setObject:(PFObject *)_object
{
    currentUser = [PFUser currentUser];
    
    object = _object;
    user = (PFUser *)_object;
    [lblForUsername setText:user.username];

//    user = object[@"Commenter"];
    
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

    
    
//    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
//        PFFile *profileImgFile = (PFFile *)object[@"ProfileImage"];
//        
//        if (profileImgFile) {
//            [OMGlobal setImageURLWithAsync:profileImgFile.url positionView:self displayImgView:imageViewForAvatar];
//        }
//
//    }
//    else
//    {
//        [lblForUsername setText:user[@"Name"]];
//    }
//    
    
}

- (IBAction)showProfileAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showProfile:)]) {
        [self.delegate performSelector:@selector(showProfile:) withObject:object];
    }

}
@end
