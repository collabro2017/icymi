//
//  OMFriendListViewController.h
//  Collabro
//
//  Created by elance on 8/13/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMFriendListViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    
    IBOutlet UITableView *tblForFriends;
    
    NSMutableArray *arrForFriend;
    
    BOOL is_grid;
    
}

- (IBAction)changeAction:(id)sender;


@end
