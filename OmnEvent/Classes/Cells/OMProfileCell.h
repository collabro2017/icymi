//
//  OMProfileCell.h
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeader : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UIButton *btnForMessage;
    
}
@property (nonatomic, strong) NSMutableArray *arrForFollowers;

@property (strong, nonatomic) IBOutlet UIButton *btnForFollow;

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfileHeader *)sharedCell;

- (IBAction)followAction:(id)sender;
- (IBAction)messageAction:(id)sender;



@end

@interface ProfileMid : UITableViewCell
{
    
    IBOutlet UIButton *btnForInfo;
    
    IBOutlet UIButton *btnForFriend;
    
    IBOutlet UIButton *btnForPhoto;
    
    
    IBOutlet UIImageView *imageViewForWrite;
    
    
    IBOutlet UILabel *lblForPlaceholder;
    
    IBOutlet UITextView *txtForStatus;
    
    IBOutlet UIButton *btnForPost;
    
    
    
}

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfileMid *)sharedCell;

- (IBAction)infoSelectAction:(id)sender;

- (IBAction)friendSelectAction:(id)sender;

- (IBAction)photoSelectAction:(id)sender;

- (IBAction)postAction:(id)sender;


@end

@interface ProfileMiddle : UITableViewCell
{
    
    IBOutlet UIButton *btnForInfos;
    
    IBOutlet UIButton *btnForEvents;
    
    IBOutlet UIButton *btnForPhotos;
}


@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfileMiddle *)sharedCell;

- (IBAction)infoAction:(id)sender;
- (IBAction)eventAction:(id)sender;

- (IBAction)photoAction:(id)sender;



@end

@interface ProfilePhoto : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForPhoto;
    
    IBOutlet UIButton *btnForLikeIcon;
    
    IBOutlet UIButton *btnForLikeLabel;
    
    
    IBOutlet UIButton *btnForCommentIcon;
    
    IBOutlet UIButton *btnForCommentLabel;
    
    
    IBOutlet UIButton *btnForShareIcon;
    
    IBOutlet UIButton *btnForShareLabel;
    NSMutableArray *likeUserArray;
    
    int likeCount;
    int commentCount;
    BOOL liked;
    
    PFUser *currentUser;

    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfilePhoto *)sharedCell;

- (IBAction)likeAction:(id)sender;
- (IBAction)commentAction:(id)sender;
- (IBAction)shareAction:(id)sender;




@end

@interface ProfileEvent : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForThumb;
    IBOutlet UILabel *lblForEventName;
    
    
    IBOutlet UILabel *lblForTime;
    
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfileEvent *)sharedCell;


@end

@interface ProfileInfo : UITableViewCell
{
    
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForEmail;
    
    IBOutlet UILabel *lblForFirstName;
    
    IBOutlet UILabel *lblForLastName;
    
    IBOutlet UILabel *lblForGender;
    
    
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
+ (ProfileInfo *)sharedCell;


@end