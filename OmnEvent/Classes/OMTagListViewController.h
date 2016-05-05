//
//  OMTagListViewController.h
//  OmnEvent
//
//  Created by elance on 8/1/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMTagListViewController;

@protocol OMTagListViewControllerDelegate <NSObject>

- (void)selectedCells:(OMTagListViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict;
- (void)selectDidCancel:(OMTagListViewController *)fsCategoryVC;

@end

@interface OMTagListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSMutableArray *arrForFriend;
    
    
    
    IBOutlet UITableView *tblForFriendList;
    
    
    
    
}
@property (nonatomic, strong)id<OMTagListViewControllerDelegate> delegate;

@end
