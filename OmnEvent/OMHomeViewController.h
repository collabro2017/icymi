//
//  OMViewController.h
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMHomeViewController : OMBaseViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    
    IBOutlet UICollectionView *collectionViewForFeed;
    IBOutlet UITableView *tblForEventFeed;
    
    BOOL is_grid;
    
    PFObject *currentObject;
    
    UIImageView *postImgView;
    BOOL commentLoaded;
}

- (IBAction)newEventPost:(id)sender;

- (IBAction)showTableView:(id)sender;

- (IBAction)showLeftMenu:(id)sender;
@property (nonatomic, retain) UIDocumentInteractionController *dic;

@property (nonatomic, strong) NSMutableArray *arrForFeed;


@end
