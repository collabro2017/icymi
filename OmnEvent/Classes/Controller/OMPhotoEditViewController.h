//
//  OMPhotoEditViewController.h
//  Collabro
//
//  Created by Ellisa on 29/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMPhotoEditViewController : UIViewController
{
    //Top Bar
    
    IBOutlet UIView *viewForTopBar;
    
    IBOutlet UIButton *btnForBack;
    
    IBOutlet UIButton *btnForNext;
    
    IBOutlet UILabel *lblForTitle;
    
    
    
    //Preview
    
    IBOutlet UIView *viewForPreview;
    
    IBOutlet UIImageView *imageViewForPreview;
    // Bottom View
    
    
    IBOutlet UIView *viewForBottom;
    
    IBOutlet UIView *viewForControl;
    
    IBOutlet UIScrollView *scrollViewForFilters;
    
    
}

- (IBAction)backAction:(id)sender;

- (IBAction)nextAction:(id)sender;


@property (strong, nonatomic) UIImage *preImage;


@end
