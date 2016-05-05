//
//  OMFeedOtherCommentCell.h
//  ICYMI
//
//  Created by lion on 4/25/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFeedOtherCommentCell : UITableViewCell{
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewForProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblForUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblForDes;
@property (strong, nonatomic) IBOutlet UILabel *lblForTime;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForCommentHeight;

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser    *currentUser;

@property (strong, nonatomic) NSString *beforeDescription;

//Event
- (void)setUser:(PFUser *)user comment:(NSString *)_comment curObj:(PFObject *)_obj;

// Comment
- (void)configurateCell:(PFObject *)tempObj;
//Post
- (void)configCell:(PFObject *)tempObj;

@end
