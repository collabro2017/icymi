//
//  OMPhotoCell.m
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMPhotoCell.h"
#import "UIImageView+AFNetworking.h"

@implementation OMPhotoCell
@synthesize delegate,object,user;

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
      currentUser = [PFUser currentUser];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setObject:(PFObject *)_object
{
    object = _object;
    
    user = object[@"user"];
    //display image
    PFFile *postImgFile = (PFFile *)object[@"image"];
    
    if (postImgFile) {
        [imageViewForPhoto setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    
//    //display avatar image
//    
//    PFFile *avatarFile = (PFFile *)object[@"ProfileImage"];
//    
//    if (avatarFile) {
//        [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
//    }
    
//    //display username
//    lblForUsername.text = user.username;
    
    //display comment count
    
    
    [btnForCommentLabel setTitle:[NSString stringWithFormat:@"%d Comments",[object[@"commentsUsers"] count]] forState:UIControlStateNormal];

    //display like status
    likeCount = [object[@"likers"] count];
    
    likeUserArray = [NSMutableArray array];
    if (object[@"likers"]) {
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%d Likes",likeCount] forState:UIControlStateNormal];
    }else
        [btnForLikeLabel setTitle:@"0 Likes" forState:UIControlStateNormal];
    
    if (object[@"likers"]) {
        [likeUserArray addObjectsFromArray:object[@"likers"]];
    }
    if ([likeUserArray containsObject:currentUser.objectId]) {
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
    switch (_status) {
        case YES:
        {
            liked = YES;
            [btnForLikeIcon setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
            
        }
            break;
        case NO:
        {
            liked = NO;
            [btnForLikeIcon setBackgroundImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}



- (IBAction)likeAction:(id)sender {

    NSLog(@"%@",currentUser.objectId);
    
    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%d Likes",--likeCount] forState:UIControlStateNormal];
        
        
        [likeUserArray removeObject:currentUser.objectId];
        
        [object setObject:likeUserArray forKey:@"likers"];
        
        [object saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%d Likes",++likeCount] forState:UIControlStateNormal];
        [likeUserArray addObject:currentUser.objectId];
        [object setObject:likeUserArray forKey:@"likers"];
        [object saveEventually];
    }



}

- (IBAction)commentAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showComments:)]) {
        [self.delegate performSelector:@selector(showComments:) withObject:object];
    }

}

- (IBAction)shareAction:(id)sender {
}
@end
