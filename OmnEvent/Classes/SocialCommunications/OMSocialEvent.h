//
//  OMSocialEvent.h
//  ICYMI
//
//  Created by Ellisa on 7/19/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <Parse/Parse.h>

@interface OMSocialEvent : PFObject<PFSubclassing>

@property (nonatomic, strong)NSMutableArray         *TagFriends;
@property (nonatomic, strong)NSMutableArray         *commenters;
@property (nonatomic, strong)NSMutableArray         *commentsArray;
@property (nonatomic, strong)NSString               *country;
@property (nonatomic, strong)NSString               *description;
@property (nonatomic, strong)NSString               *eventname;
@property (nonatomic, strong)NSMutableArray         *likeUserArray;
@property (nonatomic, strong)NSMutableArray         *likers;
@property (nonatomic, strong)PFGeoPoint             *locationData;
@property (nonatomic, strong)NSNumber               *openStatus;
@property (nonatomic, strong)PFFile                 *postImage;
@property (nonatomic, strong)NSString               *postType;
@property (nonatomic, strong)PFFile                 *thumbImage;
@property (nonatomic, strong)NSNumber               *totalCount;
@property (nonatomic, strong)PFUser                 *user;
@property (nonatomic, strong)NSString               *username;
@property (nonatomic, assign)NSInteger               badgeCount;
@property (nonatomic, assign)NSDate                 *updateAt;
@property (nonatomic, assign)NSDate                 *loadTimeAt;
@property (nonatomic, assign)NSMutableArray         *postedObjects;
@property (nonatomic, assign)NSInteger              badgeNewEvent;
@property (nonatomic, assign)NSInteger              badgeNotifier;

@end
