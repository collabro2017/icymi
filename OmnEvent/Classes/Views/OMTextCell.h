//
//  OMTextCell.h
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMTextCell : UITableViewCell<UITextFieldDelegate, UITextViewDelegate>
{   
    
    IBOutlet UILabel *lblForUsername;
    
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    
    IBOutlet UILabel *lblForTime;
    
    //IBOutlet UILabel *lblForDes;
    
    //IBOutlet UILabel *lblForTitle;
    
    //IBOutlet UITextField *lblForTitle;
    
    //IBOutlet UITextField *lblForDes;
    
    //IBOutlet NSLayoutConstraint *constraintForHeight;
    //
    
    
    IBOutlet UITextView *lblForTitle;
    
    IBOutlet NSLayoutConstraint *constraintForTitleHeight;
    
    
    IBOutlet UITextView *lblForDes;
    
    IBOutlet NSLayoutConstraint *constraintForHeight;
    
    IBOutlet UIView *viewForControl;
    
    
    IBOutlet UIButton *btnForLike;
    
    IBOutlet UIButton *btnForLikeCount;
    
    
    IBOutlet UIButton *btnForComment;
    
    IBOutlet UIButton *btnForCommentCount;
    
    
    IBOutlet UIButton *btnForMore;
    
    NSMutableArray *likeUserArray;
    
    NSInteger likeCount;
    NSInteger commentCount;
    BOOL liked;
    
}
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;

@property (strong, nonatomic) NSString *beforeTitle;
@property (strong, nonatomic) NSString *beforeDescription;


- (IBAction)likeAction:(id)sender;
- (IBAction)showLikersAction:(id)sender;

- (IBAction)commentAction:(id)sender;

- (IBAction)showCommentersAction:(id)sender;

- (IBAction)moreAction:(id)sender;
@end
