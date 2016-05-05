//
//  OMAddFriendViewController.h
//  OmnEvent
//
//  Created by elance on 7/23/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMAddFriendViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITextField *txtForEmail;
    
    IBOutlet UITextField *txtForSms;
    
    IBOutlet UITableView *tblForFriends;
    
    
}
@property (nonatomic, strong) NSMutableArray *arrForFriends;
@end
