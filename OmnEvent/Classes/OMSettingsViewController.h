//
//  OMSettingsViewController.h
//  Collabro
//
//  Created by Ellisa on 17/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMSettingsViewController : UITableViewController<MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    
    IBOutlet UIImageView *imageViewForAvatar;
    
    IBOutlet UILabel *lblForUsername;
    
    
}

@end
