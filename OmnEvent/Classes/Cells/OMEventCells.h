//
//  OMEventCells.h
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedText : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForLocation;
    
    IBOutlet UILabel *lblForTime;
    
    IBOutlet UILabel *lblForText;
    IBOutlet UIImageView *imageViewForPost;
    
   //like
    IBOutlet UIButton *btnForLikeLabe;
    
    IBOutlet UIButton *btnForLike;
    
    
    IBOutlet UIButton *btnForComment;
    
    IBOutlet UIButton *btnForCommentImage;
    IBOutlet UIButton *btnForShare;
    
    IBOutlet UIButton *btnForShareIcon;
    
    NSMutableArray *likeUserArray;
    
    NSInteger likeCount;
    NSInteger commentCount;
    BOOL liked;

    PFUser *currentUser;
    
    IBOutlet UILabel *lblForStatus;
    
}

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;


- (IBAction)tagAction:(id)sender;

- (IBAction)tapPhotoAction:(id)sender;

- (IBAction)likeAction:(id)sender;

- (IBAction)commentAction:(id)sender;

- (IBAction)shareAction:(id)sender;
- (IBAction)showProfileAction:(id)sender;


- (void)configurateItems:(PFObject *)_tempObject;
+ (FeedText *)sharedCell;

@end


@interface FeedLike : UITableViewCell
{
    
    IBOutlet UIButton *btnForLikeLabel;
    
    IBOutlet UIButton *btnForLikeIcon;
    
    IBOutlet UIButton *btnForCommentIcon;
    
    IBOutlet UIButton *btnForCommentLabel;
    IBOutlet UIButton *btnForShareLabel;
    
    IBOutlet UIButton *btnForShareIcon;
    NSMutableArray *likeUserArray;
    
    NSInteger likeCount;
    NSInteger commentCount;
    BOOL liked;
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (FeedLike *)sharedCell;


- (IBAction)likeAction:(id)sender;

- (IBAction)commentAction:(id)sender;

- (IBAction)shareAction:(id)sender;

@end

@interface FeedComment : UITableViewCell
{
    
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UIButton *btnForAvatar;
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForComment;
    
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (FeedComment *)sharedCell;

- (IBAction)showProfileAction:(id)sender;
- (void)setUser:(PFUser *)user comment:(NSString *)_comment;

@end



