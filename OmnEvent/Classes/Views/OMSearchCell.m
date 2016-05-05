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
    
    PFObject *temp_object = (PFObject *)obj;
    
    NSString *lastLoadTime_Key = [NSString stringWithFormat:@"%@-lastLoadTime", temp_object.objectId];
    
    NSDate* lastLoadTime = [[NSUserDefaults standardUserDefaults] objectForKey:lastLoadTime_Key];
    if (!lastLoadTime) {
        lastLoadTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:lastLoadTime forKey:lastLoadTime_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //NSDate *postTime = obj[@"updateAt"];
    NSDate *postTime = obj.updatedAt;
    
    NSComparisonResult result = [lastLoadTime compare:postTime];
    
    BOOL newEventFlag = NO;
    
    if (result == NSOrderedSame || result == NSOrderedAscending){
        newEventFlag = YES;
    }
    
    PFQuery *temp_mainQuery = [PFQuery queryWithClassName:@"Post"];
    [temp_mainQuery whereKey:@"targetEvent" equalTo:temp_object];
    
    [temp_mainQuery includeKey:@"user"];
    [temp_mainQuery includeKey:@"commentsArray"];
    [temp_mainQuery orderByDescending:@"createdAt"];
    
    if (!newEventFlag && lastLoadTime)
        [temp_mainQuery whereKey:@"updateAt" greaterThanOrEqualTo:lastLoadTime];
    
    [temp_mainQuery findObjectsInBackgroundWithBlock:^(NSArray *sub_objects, NSError *error) {
        
        NSLog(@"--------error----------%@", error);
        
        if (error || !sub_objects) {
            //NSLog(@"--------error----------%@", error);
            _currentObj.badgeCount = 0;
            
        } else {
            //NSLog(@"--------right----------");
            _currentObj.badgeCount = sub_objects.count;
            
            if (_currentObj.badgeCount == 0) {
                
                [lblForBadge setHidden:YES];
            } else {
                [lblForBadge setHidden:NO];
                [lblForBadge setText:[NSString stringWithFormat:@"%lu",(long)_currentObj.badgeCount]];
            }
            
        }
    }];
    
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
