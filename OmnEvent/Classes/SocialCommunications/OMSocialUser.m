//
//  OMSocialUser.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMSocialUser.h"
@implementation OMSocialUser
@dynamic  name,facebookId,ProfileImage,profileURL,Age,Lastname,Firstname,Gender,City,country,location,loginType,zipcode,State,Bio,Name;

+ (id)me
{
    __strong static OMSocialUser *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        
        sharedObject = [[OMSocialUser alloc] init];
    
    });
    
    return sharedObject;
}

- (id)init
{
    if (self  = [super init]) {
        
    }
    return self;
}

+ (id)initWithDict:(NSMutableDictionary *)_dict
{
    return self;

}

@end
