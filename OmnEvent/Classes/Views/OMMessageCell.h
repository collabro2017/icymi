//
//  OMMessageCell.h
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMMessageCell : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    IBOutlet UILabel *lblForUsername;
    
    IBOutlet UILabel *lblForTime;
    
    IBOutlet UILabel *lblForMessage;
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;
@end
