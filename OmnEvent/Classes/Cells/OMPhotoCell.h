//
//  OMPhotoCell.h
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMPhotoCell : UITableViewCell
{
    
    IBOutlet UIButton *btnForLikeIcon;
    
    IBOutlet UIButton *btnForLikeLabel;
    
    
    IBOutlet UIButton *btnForCommentIcon;
    
    IBOutlet UIButton *btnForCommentLabel;
    
    
    IBOutlet UIButton *btnForShareIcon;
    
    IBOutlet UIButton *btnForShareLabel;
    
    IBOutlet UIImageView *imageViewForPhoto;
  
    
    NSMutableArray *likeUserArray;

    int likeCount;
    int commentCount;
    BOOL liked;
    
    PFUser *currentUser;
    
    
}

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;


- (IBAction)likeAction:(id)sender;
- (IBAction)commentAction:(id)sender;

- (IBAction)shareAction:(id)sender;


@end
