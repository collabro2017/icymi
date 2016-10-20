//
//  OMFeedCommentCell.h
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFeedCommentCell : UITableViewCell<UITextViewDelegate>
{
    
    IBOutlet UIImageView *imageViewForProfile;
    IBOutlet UILabel *lblForUsername;
    IBOutlet UILabel *lblForTime;
    
    IBOutlet UITextView *commentTextView;
    IBOutlet NSLayoutConstraint *constraintForCommentHeight;
    
    NSInteger currentType;
    NSMutableArray *arrEventTagFriends;
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFObject *commentObj;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFObject *currentCommentObj;

@property (strong, nonatomic) NSString *beforeDescription;

//Event
- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj number:(NSUInteger)_number;

- (void)newsetUser:(NSString *)user comment:(NSString *)_comment curObj:(PFObject *)_obj
       commentType:(NSInteger)curType number:(NSUInteger)_number;
// Comment
- (void)configurateCell:(PFObject *)tempObj;
//Post
- (void)configCell:(PFObject *)tempObj EventObject:(PFObject *) eventObject commentType:(NSInteger)curType;

// newly

- (void)configPostCell:(PFObject *)comObj PostObject:(PFObject*) postObj EventObject:(PFObject *) eventObject CommentType:(NSInteger)curType;

@end
