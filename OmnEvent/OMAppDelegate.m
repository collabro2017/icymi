//
//  OMAppDelegate.m
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMAppDelegate.h"
#import <Parse/Parse.h>
#import "FTTabBarController.h"

#import "OMLoginViewController.h"

#import "OMWelcomeViewController.h"

#import "OMLeftMenuViewController.h"
#import "SlideNavigationController.h"
#import "OMSocialEvent.h"
#import <Crittercism/Crittercism.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import "OMTermsAndConditionsViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

// Test

//#define PARSE_APP_ID @"i5GXnqwQYfjS0xlNql2Oi29jEdCg6zFhLAZSE0t1"
//#define CLIENT_KEY   @"oFHtcrLhbqXt3Ge9ylT3KjJmYwo3vE63ImIWEZDW"

//////   Real
#define PARSE_APP_ID      @"fXthztgrwB3gdmQ5TNGL4DVNRzaZJWgoeIBH6lVD"
#define CLIENT_KEY        @"CCSj4mz2TxK2lVJxARaFPaKSj8btTG3loZhtg9II"

@implementation OMAppDelegate

@synthesize m_fLoadingPostView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Install Fabric
    [Fabric with:@[[Crashlytics class]]];
    
    self.logOut = NO;
    m_fLoadingPostView = NO;
    _network_state = YES;
    
    [GlobalVar getInstance].isPostLoading = YES;
    [GlobalVar getInstance].isEventLoading = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"network_status"])
    {
        _network_state = [[NSUserDefaults standardUserDefaults] boolForKey:@"network_status"];
    }
    
    //Parse  Setting
    
    [OMSocialEvent registerSubclass];
    [ParseCrashReporting enable];
    [Parse enableLocalDatastore];
    //[Parse setApplicationId:PARSE_APP_ID clientKey:CLIENT_KEY];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = PARSE_APP_ID;
        configuration.clientKey = CLIENT_KEY;
        configuration.server = @"http://eb-icymyi-parse-server.jegr4ium5p.us-east-1.elasticbeanstalk.com/parse";
        [configuration setLocalDatastoreEnabled:YES ];
    }]];
    
    if (IS_UPLOADING)
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Facebook
    
    [PFFacebookUtils initializeFacebook];
    
    //Track app open
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFInstallation *installation = [PFInstallation currentInstallation];  
    
    if (installation.badge != 0) {
        
        installation.badge = 0;
        [installation saveInBackground];
        
    }
    
    //Google Email Login
    
    [GIDSignIn sharedInstance].clientID = KEY_GOOGLE_CLIENTID;
    //[GIDSignIn sharedInstance].delegate = self;
    
    //Enable public read access by default, with any newly created PFObjects belonging to the current user
    
    PFACL *defaultACL = [PFACL ACL];
    
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [Crittercism enableWithAppID:@"c8963df223864f368fe542d911897d6000555300"];
    
    if (application.applicationState != UIApplicationStateBackground) {
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    //Push Notifications
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfo ) {
        
        [self application:application didFinishLaunchingWithOptions:userInfo];
        
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    [self handlePush:launchOptions];
    
    _m_offlinePosts = [[NSMutableArray alloc] init];
    _m_offlinePostURLs = [[NSMutableArray alloc] init];
    
    [GlobalVar getInstance].gArrEventList = [[NSMutableArray alloc] init];
    
    //Check for app version
    NSString *saveAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_VERSION"];
    NSString *currentAppVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (![currentAppVersion isEqualToString:saveAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"APP_VERSION"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AGREEMENT_AGREED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFInstallation *installation = [PFInstallation currentInstallation];

    if (installation.badge != 0) {
        installation.badge = 0;
        [installation saveEventually];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LOG_IN] && currentUser) {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:AGREEMENT_AGREED]) {
            [self showAgreementVC];
        }
        
        if(![GlobalVar getInstance].isEventLoading)
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
        if(![GlobalVar getInstance].isPostLoading)
        {
            //[[NSNotificationCenter defaultCenter] postNotificationName:kLoadComponentsData object:nil];
        }
        
        [installation setObject:USER forKey:@"user"];
        [installation setObject:USER.objectId forKey:@"userID"];
        [installation saveEventually];        
        
    }
    else
    {
        [self showWelcomeVC];
    }
}

// For iOS 8.0 and Older
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
   // for temporatly - unknown issue
    if([[url absoluteString] containsString:@"denied"]
       && [[url absoluteString] containsString:@"com.googleusercontent.apps"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideMBProgressView" object:nil];
        return NO;
    }
    BOOL googleSignInFlag = [[GIDSignIn sharedInstance] handleURL:url
                                              sourceApplication:sourceApplication
                                                     annotation:annotation];
    
    BOOL facebookSignInFlag = [FBAppCall handleOpenURL:url
                                    sourceApplication:sourceApplication
                                          withSession:[PFFacebookUtils session]];
    
    return facebookSignInFlag || googleSignInFlag;
}
//// For iOS 8.0 and new
//- (BOOL)application:(UIApplication *)app
//            openURL:(NSURL *)url
//            options:(NSDictionary *)options {
//    
//    BOOL googleSignInFlag = [[GIDSignIn sharedInstance] handleURL:url
//                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//
//    BOOL facebookSigInFlag = [FBAppCall handleOpenURL:url
//                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                          withSession:[PFFacebookUtils session]];
//
//    return googleSignInFlag || facebookSigInFlag;
//}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
    NSLog(@"%@", userInfo);
    
    if ([userInfo objectForKey:@"request"]) {
        
       // [[NSNotificationCenter defaultCenter] postNotificationName:kShowBadgeOnEvent object:nil userInfo:userInfo];
        
    }
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    
    [currentInstallation saveEventually];
    /*
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadEventData object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBadgeCount" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:count] forKey:@"count"]];
     
     */
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    if ([userInfo objectForKey:@"request"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowBadgeOnEvent object:nil userInfo:userInfo];
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

#pragma mark -

- (void)handlePush:(NSDictionary *)launchOptions {
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    //NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //    if (remoteNotificationPayload) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
    //
    //        if (![PFUser currentUser]) {
    //            return;
    //        }
    //
    //        // If the push notification payload references a photo, we will attempt to push this view controller into view
    //        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
    //        if (photoObjectId && photoObjectId.length > 0) {
    //            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
    //            return;
    //        }
    //
    //        // If the push notification payload references a user, we will attempt to push their profile into view
    //        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
    //        if (fromObjectId && fromObjectId.length > 0) {
    //            PFQuery *query = [PFUser query];
    //            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    //            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
    //                if (!error) {
    //                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
    //                    self.tabBarController.selectedViewController = homeNavigationController;
    //
    //                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    //                    NSLog(@"Presenting account view controller with user: %@", user);
    //                    accountViewController.user = (PFUser *)user;
    //                    [homeNavigationController pushViewController:accountViewController animated:YES];
    //                }
    //            }];
    //        }
    //    }
}

#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error{
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    }else
    {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}

#pragma mark - TabBarController

- (FTTabBarController *)tabBarController
{
    return (FTTabBarController *) self.window.rootViewController;
}

- (void)showWelcomeVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    OMWelcomeViewController *welcomeVC = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
    [nav setNavigationBarHidden:YES];
    [self.window.rootViewController presentViewController:nav animated:NO completion:nil];
    [self.window makeKeyAndVisible];
}

- (void)showAgreementVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    OMTermsAndConditionsViewController *termsVC = [storyboard instantiateViewControllerWithIdentifier:@"TermsVC"];
    termsVC.isToolbarShown = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:termsVC];
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [self.window makeKeyAndVisible];
}

@end
