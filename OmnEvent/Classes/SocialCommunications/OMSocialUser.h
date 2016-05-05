//
//  OMSocialUser.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMSocialUser : PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *Gender;
@property (nonatomic, strong) NSString *Age;
@property (nonatomic, strong) NSString *City;
@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *Firstname;
@property (nonatomic, strong) NSString *Lastname;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *profileURL;
@property (nonatomic, strong) NSString *ProfileImage;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic, strong) NSString *loginType;
@property (nonatomic, strong) NSString *Bio;
@property (nonatomic, strong) NSString *country;


@end
