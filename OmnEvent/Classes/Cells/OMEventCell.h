//
//  OMEventCell.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMSocialFeed.h"

@interface OMEventCell : UITableViewCell
{
    
    IBOutlet UILabel *lblForEventName;
    IBOutlet UIButton *btnForNews;
    
    IBOutlet UIButton *btnForEventList;
    
    IBOutlet UIButton *btnForNewEvent;
    
    IBOutlet UIButton *btnForTagPeople;
    
    IBOutlet UILabel *lblForDescription;
    
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForTime;
    IBOutlet UIImageView *imageViewForFeed;
    
    IBOutlet UILabel *lblForLike;
    
    IBOutlet UILabel *lblForComment;
    
    IBOutlet UIImageView *imageViewForAvatar;
    BOOL liked;
    
    
    IBOutlet UIButton *btnForLike;
    
    
    NSMutableArray *likeUserArray;
    
    int likeCount;
    int commentCount;
    
    PFUser *currentUser;
    
}

- (IBAction)newsAction:(id)sender;
- (IBAction)listAction:(id)sender;
- (IBAction)newPostAction:(id)sender;

- (IBAction)tagAction:(id)sender;

- (void)configurationCell:(PFObject *)_tempObject;

- (IBAction)likeAction:(id)sender;

- (IBAction)commentAction:(id)sender;

- (IBAction)shareAction:(id)sender;

//+ (OMEventCell *)sharedCell;

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) OMSocialFeed *feed;

@property (nonatomic, strong) PFUser *_user;
@property (nonatomic, strong) PFObject *_object;

@end
