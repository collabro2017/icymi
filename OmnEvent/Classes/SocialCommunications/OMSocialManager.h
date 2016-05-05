//
//  OMSocialManager.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OMSocialUser;
@class OMSocialFeed;
@class OMSocialNotification;
@interface OMSocialManager : NSObject

@property (strong, nonatomic) OMSocialUser *me;

+ (OMSocialManager *)sharedManager;




- (void)addPhoto;

@end
