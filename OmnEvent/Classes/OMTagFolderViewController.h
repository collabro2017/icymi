//
//  OMTagFolderViewController.h
//  ICYMI
//
//  Created by Kevin on 8/18/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMTagFolderViewController;

@protocol OMTagFolderViewControllerDelegate <NSObject>

- (void)selectedFolders:(OMTagFolderViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict;
- (void)selectFolderCancel:(OMTagFolderViewController *)fsCategoryVC;

@end

@interface OMTagFolderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSMutableArray *arrForFolder;
    
    IBOutlet UITableView *tblForFolderList;
    

}
@property (nonatomic, strong)id<OMTagFolderViewControllerDelegate> delegate;

@end