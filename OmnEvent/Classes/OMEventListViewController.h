//
//  OMEventListViewController.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMEventListViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *tblForEventList;
    
    BOOL is_mosaic;
}


@property (nonatomic, strong) NSMutableArray *arrForEvent;

- (IBAction)createNewEventAction:(id)sender;

@end
