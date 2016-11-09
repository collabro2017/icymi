//
//  FTTabBarController.m
//  Forty
//
//  Created by Ellisa on 15/12/14.
//  Copyright (c) 2014 Linus Olander. All rights reserved.
//

#import "FTTabBarController.h"
#import "OMLoginViewController.h"
#import "OMHomeViewController.h"
#import "OMCameraViewController.h"
#import "OMWelcomeViewController.h"
#import "OMPostEventViewController.h"
#import "OMRecordAudioViewController.h"
#import "OMMyProfileViewController.h"
#import "OMTutorialVC.h"
#import "OMCameraPhotoViewController.h"

#define RED     13.0f/255.0f
#define BLUE    178.0f/255.0f
#define GREEN   186.0f/225.0f
@interface FTTabBarController ()
{
    NSArray *availableIdentifiers;
    
    
    NSArray *arrForPopList;
    
    
    CGFloat _popoverWidth;
    CGSize _popoverArrowSize;
    CGFloat _popoverCornerRadius;
    CGFloat _animationIn;
    CGFloat _animationOut;
    
    BOOL _animationSpring;
    
    
    CGFloat heightOfTabView;
    CGFloat topSpaceOfNotification;
    
    NSMutableDictionary *_viewControllersByIdentifier;
    
    
    
    NSString *urlForVideo;
    
    MPMoviePlayerViewController *player;


    
    
}
@property (nonatomic, strong) UITableView *tblForPopup;

//@property (nonatomic, strong) DXPopover *popover;
@end

@implementation FTTabBarController

@synthesize currentViewController;
@synthesize placeholderView;
@synthesize tabBarButtons;

- (IBAction)tabBarAction:(id)sender {
    
    if (((UIButton *)sender).tag == 10) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFirstViewLoad object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFirstDetailViewLoad object:nil];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForthDetailViewLoad object:nil];
    
}

- (IBAction)showMessageAction:(id)sender {
}

- (void)newPostAction:(int)_uploadOption mediaKind:(int)_captureOption currentObject:(PFObject *)_curObj postOrder:(int)_postOrder
{
    if ((kTypeCapture)_captureOption == kTypeCaptureText) {
        
        OMPostEventViewController *postEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostEventVC"];
        
        [postEventVC setUploadOption:_uploadOption];
        [postEventVC setCaptureOption:_captureOption];
        [postEventVC setCurObj:_curObj];
        [postEventVC setPostOrder:_postOrder];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postEventVC];
        
        [nav setNavigationBarHidden:NO animated:YES];
        
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    else
    {
//        if(_captureOption == kTypeCaptureVideo)
        {
            OMCameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraVC"];
            
            [cameraVC setUploadOption:(kTypeUpload)_uploadOption];
            [cameraVC setCaptureOption:(kTypeCapture)_captureOption];
            [cameraVC setCurObj:_curObj];
            [cameraVC setPostOrder:_postOrder];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraVC];
            
            [nav setNavigationBarHidden:YES animated:YES];
            
            [self presentViewController:nav animated:YES completion:nil];
        }
//        else if(_captureOption == kTypeCapturePhoto)
//        {
//            OMCameraPhotoViewController * photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraPhotoVC"];
//            [photoVC setUploadOption:(kTypeUpload)_uploadOption];
//            [photoVC setCaptureOption:_captureOption];
//            [photoVC setCurObj:_curObj];
//            
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
//            
//            [nav setNavigationBarHidden:YES animated:YES];
//            
//            [self presentViewController:nav animated:YES completion:nil];
//        }
       

    }
}

- (void)showAudioRecordScreen
{
    
}

- (void)postAudio:(int)_uploadOption mediaKind:(int)_captureOption currentObject:(PFObject *)_curObj
        audioData:(NSData *)_audioData postOrder:(int)_postOrder
{
        
    OMRecordAudioViewController *recordAudioVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordAudioVC"];
    [recordAudioVC setUploadOption:_uploadOption];
    [recordAudioVC setCaptureOption:_captureOption];
    [recordAudioVC setCurObj:_curObj];
    [recordAudioVC setAudioData:_audioData];
    [recordAudioVC setPostOrder:_postOrder];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recordAudioVC];
    [nav setNavigationBarHidden:NO animated:YES];
    [self presentViewController:nav animated:YES completion:nil];
    
    /////

    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postEventVC];
