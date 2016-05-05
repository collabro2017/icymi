//
//  OMMessageCell.m
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMMessageCell.h"

@implementation OMMessageCell
@synthesize user,currentObj,delegate;

- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:imageViewForAvatar borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentObj:(PFObject *)obj
{
    currentObj = obj;
    
//    user = ;
}
@end
