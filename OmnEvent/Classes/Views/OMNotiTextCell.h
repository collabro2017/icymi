//
//  OMNotiTextCell.h
//  ICYMI
//
//  Created by lion on 11/28/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMNotiTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblUser;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblActivityTitle;

@end
