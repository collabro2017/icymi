//
//  OMCommentViewController.h
//  OmnEvent
//
//  Created by elance on 7/27/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *tblForComment;
    
    PFUser *currentUser;
}

@property (nonatomic, strong)    PFObject *currentObject;


@end
