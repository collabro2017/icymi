//
//  OMSearchCell.m
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMSearchCell.h"
#import "OMSocialEvent.h"
@implementation OMSearchCell
@synthesize delegate,user;

- (void)setCurrentObj:(OMSocialEvent *)obj {
    
    [OMGlobal setCircleView:lblForBadge borderColor:nil];
    
    [btnForVideo setHidden:YES];
    _currentObj = obj;
    
    if (imageViewForBG.image) {
        imageViewForBG.image = nil;
    }
    
    PFFile *postFile = (PFFile *)_currentObj[@"thumbImage"];
    if (postFile) {
    
        if (imageViewForBG.image) {
            imageViewForBG.image = nil;
        }
        [imageViewForBG setImageWithURL:[NSURL URLWithString:postFile.url] placeholderImage:nil];
    }
    
    if ([_currentObj[@"postType"] isEqualToString:@"video"]) {
        //[btnForVideo setHidden:NO];
    } else {
        [btnForVideo setHidden:YES];
    }
    
    //NSLog(@"-------_currentObj.badgeCount cell------------%lu", _currentObj.badgeCount);
    
    if (_currentObj.badgeCount == 0) {
        
        [lblForBadge setHidden:YES];
    } else {
        [lblForBadge setHidden:NO];
        [lblForBadge setText:[NSString stringWithFormat:@"%lu",(long)_currentObj.badgeCount]];
    }
    [lblForTitle setText:_currentObj[@"eventname"]];
    user = _currentObj[@"user"];
    
    [lblForUsername setText:user.username];
}

@end
