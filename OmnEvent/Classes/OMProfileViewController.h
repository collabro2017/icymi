//
//  OMProfileViewController.h
//  OmnEvent
//
//  Created by elance on 8/3/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMProfileViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrForProfileInfo;

    NSMutableArray *arrForFollowers;
    NSMutableArray *arrForFollowings;
    
    IBOutlet UITableView *tblForProfile;
     PFUser *currentUser;
    
}
@property (nonatomic,readwrite) NSInteger is_type;
@property (nonatomic, strong) PFUser *targetUser;
@end
