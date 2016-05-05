//
//  OMAdditionalTagViewController.h
//  Collabro
//
//  Created by XXX on 4/10/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMAdditionalTagViewController;

@protocol OMAdditionalTagViewControllerDelegate <NSObject>

- (void)selectedCells:(OMAdditionalTagViewController *)fsCategoryVC didFinished:(NSMutableArray *)_dict;
- (void)selectDidCancel:(OMAdditionalTagViewController *)fsCategoryVC;

@end
@interface OMAdditionalTagViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *tblForTagFriend;
}

@property (nonatomic, strong)id<OMAdditionalTagViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *currentObject;

@end
