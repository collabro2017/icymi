//
//  OMIndividualEventCell.h
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentProfile : UITableViewCell
{
    
    
    IBOutlet UIButton *btnForAvatar;
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForTime;
    
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ContentProfile *)sharedCell;
@end

@interface ContentPhoto : UITableViewCell
{
    
    
    IBOutlet UIImageView *imageViewForPhoto;
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ContentPhoto *)sharedCell;
@end

@interface ContentLike : UITableViewCell
{
    
    IBOutlet UIButton *btnForLikeLabel;
    
    IBOutlet UIButton *btnForLikeIcon;
    
    IBOutlet UIButton *btnForCommentIcon;
    
    IBOutlet UIButton *btnForCommentLabel;
    
    NSMutableArray *likeUserArray;
    
    int likeCount;
    int commentCount;
    BOOL liked;

}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ContentLike *)sharedCell;


- (IBAction)likeAction:(id)sender;

- (IBAction)commentAction:(id)sender;


@end

@interface ContentText : UITableViewCell
{
    
    
    IBOutlet UILabel *lblForStatus;
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ContentText *)sharedCell;
//- (void)setFrameOfLabel;
@end

