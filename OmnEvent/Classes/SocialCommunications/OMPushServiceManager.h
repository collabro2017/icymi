//
//  OMPushServiceManager.h
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMPushServiceManager : NSObject
+ (OMPushServiceManager *)sharedInstance;


- (void)sendGroupInviteNotification:(NSString*)alertMessage
                            groupId:(NSString*)groupId
                           userList:(NSMutableArray*)userList;


- (void)sendNotificationToTaggedFriends:(PFObject *)currentPost;

@end
