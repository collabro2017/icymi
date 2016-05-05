//
//  OMIndividualEventCell.m
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMIndividualEventCell.h"
#define XIB_NAME  @"OMIndividualEventCell"

@implementation ContentProfile
@synthesize object,user,delegate;

+ (ContentProfile *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ContentProfile *cell = [array objectAtIndex:0];
    return cell;

}

- (void)setObject:(PFObject *)_object
{
    
    object = _object;
    user = object[@"user"];
    lblForUsername.text = user.username;
    
    lblForTime.text = [OMGlobal showTime:object.createdAt];
    
    PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
    
    [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:imageViewForAvatar];

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

@implementation ContentPhoto
@synthesize object,user,delegate;

+ (ContentPhoto *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ContentPhoto *cell = [array objectAtIndex:1];
    return cell;
    
}

- (void)setObject:(PFObject *)_object
{
    object = _object;
    
    PFFile *postFile = (PFFile *)object[@"postFile"];
    
    [OMGlobal setImageURLWithAsync:postFile.url positionView:self displayImgView:imageViewForPhoto];

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

@implementation ContentLike
@synthesize object,user,delegate;
+ (ContentLike *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ContentLike *cell = [array objectAtIndex:2];
    return cell;
    
}

- (IBAction)likeAction:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
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

- (void)setObject:(PFObject *)_object
{
    
    object = _object;
    
    PFUser *currentUser = [PFUser currentUser];

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

@implementation ContentText
@synthesize object,user,delegate;
+ (ContentText *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIB_NAME owner:nil options:nil];
    
    ContentText *cell = [array objectAtIndex:3];
    return cell;
    
}

- (void)setObject:(PFObject *)_object
{
    object = _object;
    lblForStatus.text = object[@"description"];
    
    CGRect rect = CGRectMake(10, 5, [OMGlobal getBoundingOfString:lblForStatus.text width:300].width + 10, [OMGlobal getBoundingOfString:lblForStatus.text width:300].height + 10);
    
    [lblForStatus setFrame:rect];
    
    
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
