//
//  OMSearchCell.h
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMSocialEvent;
@interface OMSearchCell : UICollectionViewCell {
    
    IBOutlet UIImageView *imageViewForBG;
    
    IBOutlet UILabel *lblForTitle;
    IBOutlet UILabel *lblForUsername;
    IBOutlet UILabel *lblDateTime;
    
    IBOutlet UILabel *lblForNewEvent;
    IBOutlet UILabel *lblForBadge;
    IBOutlet UIButton *btnForVideo;
    IBOutlet UIActivityIndicatorView    *activityIndicator;
}

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) OMSocialEvent *currentObj;
@property (strong, nonatomic) PFUser   *user;


@end
