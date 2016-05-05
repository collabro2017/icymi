//
//  OMEventCommentViewController.h
//  Collabro
//
//  Created by elance on 8/12/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMEventCommentViewController;

@protocol OMEventCommentViewControllerDelegate <NSObject>

- (void)updateCommentCount:(OMEventCommentViewController *)vc tempObject:(PFObject *)_tempObj;

@end


@interface OMEventCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *tblForComment;
    
    PFUser *currentUser;
    
    IBOutlet UIView *viewForInputBar;
    
    
    
}

@property (nonatomic, strong)    PFObject *currentObject;
@end
