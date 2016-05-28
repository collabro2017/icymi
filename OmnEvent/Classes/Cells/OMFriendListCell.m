//
//  OMFriendListCell.m
//  Collabro
//
//  Created by elance on 8/14/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMFriendListCell.h"

@implementation OMFriendListCell
@synthesize object,delegate,user;

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
    user = (PFUser *)_object;
    [lblForUsername setText:user.username];

    
//    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
//        PFFile *profileImgFile = (PFFile *)user[@"ProfileImage"];
//        
//        if (profileImgFile) {
//            [OMGlobal setImageURLWithAsync:profileImgFile.url positionView:self displayImgView:imageViewForAvatar];
//        }
//        [lblForUsername setText:user.username];
//        
//    }
//    else
//    {
//        [lblForUsername setText:user[@"Name"]];
//    }
    
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

}


- (IBAction)showProfileAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        [delegate performSelector:@selector(showProfile:) withObject:user];
    }
}
@end
