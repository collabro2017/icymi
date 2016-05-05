//
//  OMFriendCell.h
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMFriendCell;
@interface OMFriendCell : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    IBOutlet UILabel *lblForUsername;
    IBOutlet UILabel *lblForLocation;
    
    IBOutlet UIButton *btnForFriendStatus;
    
    IBOutlet UIActivityIndicatorView *indicator;
    NSMutableArray *tempArrayFriend;
    
    int friendType; // BOOL isFriend;
    NSInteger index;
}

@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;
@property (strong, nonatomic) id delegate;
@property (nonatomic, assign) BOOL searchMode;

- (void)setCurrentObj:(PFObject *)obj tempFriendArray:(NSMutableArray *)_tempArr tempObjectArray:(NSMutableArray *)_tempObjectArr rowIndex:(NSInteger)_index searchMode:(BOOL)_searchMode;
- (void)setCurrentObj:(PFObject *)obj ofProfileView:(BOOL)_bool;


- (IBAction)addFriendAction:(id)sender;

- (void)animateIndicatorView:(BOOL)_bool;
- (void)changeButtonState:(BOOL)_bool;
@end
