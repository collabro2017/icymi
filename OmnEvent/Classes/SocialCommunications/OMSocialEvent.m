//
//  OMSocialEvent.m
//  ICYMI
//
//  Created by Ellisa on 7/19/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMSocialEvent.h"
#import <Parse/PFObject+Subclass.h>

@implementation OMSocialEvent

@dynamic TagFriends,thumbImage,totalCount,user,username,likers,likeUserArray,commentsArray,country,postImage,postType,description,eventname,locationData,openStatus,commenters, updateAt, postedObjects;

@synthesize badgeCount, loadTimeAt;


+ (NSString *)parseClassName
{
    return @"Event";
}


@end
