//
//  OMProfileBioCell.m
//  Collabro
//
//  Created by Ellisa on 26/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMProfileBioCell.h"

@implementation OMProfileBioCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)currentUser
{
    _user = currentUser;
    
    if ([_user objectForKey:@"Bio"]) {
        
        
        _constraintForHeight.constant = [OMGlobal heightForCellWithPost:[_user objectForKey:@"Bio"]];
        
        [_lblForBio setText:[_user objectForKey:@"Bio"]];

    }
    else
        [_lblForBio setText:kDefaultTextBio];

    
}
@end
