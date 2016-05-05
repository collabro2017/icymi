//
//  OMCommentCell.m
//  OmnEvent
//
//  Created by elance on 7/27/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMCommentCell.h"
#import "UIImageView+AFNetworking.h"

@implementation OMCommentCell
@synthesize delegate, user,object;

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
    
    [OMGlobal setCircleView:imageViewForProfile borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configurateCell:(PFObject *)tempObj
{
    
    object = tempObj;
    
    user = object[@"Commenter"];
    
    if ([user[@"loginType"] isEqualToString:@"email"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForProfile];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForProfile];
    }
    
    [lblForComment setText:object[@"Comments"]];
    [lblForUsername setText:user.username];
    
}


- (IBAction)showProfileAction:(id)sender {
    
    
    
}
@end
