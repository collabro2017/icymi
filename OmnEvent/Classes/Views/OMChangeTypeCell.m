//
//  OMChangeTypeCell.m
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMChangeTypeCell.h"

@implementation OMChangeTypeCell
@synthesize delegate;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeTypeAction:(id)sender {
    
    
    UISegmentedControl *control = (UISegmentedControl *)sender;

    
    if ([delegate respondsToSelector:@selector(changeType:)]) {
        
        [delegate performSelector:@selector(changeType:) withObject:[NSNumber numberWithInteger:control.selectedSegmentIndex]];
    }
}
@end
