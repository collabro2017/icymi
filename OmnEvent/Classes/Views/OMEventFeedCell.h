//
//  OMEventFeedCell.h
//  ICYMI
//
//  Created by Muhammad Junaid Butt on 01/11/2016.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMEventFeedCell : UITableViewCell

@property (strong, nonatomic) PFObject *currentObj;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEventTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblOwnerName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightForTitle;

@end
