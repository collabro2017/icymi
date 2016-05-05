//
//  OMFeedHeaderCell.h
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMFeedHeaderCell : UITableViewCell{
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewForProfile;

@property (strong, nonatomic) IBOutlet UILabel *lblForUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblForTime;

@property (strong, nonatomic) IBOutlet UILabel *lblForDes;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForHeight;

@property (strong, nonatomic) IBOutlet UILabel *lblForLocation;



@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;

@end
