//
//  OMFeedControlCell.h
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFeedControlCell : UITableViewCell{
    
    NSMutableArray *likeUserArray;
    
    NSInteger likeCount;
    NSInteger commentCount;
    BOOL liked;
    
    IBOutlet UIButton *btnForLike;
    IBOutlet UIButton *btnForLikeCount;
    
    IBOutlet UIButton *btnForComment;
    
    IBOutlet UIButton *btnForCommentCount;
    IBOutlet UIButton *btnForMore;

    
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;

- (IBAction)likeAction:(id)sender;

- (IBAction)showLikersAction:(id)sender;

- (IBAction)commentAction:(id)sender;
- (IBAction)showCommentersAction:(id)sender;

- (IBAction)moreAction:(id)sender;

@end
