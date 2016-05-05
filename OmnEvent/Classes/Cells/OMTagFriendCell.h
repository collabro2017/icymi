//
//  OMTagFriendCell.h
//  Collabro
//
//  Created by elance on 8/11/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMTagFriendCell : UITableViewCell
{
    
    PFUser *currentUser;
    
    IBOutlet UIButton *btnForAvatar;
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UILabel *lblForUsername;
    
}
@property (nonatomic, strong)id delegate;
@property (nonatomic, strong)PFUser *user;
@property (nonatomic, strong)PFObject *object;

- (IBAction)showProfileAction:(id)sender;


@end
