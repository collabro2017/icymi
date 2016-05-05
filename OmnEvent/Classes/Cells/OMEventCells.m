//
//  OMEventCells.m
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMEventCells.h"
#import "UIImageView+AFNetworking.h"




#define XIB_NAME  @"OMEventCells"
@implementation FeedText
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
    [OMGlobal setCircleView:imageViewForAvatar borderColor:[UIColor purpleColor]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showDetailPage:(UITapGestureRecognizer *)_gesture
{
}

+ (FeedText *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    FeedText *cell = [array objectAtIndex:0];
    return cell;
}

- (void)setObject:(PFObject *)_object
{
    object = _object;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [imageViewForAvatar addGestureRecognizer:gesture];

    
    if ([object[@"openStatus"] intValue]) {
        
        lblForStatus.text = @"Opened";
        [lblForStatus setTextColor:[UIColor blueColor]];
        
    }
    else
    {
        lblForStatus.text = @"Closed";
        [lblForStatus setTextColor:[UIColor redColor]];
    }
    
    user = object[@"user"];
    
//    if (![object[@"PostType"] isEqualToString:@"status"]) {
//        [lblForText setHidden:YES];
//    }
    //display image
    PFFile *postImgFile = (PFFile *)object[@"thumbImage"];
    
    if (postImgFile) {
        [imageViewForPost setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }

    //display avatar image
        
    if ([user[@"loginType"] isEqualToString:@"email"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
    }

    //display username
    lblForUsername.text = user.username;
    lblForTime.text = [OMGlobal showTime:object.createdAt];
    lblForText.text = object[@"eventname"];
    if (object[@"openStatus"]) {
        
    }
    else
    {
        lblForLocation.text = @"Closed";
    }
    //display comment count
    
//    
//    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comments"];
//    [commentQuery whereKey:@"postMedia" equalTo:object];
//    [commentQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            [btnForComment setTitle:[NSString stringWithFormat:@"%d Comments",number] forState:UIControlStateNormal];
//        }
//    }];
    
    
    [btnForComment setTitle:[NSString stringWithFormat:@"%ld Comments",(unsigned long)[object[@"commenters"] count]] forState:UIControlStateNormal];

    
    //display like status
    likeCount = [object[@"likers"] count];
    
    likeUserArray = [NSMutableArray array];
    if (object[@"likers"]) {
        [btnForLikeLabe setTitle:[NSString stringWithFormat:@"%ld Likes",likeCount] forState:UIControlStateNormal];
    }else
        [btnForLikeLabe setTitle:@"0 Likes" forState:UIControlStateNormal];
    
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
    
    if (_status) {
        
        liked = YES;
        [btnForLike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];

    }
    else
    {
        liked = NO;
        [btnForLike setBackgroundImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];

    }
}



- (IBAction)tagAction:(id)sender {
    if ([delegate respondsToSelector:@selector(tagPeople:)]) {
        [delegate performSelector:@selector(tagPeople:) withObject:object];
    }

}

- (IBAction)tapPhotoAction:(id)sender {
    
    if ([delegate respondsToSelector:@selector(showDetail:)]) {
        [delegate performSelector:@selector(showDetail:) withObject:object];
    }

}

- (IBAction)likeAction:(id)sender {
    
    NSLog(@"%@",currentUser.objectId);
    
    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        [btnForLikeLabe setTitle:[NSString stringWithFormat:@"%ld Likes",--likeCount] forState:UIControlStateNormal];

        
        [likeUserArray removeObject:currentUser.objectId];
        
        [object setObject:likeUserArray forKey:@"likers"];
        
        [object saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeLabe setTitle:[NSString stringWithFormat:@"%ld Likes",++likeCount] forState:UIControlStateNormal];
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
    if ([self.delegate respondsToSelector:@selector(shareEvent:)]) {
        [self.delegate performSelector:@selector(shareEvent:) withObject:object];
    }

}

- (IBAction)showProfileAction:(id)sender {
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        [delegate performSelector:@selector(showProfile:) withObject:user];
    }

}


@end

@implementation FeedLike
@synthesize object,user,delegate;
+ (FeedLike *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    FeedLike *cell = [array objectAtIndex:1];
    return cell;
    
}

- (IBAction)likeAction:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (liked) {
        
        if (likeCount <= 0) return;
        
        [self setLikeButtonStatus:NO];
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%ld Likes",--likeCount] forState:UIControlStateNormal];
        
        
        [likeUserArray removeObject:currentUser.objectId];
        
        [object setObject:likeUserArray forKey:@"likers"];
        
        [object saveEventually];
    }
    else
    {
        [self setLikeButtonStatus:YES];
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%ld Likes",++likeCount] forState:UIControlStateNormal];
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

- (IBAction)shareAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareEvent:)]) {
        [self.delegate performSelector:@selector(shareEvent:) withObject:object];
    }

}

- (void)setObject:(PFObject *)_object
{
    
    object = _object;
    
    PFUser *currentUser = [PFUser currentUser];
    
    //display comment count
    
    
    [btnForCommentLabel setTitle:[NSString stringWithFormat:@"%lu Comments",(unsigned long)[object[@"commenters"] count]] forState:UIControlStateNormal];
    
    //display like status
    likeCount = [object[@"likers"] count];
    
    likeUserArray = [NSMutableArray array];
    if (object[@"likers"]) {
        [btnForLikeLabel setTitle:[NSString stringWithFormat:@"%ld Likes",(long)likeCount] forState:UIControlStateNormal];
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
        
    if (_status) {
        
        liked = YES;
        [btnForLikeIcon setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];

    }
    else
    {
        liked = NO;
        [btnForLikeIcon setBackgroundImage:[UIImage imageNamed:@"unlike.png"] forState:UIControlStateNormal];

    }
}


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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@implementation FeedComment
@synthesize object,user,delegate;
+ (FeedComment *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    FeedComment *cell = [array objectAtIndex:2];
    return cell;
    
}

- (IBAction)showProfileAction:(id)sender {
}

- (void)setUser:(PFUser *)_user comment:(NSString *)_comment
{
    
    user = _user;
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSLog(@"%@",user.username);
            if ([user[@"loginType"] isEqualToString:@"email"]) {
                PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
                if (avatarFile) {
                    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
                }
                
            }
            else if ([user[@"loginType"] isEqualToString:@"facebook"])
            {
                [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:imageViewForAvatar];
            }
            
            
            //    PFFile *profileImgFile = (PFFile *)user[@"ProfileImage"];
            //
            //    if (profileImgFile) {
            //        [imageViewForProfile setImageWithURL:[NSURL URLWithString:profileImgFile.url] placeholderImage:nil];
            //    }
            //
            [lblForComment setText:_comment];
            
            
            [lblForUsername setText:user.username];

        }
    }];
    
    
}

- (void)setObject:(PFObject *)_object
{
    object = _object;
    
    user = object[@"Commenter"];
    
    
}

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

@end
