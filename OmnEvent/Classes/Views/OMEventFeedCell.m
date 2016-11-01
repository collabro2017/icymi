//
//  OMEventFeedCell.m
//  ICYMI
//
//  Created by Muhammad Junaid Butt on 01/11/2016.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMEventFeedCell.h"

@implementation OMEventFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.lblEventTitle.text = self.currentObj[@"eventname"];
    self.lblOwnerName.text = ((PFUser *)self.currentObj[@"user"]).username;
    
    //Show Date & Time in Local Timezone of user's device and in GMT
    NSDateFormatter* formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
    [formatterLocal setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strCreationDateInLocal = [formatterLocal stringFromDate:self.currentObj.createdAt];
    
    NSDateFormatter* formatterGMT = [[NSDateFormatter alloc] init];
    [formatterGMT setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatterGMT setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strCreationDateInGMT = [formatterGMT stringFromDate:self.currentObj.createdAt];
    self.lblEventDate.text = [NSString stringWithFormat:@"%@ / %@", strCreationDateInLocal, strCreationDateInGMT];
    self.lblEventDate.adjustsFontSizeToFitWidth = YES;
    
    self.constraintHeightForTitle.constant = [OMGlobal heightForCellWithPost:self.currentObj[@"eventname"]] - 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
