//
//  OMPasswordCell.h
//  Collabro
//
//  Created by Ellisa on 17/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMPasswordCell : UITableViewCell
{
    
    IBOutlet UIImageView *imageViewForLock;
    
    IBOutlet UITextField *txtForPassword;
    
}
- (void)configureCell:(NSString *)str;

@end
