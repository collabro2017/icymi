//
//  OMPhotoViewController.h
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"
@interface OMPhotoViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    
    IBOutlet UITableView *tblForPhoto;
    
    BOOL is_grid;
    
    
}

@property (nonatomic, strong) NSMutableArray *arrForPhoto;


- (IBAction)showTableView:(id)sender;

- (IBAction)newPhotoPostAction:(id)sender;

@end
