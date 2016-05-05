//
//  OMFeedCommentCell.h
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFeedCommentCell : UITableViewCell<UITextFieldDelegate>
{
    
    IBOutlet UIImageView *imageViewForProfile;
    IBOutlet UILabel *lblForUsername;
    IBOutlet UILabel *lblForTime;
    
    IBOutlet UITextField *lblForDes;
    IBOutlet NSLayoutConstraint *constraintForCommentHeight;
    
}

//@property (strong, nonatomic) IBOutlet UIImageView *imageViewForProfile;
//
//@property (strong, nonatomic) IBOutlet UILabel *lblForUsername;
//
////@property (strong, nonatomic) IBOutlet UILabel *lblForDes;
//
//@property (strong, nonatomic) IBOutlet UITextField *lblForDes;
//
//@property (strong, nonatomic) IBOutlet UILabel *lblForTime;
//
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForCommentHeight;

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFObject *currentCommentObj;

@property (strong, nonatomic) NSString *beforeDescription;

//Event
- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj number:(NSUInteger)_number;

- (void)newsetUser:(NSString *)user comment:(NSString *)_comment curObj:(PFObject *)_obj;

// Comment
- (void)configurateCell:(PFObject *)tempObj;
//Post
- (void)configCell:(PFObject *)tempObj EventObject:(PFObject *) eventObject;

@end
