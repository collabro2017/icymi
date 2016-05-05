//
//  OMEventListCell.h
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMEventListCell : UITableViewCell
{
    IBOutlet UIImageView *imageViewForThumb;
    IBOutlet UILabel *lblForTime;
    
    IBOutlet UILabel *lblForUsername;
}
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;
@end
