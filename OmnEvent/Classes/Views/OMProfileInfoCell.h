//
//  OMProfileInfoCell.h
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMProfileInfoCell : UITableViewCell
{
    
    
    IBOutlet UIView *viewForBack;
    
    
    
    IBOutletCollection(UIView) NSArray *viewArray;
    
    IBOutlet UILabel *lblForGenderTitle;
    
    IBOutlet UILabel *lblForGenderValue;
    
    IBOutlet UILabel *lblForAgeTitle;
    IBOutlet UILabel *lblForAgeValue;
    
    
    IBOutlet UILabel *lblForCityTitle;
    
    IBOutlet UILabel *lblForCityValue;
    
    IBOutlet UILabel *lblForState;
    
    
    IBOutlet UILabel *lblForStateValue;
    
    IBOutlet UILabel *lblForPostal;
    
    IBOutlet UILabel *lblForPostalValue;
    
    
    IBOutlet UILabel *lblForEmail;
    
    IBOutlet UILabel *lblForEmailValue;
    
    
    
    
    IBOutlet UILabel *lblForPhone;
    
    IBOutlet UILabel *lblForPhoneValue;
    
    
    
    
    IBOutlet UILabel *lblForCountry;
    
    IBOutlet UILabel *lblForCountryValue;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) PFUser *user;

@end
