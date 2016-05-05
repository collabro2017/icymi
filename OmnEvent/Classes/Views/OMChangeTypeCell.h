//
//  OMChangeTypeCell.h
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMChangeTypeCell : UITableViewCell
{
    
    
    
    IBOutlet UISegmentedControl *segmentToChangeType;
    
}
- (IBAction)changeTypeAction:(id)sender;


@property (nonatomic, strong) id delegate;
@end
