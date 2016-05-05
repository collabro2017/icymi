//
//  OMOwnerProfileViewController.h
//  OmnEvent
//
//  Created by elance on 7/25/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMOwnerProfileViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    
   
    IBOutlet UITableView *tblForProfile;
    
    PFUser *currentUser;
    
}
- (IBAction)editAction:(id)sender;

@property (nonatomic, strong) NSMutableArray *arrForProfileInfo;

@end