//    
//    [nav setNavigationBarHidden:YES animated:YES];
//    
//    [self presentViewController:nav animated:YES completion:nil];

}

- (void) setSelectedIndex: (int) index
{
    if ([tabBarButtons count] <= index) return;
    
    
    [self performSegueWithIdentifier: availableIdentifiers[index]
                              sender: tabBarButtons[index]];
}

- (void)hideTabView:(BOOL)_hidden
{
    
    [tabView setHidden:_hidden];
    if (_hidden) {
        self.heightConstraint.constant = 0;
    }
    else
    {
        self.heightConstraint.constant = heightOfTabView;
    }
    
}

- (IBAction)showPopupAction:(id)sender {
}

- (void)showNotification:(NSNotification *)_notification
{
    constraintForNotificationHeight.constant = topSpaceOfNotification;
    
    [self.view layoutIfNeeded];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contraintWidthTabbar.constant = IS_IPAD? 414 : SCREEN_WIDTH_ROTATED;
    
    urlForVideo = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"mp4"];
    
    //////
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    
    availableIdentifiers = @[@"kIdentifierHome",
                             @"kIdentifierSearch",
                             @"kIdentifierFriend",
                             @"kIdentifierProfile"];
    
    if([tabBarButtons count]) {
        
        [self performSegueWithIdentifier: @"kIdentifierHome"
                                  sender: tabBarButtons[0]];
        
    }
    
    topSpaceOfNotification = constraintForNotificationHeight.constant;
    heightOfTabView = self.heightConstraint.constant;
    
    constraintForNotificationHeight.constant = -200;
    
    
    ////////
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotification:) name:kLoadEventData object:nil];
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];

    
    [USER fetchIfNeeded];
    
    player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:urlForVideo]];
    [[NSNotificationCenter defaultCenter] removeObserver:player
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player.moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player.moviePlayer];

}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        // Dismiss the view controller
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [OMGlobal setCircleView:imageViewForAvatar borderColor:[UIColor whiteColor]];
    
    if (USER) {
        if ([USER[@"loginType"] isEqualToString:@"email"] || [USER[@"loginType"] isEqualToString:@"gmail"]) {
            
            
            PFFile *avatarFile = (PFFile *)USER[@"ProfileImage"];
            
            if (avatarFile) {
                
                [imageViewForAvatar setImageWithURL:[NSURL URLWithString:avatarFile.url]];
            }
        }
        else if ([USER[@"loginType"] isEqualToString:@"facebook"])
        {
            
            [imageViewForAvatar setImageWithURL:[NSURL URLWithString:USER[@"profileURL"]]];

        }
    }
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (void)signOut
{
    OMWelcomeViewController *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:NO completion:^{
        
        [self setSelectedIndex:0];
        
        [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
        [[PFInstallation currentInstallation] saveInBackground];
        
        // Clear all caches
        [PFQuery clearAllCachedResults];
        
        // Log out
        [PFUser logOut];
        [FBSession setActiveSession:nil];
        [APP_DELEGATE setLogOut:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LOG_IN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        OMAppDelegate *appDelegate = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }];
}

#pragma mark 

-(void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    
    self.oldViewController = self.currentViewController;
    
    if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
    
        [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    if([availableIdentifiers containsObject: segue.identifier])
    {
        for (UIButton *btn in tabBarButtons)
        {
            if(sender != nil && ![btn isEqual: sender]) {
                [btn setSelected: NO];
                [btn setEnabled:YES];
            }
            else if(sender != nil)
            {
                [btn setSelected: YES];
//                [btn setEnabled:NO];
            }
        }
        self.destinationIdentifier = segue.identifier;
        self.currentViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
        
        
        if ([segue.identifier isEqualToString:@"kIdentifierProfile"]) {
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:kGetProfileInfoNotification object:nil];
            
            UINavigationController *nav = (UINavigationController *)self.currentViewController;
            //MyProfileViewController *otherVC = (MyProfileViewController *) nav.topViewController;
            
            OMMyProfileViewController *myProfileVC = (OMMyProfileViewController *)nav.topViewController;
            myProfileVC.is_type = 0;
            [myProfileVC setTargetUser:USER];
            [myProfileVC setIsPushed:NO];
            
            
        }

    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        return NO;
    }
    
    return YES;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[_viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [_viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
}


- (IBAction)showTutorialVideoAction:(id)sender {
    [TABController presentMoviePlayerViewControllerAnimated:player];
}
@end
