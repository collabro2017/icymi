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
    
    PFFile *postFile = (PFFile *)_currentObj[@"postImage"];
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
    
    if (_currentObj.badgeCount == 0) {
        
        [lblForBadge setHidden:YES];
        
        if(_currentObj.badgeNotifier > 0)
        {
            [lblForBadge setHidden:NO];
            [lblForBadge setText:[NSString stringWithFormat:@"%lu",(long)_currentObj.badgeNotifier]];
        }
        
    } else {
        [lblForBadge setHidden:NO];
        [lblForBadge setText:[NSString stringWithFormat:@"%lu",(long)_currentObj.badgeCount]];
    }
    
    
    if (_currentObj.badgeNewEvent == 0) {
        
        [lblForNewEvent setHidden:YES];
    } else {
        [lblForNewEvent setHidden:NO];
    }
    
    [lblForTitle setText:_currentObj[@"eventname"]];
    
    user = _currentObj[@"user"];
    if (user != nil) {
        [lblForUsername setText:user.username];
    }
    
    //Show Date & Time in Local Timezone of user's device and in GMT
    NSDateFormatter* formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
    [formatterLocal setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strCreationDateInLocal = [formatterLocal stringFromDate:_currentObj.createdAt];
    
    NSDateFormatter* formatterGMT = [[NSDateFormatter alloc] init];
    [formatterGMT setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatterGMT setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strCreationDateInGMT = [formatterGMT stringFromDate:_currentObj.createdAt];
    lblDateTime.text = [NSString stringWithFormat:@"%@ / %@", strCreationDateInLocal, strCreationDateInGMT];
    lblDateTime.adjustsFontSizeToFitWidth = YES;
}

@end
