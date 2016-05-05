//
//  OMProfileBioCell.h
//  Collabro
//
//  Created by Ellisa on 26/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMProfileBioCell : UITableViewCell
{
    

}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForHeight;
@property (strong, nonatomic) IBOutlet UILabel *lblForBio;


@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;
@end
