//
//  OMCommentCell.h
//  OmnEvent
//
//  Created by elance on 7/27/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMCommentCell : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForProfile;
    
    
    IBOutlet UIButton *btnForProfile;
    
    IBOutlet UILabel *lblForUsername;
    
    
    IBOutlet UILabel *lblForComment;
    
    
}


@property (nonatomic, strong)id delegate;
@property (nonatomic, strong)PFUser *user;
@property (nonatomic, strong)PFObject *object;

- (IBAction)showProfileAction:(id)sender;
- (void)configurateCell:(PFObject *)tempObj;
@end
