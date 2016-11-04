//
//  OMBaseViewController.m
//  OmnEvent
//
//  Created by elance on 7/29/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMBaseViewController.h"
#import "BBBadgeBarButtonItem.h"


#define kNavBarAttributes [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255./255.0 green:255./255.0 blue:255./255.0 alpha:1.0], NSForegroundColorAttributeName,[UIFont fontWithName:@"Gibson" size:15], NSFontAttributeName, [NSNumber numberWithFloat:2.0],NSKernAttributeName,nil]

#define kBoldNavBarAttributes [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255./255.0 green:255./255.0 blue:255./255.0 alpha:1.0], NSForegroundColorAttributeName,[UIFont fontWithName:@"GibsonSemibold" size:15], NSFontAttributeName, [NSNumber numberWithFloat:2.0],NSKernAttributeName,nil]
@interface OMBaseViewController ()
{
    
    BBBadgeBarButtonItem *btnForInvite;
    BBBadgeBarButtonItem *barButton;
}

@end

@implementation OMBaseViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self initializeNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)initializeNavigationBar
{
    ///////
    
    UILabel *titleLabel = [UILabel new];
    
    NSString *titleString = @"ICYMI";
    NSMutableAttributedString *titleAttributedString;
    if ([titleString isEqualToString:@"ICYMI"]) {
        titleAttributedString = [[NSMutableAttributedString alloc] initWithString:titleString.uppercaseString attributes:kBoldNavBarAttributes];
    }
    else{
        titleAttributedString = [[NSMutableAttributedString alloc] initWithString:titleString.uppercaseString attributes:kNavBarAttributes];
    }
    titleLabel.attributedText = titleAttributedString;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;   
    
    
    ///////
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"layer_navigationbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    ////
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];

    [inviteButton addTarget:self action:@selector(showInvite) forControlEvents:UIControlEventTouchUpInside];
//    [inviteButton setImage:[UIImage imageNamed:@"icon_friend"] forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:@"icon_friend"] forState:UIControlStateNormal];

    
    btnForInvite = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:inviteButton];
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [customButton addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchUpInside];
    [customButton setBackgroundImage:[UIImage imageNamed:@"icon_bell"] forState:UIControlStateNormal];
    
    barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
//    barButton.badgeValue = @"2";
    
//    PFInstallation *curIn = [PFInstallation currentInstallation];
//    barButton.badgeValue = [NSString stringWithFormat:@"%ld",(long)[curIn badge]];
    barButton.badgeOriginX = 10;
    barButton.badgeOriginY = -9;
    
    //////
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    [searchButton addTarget:self action:@selector(newEventPostAction) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"icon_newpost"] forState:UIControlStateNormal];
    
    BBBadgeBarButtonItem *btnForSearch = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:searchButton];
    
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer1, btnForSearch,negativeSpacer1, barButton, negativeSpacer1,btnForInvite, nil] animated:NO];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadgeNumber:) name:@"ChangeBadgeCount" object:nil];
    
    
    
}

- (void)changeBadgeNumber:(NSNotification *)_notification
{
    NSDictionary *dic = [_notification userInfo];
    NSLog(@"%@", [dic objectForKey:@"count"]);
//    NSString *count = [((NSNumber *)[dic objectForKey:@"count"]) stringValue];
//    barButton.badgeValue = codunt;
}

- (void)showLeftMenu
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)showMessageView
{
    PFInstallation *currentIns = [PFInstallation currentInstallation];
    
    [currentIns setBadge:0];
    
    [currentIns saveInBackground];
}

- (void)newEventPostAction
{
    [TABController newPostAction:kTypeUploadEvent mediaKind:kTypeCaptureAll currentObject:nil postOrder:-1];
}

- (void)animatePopupView
{
   
}

- (void)showInvite
{
    
    //[self inviteFriendsForApp];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite People" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Invite via Email" otherButtonTitles:@"Invite via SMS", nil];
    
    [actionSheet setTag:1000];
    [actionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag == 1000) {
        
        switch (buttonIndex) {
            case 0:
            {
                [self inviteViaEmail];
                
            }
                break;
            case 1:
            {
                [self inviteViaSMS];
            }
                break;
            default:
                break;
        }

    }
    
}
- (void)inviteViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"Enjoy ICYMI App!"];
        [mailView setMessageBody:@"Created by ICYMI App!Please install it.\n http://apple.co/1ftcr3n" isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
        //                NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
        //                [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [TABController presentViewController:mailView animated:YES completion:nil];
        
    }

}

- (void)inviteViaSMS
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.persistent = YES;
    //            pasteboard.image = [UIImage imageNamed:<#(NSString *)#>]
    
    NSString *phoneToCall = @"sms:";
    NSString *phoneToCallEncoded = [phoneToCall stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSURL *url = [[NSURL alloc] initWithString:phoneToCallEncoded];
    [[UIApplication sharedApplication] openURL:url];
    
    if ([MFMessageComposeViewController canSendText]) {
        controller.messageComposeDelegate = self;
        controller.body = @"Created by ICYMI App!Please install it.\n http://apple.co/1ftcr3n";
        NSMutableDictionary *navBarTitleAttributes = [[UINavigationBar appearance] titleTextAttributes].mutableCopy;
        
        UIFont *navBarTitleFont = navBarTitleAttributes[NSFontAttributeName];
        
        navBarTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:navBarTitleFont.pointSize];
        [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
        
        [TABController presentViewController:controller animated:YES completion:^{
            navBarTitleAttributes[NSFontAttributeName] = navBarTitleFont;
            [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleAttributes];
        }];
    }
    else
    {
        [OMGlobal showAlertTips:@"Your device can't support SMS" title:nil];
    }

}


#pragma mark

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultCancelled) {
    
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActivityViewController - Sharing with this App link and User

- (void) inviteFriendsForApp
{
    //-- set strings and URLs
    NSString *textObject = @"Enjoy ICYMI App!";
    NSString *urlString = [NSString stringWithFormat:@"http://apple.co/1ftcr3n"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSArray *activityItems = [NSArray arrayWithObjects:textObject, url,  nil];
    
    //-- initialising the activity view controller
    UIActivityViewController *avc = [[UIActivityViewController alloc]
                                     initWithActivityItems:activityItems
                                     applicationActivities:nil];
    
    
    avc.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                  UIActivityTypeAssignToContact,
                                  UIActivityTypeCopyToPasteboard ];
    
    
    //-- define the activity view completion handler
    avc.completionHandler = ^(NSString *activityType, BOOL completed){
        
        if (completed) {
            // NSLog(@"Selected activity was performed.");
        } else {
            if (activityType == NULL) {
                //   NSLog(@"User dismissed the view controller without making a selection.");
            } else {
                //  NSLog(@"Activity was not performed.");
            }
        }
    };
    
    [TABController presentViewController:avc animated:YES completion:nil];

}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end
