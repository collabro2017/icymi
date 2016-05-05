//
//  OMOtherProfileViewController.h
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMOtherProfileViewController : UIViewController
{
    
    IBOutlet UITableView *tblForOtherProfile;
    
    IBOutlet UIButton *btnForBack;
    
}
@property (nonatomic, readwrite) NSInteger is_type;
@property (nonatomic, strong) PFUser *targetUser;
@property (nonatomic, readwrite) NSInteger userType;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivateDesc;

- (IBAction)backAction:(id)sender;


@end
