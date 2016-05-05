//
//  OMEventCell.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMEventCell.h"
#import "UIImageView+AFNetworking.h"

@implementation OMEventCell
@synthesize _user,_object;

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
    
    [super awakeFromNib];
    
    currentUser = [PFUser currentUser];
    [OMGlobal setCircleView:imageViewForAvatar borderColor:[UIColor purpleColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)newsAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(noticeNewPost:)]) {
        [self.delegate performSelector:@selector(noticeNewPost:) withObject:_object];
    }
}

- (IBAction)listAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showEventList:)]) {
        [self.delegate performSelector:@selector(showEventList:) withObject:_object];
    }

}

- (IBAction)newPostAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(newEventPost:)]) {
        [self.delegate performSelector:@selector(newEventPost:) withObject:_object];
    }
}

- (IBAction)tagAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(tagFriend:)]) {
        [self.delegate performSelector:@selector(tagFriend:) withObject:_object];
    }

}

- (void)configurationCell:(PFObject *)_tempObject
{
    _object = _tempObject;
    _user = _object[@"user"];
    
    
   
    //display image
    PFFile *postImgFile = (PFFile *)_object[@"image"];
    
    if (postImgFile) {
        [imageViewForFeed setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    //display avatar image
    
    PFFile *avatarFile = (PFFile *)_object[@"ProfileImage"];
    
    if (avatarFile) {
        [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
    }
    //display username
    lblForUsername.text = _user.username;
    
    //display description & event name
    
    lblForDescription.text = _object[@"description"];
    lblForEventName.text = _object[@"EventName"];
    
    
    //display comment count
    
    
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentQuery whereKey:@"postMedia" equalTo:_object];
    [commentQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            lblForComment.text = [NSString stringWithFormat:@"%d comments",number];
        }
    }];
    
    //display like status
    likeCount = [_object[@"likers"] count];

    likeUserArray = [NSMutableArray array];
    if (_object[@"likers"]) {
        lblForLike.text = [NSString stringWithFormat:@"%d likes",likeCount];
    }else
        lblForLike.text = @"0 likes";

    if (_object[@"likers"]) {
        [likeUserArray addObjectsFromArray:_object[@"likers"]];
    }
    if ([likeUserArray containsObject:currentUser.objectId]) {
        liked = YES;
    }
    else
    {
        liked = NO;
    }
    [self setLikeButtonStatus:liked];

  //    commentCount = [_object [@""] count];
    
}

- (IBAction)likeAction:(id)sender {
    NSLog(@"%@",currentUser.objectId);

    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        lblForLike.text = [NSString stringWithFormat:@"%d likes",--likeCount];
        
        
        [likeUserArray removeObject:currentUser.objectId];
        
        [_object setObject:likeUserArray forKey:@"likers"];
        
        [_object saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        lblForLike.text = [NSString stringWithFormat:@"%d likes",++likeCount];
        [likeUserArray addObject:currentUser.objectId];
        [_object setObject:likeUserArray forKey:@"likers"];
        [_object saveEventually];
    }
    
}

- (IBAction)commentAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showComments:)]) {
        [self.delegate performSelector:@selector(showComments:) withObject:_object];
    }
}

- (IBAction)shareAction:(id)sender {
}

- (void)setLikeButtonStatus:(BOOL) _status
{
    switch (_status) {
        case YES:
        {
            liked = YES;
            [btnForLike setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        
        }
            break;
        case NO:
        {
            liked = NO;
            [btnForLike setImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

@end
