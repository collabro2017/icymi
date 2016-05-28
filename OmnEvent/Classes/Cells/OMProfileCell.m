//
//  OMProfileCell.m
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMProfileCell.h"
#import "UIImageView+AFNetworking.h"


#define XIB_NAME    @"OMProfileCell"

@implementation ProfileHeader
@synthesize delegate,btnForFollow,arrForFollowers;

+ (ProfileHeader *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfileHeader *cell = [array objectAtIndex:0];
    return cell;
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
    
//    _user = [PFUser currentUser];
    
    
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)user
{
    _user = user;
    lblForUsername.text = _user.username;
    //display avatar image
    [OMGlobal setCircleView:imageViewForAvatar borderColor:[UIColor purpleColor]];
    
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

    
//    
//    PFFile *avatarFile = (PFFile *)_user[@"ProfileImage"];
//    if (avatarFile) {
//        [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];
//    }
    
    if ([_user isEqual:[PFUser currentUser]]) {
        [btnForFollow setImage:[UIImage imageNamed:@"edit-info"] forState:UIControlStateNormal];
        [btnForMessage setHidden:YES];
    }
    else
    {
        
        if ([arrForFollowers count] > 0) {
            
            [btnForFollow setImage:[UIImage imageNamed:@"following"] forState:UIControlStateNormal];
            
        }
        else
        {
            [btnForFollow setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
        }
    }
    [btnForMessage setHidden:YES];

}

- (IBAction)followAction:(id)sender {
    
    if ([_user isEqual:[PFUser currentUser]]) {
    
        if ([delegate respondsToSelector:@selector(editProfile:)]) {
            [delegate performSelector:@selector(editProfile:) withObject:[PFUser currentUser]];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(follow:)]) {
            [delegate performSelector:@selector(follow:) withObject:_user];
        }
    }

    
    
}

- (IBAction)messageAction:(id)sender {
}
@end

@implementation ProfileMid

+ (ProfileMid *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfileMid *cell = [array objectAtIndex:1];
    return cell;
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

- (IBAction)infoSelectAction:(id)sender {
    
    
}

- (IBAction)friendSelectAction:(id)sender {
    if (btnForFriend.selected) {
        [btnForFriend setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [btnForFriend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

}

- (IBAction)photoSelectAction:(id)sender {
    if (btnForPhoto.selected) {
        [btnForPhoto setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else
    {
        [btnForPhoto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

}

- (IBAction)postAction:(id)sender {
}
@end

@implementation ProfileMiddle

+ (ProfileMiddle *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfileMiddle *cell = [array objectAtIndex:2];
    return cell;
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
    [btnForEvents setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (IBAction)infoAction:(id)sender {
    if (btnForInfos.selected) {
      
        
    }
    else
    {
        btnForInfos.selected = !btnForInfos.selected;

        [btnForInfos setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnForEvents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnForPhotos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        btnForEvents.selected = NO;
        btnForPhotos.selected = NO;
        
        if ([self.delegate respondsToSelector:@selector(changeType:)]) {
            [self.delegate performSelector:@selector(changeType:) withObject:[NSNumber numberWithInteger:2]];
        }

//        [btnForInfos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

}

- (IBAction)eventAction:(id)sender {

    if (btnForEvents.selected) {
       
    }
    else
    {
        btnForEvents.selected = !btnForEvents.selected;

        [btnForEvents setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [btnForInfos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnForPhotos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        btnForInfos.selected = NO;
        btnForPhotos.selected = NO;
        if ([self.delegate respondsToSelector:@selector(changeType:)]) {
            [self.delegate performSelector:@selector(changeType:) withObject:[NSNumber numberWithInteger:1]];
        }


    }

}

- (IBAction)photoAction:(id)sender {
    

    if (btnForPhotos.selected) {
        
    }
    else
    {
        btnForPhotos.selected = !btnForPhotos.selected;
        [btnForPhotos setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnForInfos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnForEvents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        btnForInfos.selected = NO;
        btnForEvents.selected = NO;
        if ([self.delegate respondsToSelector:@selector(changeType:)]) {
            [self.delegate performSelector:@selector(changeType:) withObject:[NSNumber numberWithInteger:0]];
        }


    }

}
@end


@implementation ProfilePhoto
@synthesize delegate,object,user;

+ (ProfilePhoto *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfilePhoto *cell = [array objectAtIndex:4];
    return cell;
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
- (void)setObject:(PFObject *)_object
{
    currentUser = [PFUser currentUser];

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

@implementation ProfileEvent
@synthesize delegate,object,user;

+ (ProfileEvent *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfileEvent *cell = [array objectAtIndex:5];
    return cell;
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

- (void)setObject:(PFObject *)_object
{

    object = _object;
    
    user = object[@"user"];
    //display image
    PFFile *postImgFile = (PFFile *)object[@"thumbImage"];
    
    if (postImgFile) {
        
        if (imageViewForThumb.image) {
            imageViewForThumb.image = nil;
        }
        [imageViewForThumb setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    lblForEventName.text = object[@"eventname"];
    
    
    lblForTime.text = [OMGlobal showTime:object.createdAt];
    
    
}

@end

@implementation ProfileInfo
@synthesize delegate,object,user;

+ (ProfileInfo *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ProfileInfo *cell = [array objectAtIndex:3];
    return cell;
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

- (void)setUser:(PFUser *)_user
{
    PFUser *currentUser = _user;
    
    lblForEmail.text = currentUser.email;
    lblForUsername.text = currentUser.username;
    if (currentUser[@"FirstName"]) {
        lblForFirstName.text = currentUser[@"FirstName"];

    }
    
    
}
@end


