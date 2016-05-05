//
//  OMFriendListCell.h
//  Collabro
//
//  Created by elance on 8/14/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFriendListCell : UITableViewCell
{
    
    
    IBOutlet UIButton *btnForAvatar;
    
    IBOutlet UIImageView *imageViewForAvatar;
    IBOutlet UILabel *lblForUsername;
}

- (IBAction)showProfileAction:(id)sender;
@property (nonatomic, strong)id delegate;
@property (nonatomic, strong)PFUser *user;
@property (nonatomic, strong)PFObject *object;

@end
