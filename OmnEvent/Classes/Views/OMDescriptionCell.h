//
//  OMDescriptionCell.h
//  Collabro
//
//  Created by XXX on 4/21/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMDescriptionCell : UITableViewCell<UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UITextView *txtViewForDescription;
}

@property (strong, nonatomic) PFObject *currentObj;
@property (strong, nonatomic) PFUser   *user;
@property (strong, nonatomic) NSString *beforeDescription;

@end
