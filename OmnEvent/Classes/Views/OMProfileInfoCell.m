//
//  OMProfileInfoCell.m
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMProfileInfoCell.h"

@implementation OMProfileInfoCell
@synthesize user;
- (void)awakeFromNib {
    // Initialization code
    
    for (UIView *view  in viewArray) {
        
        [OMGlobal setRoundView:view cornorRadius:5.0f borderColor:nil borderWidth:0];

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(PFUser *)_user
{
    user = _user;
    
    if (user[@"Age"]) {
        lblForAgeValue.text = user[@"Age"];

    }
    if (user[@"email"]) {
        lblForEmailValue.text = user[@"email"];
    }
    if (user[@"company"]) {
        lblCompanyValue.text = user[@"company"];
        
    }
    if (user[@"Gender"]) {
        lblForAgeTitle.text = user[@"Gender"];
        
    }
    if (user[@"City"]) {
        lblForCityValue.text = user[@"City"];
        
    }
    if (user[@"State"]) {
        lblForStateValue.text = user[@"State"];
        
    }
    if (user[@"zipcode"]) {
        lblForPostalValue.text = user[@"zipcode"];
        
    }
    if (user[@"phone"]) {
        lblForPhoneValue.text = user[@"phone"];
        
    }

    if (user[@"country"]) {
        lblForCountryValue.text = user[@"country"];
        
    }

    
}

@end
