//
//  OMAppDelegate.h
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_UPLOADING FALSE

@class FTTabBarController;
@interface OMAppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL m_fLoadingPostView;
}


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) BOOL logOut;
@property (nonatomic, assign) BOOL m_fLoadingPostView;
@property (nonatomic, retain) NSMutableArray* m_offlinePosts;
@property (nonatomic, retain) NSMutableArray* m_offlinePostURLs;
@property (nonatomic, assign) BOOL network_state;

- (FTTabBarController *)tabBarController;

@end
