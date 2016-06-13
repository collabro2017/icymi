//
//  OMTagFolderCell.h
//  ICYMI
//
//  Created by Kevin on 8/18/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMTagFolderCell : UITableViewCell
{
    
    PFUser *currentUser;
    
    IBOutlet UIButton *btnForAvatar;
    
    IBOutlet UIImageView *imageViewForFolder;
    IBOutlet UILabel *lblForFolderName;
    
}
@property (nonatomic, strong)id delegate;
@property (nonatomic, strong)PFUser *user;
@property (nonatomic, strong)PFObject *object;

@end
