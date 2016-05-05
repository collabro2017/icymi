//
//  OMLikersViewController.h
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMLikersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    
    
    IBOutlet UITableView *tblForLikers;
    
    
}

@property (nonatomic, strong) PFObject *curObj;
@property (nonatomic, assign) BOOL      isEventMode;

@end
