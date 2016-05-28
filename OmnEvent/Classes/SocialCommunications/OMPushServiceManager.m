//
//  OMPushServiceManager.m
//  Collabro
//
//  Created by XXX on 4/13/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMPushServiceManager.h"

@implementation OMPushServiceManager


+ (OMPushServiceManager *)sharedInstance
{
    __strong static OMPushServiceManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        
        sharedObject = [[OMPushServiceManager alloc] init];
        
    });
    
    return sharedObject;
}

- (void)sendGroupInviteNotification:(NSString*)alertMessage groupId:(NSString*)groupId userList:(NSMutableArray*)userList{
    NSDictionary *data = @{@"action":@"org.church.rockmobile.PUSH_ACTION",
                           @"badge":@"Increment",
                           @"alert":alertMessage,
                           @"sound":@"default",
                           @"type":@"Tag"};
    
//    PFQuery *innerQuery = [PFQuery queryWithClassName:kClassUser];
    
//    [innerQuery whereKey:@"objectId" containedIn:userList];
    
    
    
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"userID" containedIn:userList];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            NSLog(@"Push Sent Successfully");
        }
    }];
}

- (void)sendNotificationToTaggedFriends:(PFObject *)currentPost
{
    
//    [PFCloud callFunctionInBackground:@"sendNotificationsToTaggedFriends"
//                       withParameters:@{@"postID":currentPost.objectId}];
    
}
@end
