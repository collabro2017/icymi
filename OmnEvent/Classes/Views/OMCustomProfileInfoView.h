//
//  OMCustomProfileInfoView.h
//  Collabro
//
//  Created by Ellisa on 27/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMCustomProfileInfoView : UIView
{
    
    BOOL isFriend;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *imageViewForAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblForUsername;

@property (strong, nonatomic) IBOutlet UILabel *lblForLocation;

@property (strong, nonatomic) IBOutlet UILabel *lblForBio;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForHeight;
@property (strong, nonatomic) IBOutlet UIButton *btnForFriend;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControlForType;


@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFUser *user;



@property (nonatomic, copy) void (^onCompletion)(void);

- (void)setUserInfo:(NSString *)_avatarUrl name:(NSString *)_name location:(NSString *)_location;
- (void)showAddFriendButton:(PFObject *)obj tempArray:(NSMutableArray *)arr;

- (IBAction)changeTypeAction:(id)sender;
- (IBAction)addFriendAction:(id)sender;
- (void)changeButtonState:(BOOL)_bool;
@end
