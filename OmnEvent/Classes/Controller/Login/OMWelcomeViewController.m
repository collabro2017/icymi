//
//  OMWelcomeViewController.m
//  Collabro
//
//  Created by Ellisa on 19/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMWelcomeViewController.h"

@interface OMWelcomeViewController ()
{
    PFUser *newUser;
}
@end

@implementation OMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Google Sign In
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;

    //PFUser init
    newUser = [PFUser user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMBProgressView) name:@"HideMBProgressView" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[FBSession activeSession] isOpen])
    {
        NSLog(@"Session opened");
    }
}

- (IBAction)loginWithFBAction:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *arrForPermission = @[@"email",@"user_friends"];
    
    //Login PFUser using FB
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [PFFacebookUtils logInWithPermissions:arrForPermission block:^(PFUser *user, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh, The user cancelled the FB login");
                return;
            }
            else
            {
                NSLog(@"An error occured %@",error.localizedDescription);
                return;
            }
        }
        else if (user.isNew)
        {
            NSLog(@"user with fb signed up and logged in");
            [self registerUser];
            
        }else
        {
            NSLog(@"User with FB logged");
            [self registerUser];
            
        }
        
    }];

}

- (void)registerUser
{
    NSLog(@"Registering user information");
    
    if ([FBSession activeSession].isOpen) {
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"name, location, gender, birthday, relationship_status, first_name, last_name", @"fields", nil];
        
        FBRequest *request = [FBRequest requestWithGraphPath:@"me" parameters:params HTTPMethod:nil];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
        {
            NSLog(@"error %@", error);
            
            if (!error)
            {
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebook_id = userData[@"id"];
                NSString *name = userData[@"name"];
                NSString *relationship = userData[@"relationship_status"];
                NSString *location = userData[@"location"][@"name"];
                NSString *gender = userData[@"gender"];
                NSString *birthday = userData[@"birthday"];
                NSString *first_name = userData[@"firstname"];
                NSString *last_name = userData[@"lastname"];
                NSString *profileURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?",facebook_id];
                
                PFUser *currentUser = [PFUser currentUser];
                
                if ([currentUser objectForKey:@"Status"])
                {
                    BOOL status = [[currentUser objectForKey:@"Status"] boolValue];
                    if (!status)
                    {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your account is suspended." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        return;
                    }
                }
                
                [currentUser setObject:facebook_id forKey:@"facebookId"];
                [currentUser setObject:profileURL forKey:@"profileURL"];
                if (gender) {
                    [currentUser setObject:gender forKey:@"Gender"];
                }
                if (birthday) {
                    [currentUser setObject:birthday forKey:@"Birthday"];
                }
                if (relationship) {
                    [currentUser setObject:relationship forKey:@"Relationship"];
                }
                if (location) {
                    [currentUser setObject:location forKey:@"Location"];
                }
                if (first_name) {
                    [currentUser setObject:first_name forKey:@"Firstname"];
                }
                if (last_name) {
                    [currentUser setObject:last_name forKey:@"LastName"];
                }
                if (name) {
                    [currentUser setObject:name forKey:@"username"];
                    [currentUser setObject:name forKey:@"name"];
                    
                }
                currentUser[@"loginType"] = @"facebook";
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        if (![PFFacebookUtils isLinkedWithUser:currentUser])
                        {
                            [PFFacebookUtils linkUser:currentUser permissions:nil block:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    NSLog(@"User logged in with FB");
                                }
                            }];
                        }
                        
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        [installation setObject:currentUser forKey:@"user"];
                        [installation saveEventually];
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    
                    if ([APP_DELEGATE logOut])
                    {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadSearchData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriendData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFolderData object:nil];
                    }
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        [APP_DELEGATE setLogOut:NO];
                        [OMGlobal setLogInUserDefault];
                    }];
                }];
            }
        }];
    }
}

// SignUp and SignIn with gmail
- (IBAction)signInWithGmail:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GIDSignIn sharedInstance] signIn];
}

- (void)hideMBProgressView
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)registerWithGoogleMail:(GIDGoogleUser *)googleUser
{
    
    NSString *userEmail;
    NSString *userName;
    NSString *userPassword;
    NSString *loginType;
    NSURL *profileUrl;
    
    userName = googleUser.profile.name;
    userEmail = googleUser.profile.email;
    
    userPassword = GMAIL_SIGNIN_KEY;
    loginType = @"gmail";
    
    // In Case with profile Image
    if(googleUser.profile.hasImage)
    {
        NSUInteger dimension = round(200 * [[UIScreen mainScreen] scale]);
        profileUrl = [googleUser.profile imageURLWithDimension:dimension];
        
        // fetch profile image from URL
        NSURLRequest *userURLRequest = [NSURLRequest requestWithURL:profileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
        [NSURLConnection sendAsynchronousRequest:userURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(connectionError == nil){
                
                PFFile *profilePicture = [PFFile fileWithName:@"avatar.jpg" data:data];
                newUser[@"ProfileImage"] = profilePicture;
                
                [newUser setUsername:userName];
                [newUser setEmail:userEmail];
                [newUser setPassword:userPassword];
                newUser[@"name"] = userName;
                newUser[@"loginType"] = loginType;
                //newUser[@"emailVerified"] = [NSNumber numberWithBool:YES];
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // SignUp with gmail information on Parse
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    if (succeeded) {
                        
                        NSLog(@"Login success with profile Image");
                        
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        [installation setObject:newUser forKey:@"user"];
                        [installation setObject:newUser.objectId forKey:@"userID"];
                        [installation saveEventually];
                        [OMGlobal setLogInUserDefault];
                        
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        [OMGlobal showAlertTips:[error localizedDescription] title:@"Failed to Sign Up!"];
                        
                    }
                }];
            }else{
                [OMGlobal showAlertTips:connectionError.localizedDescription title:@"SignUp with Gmail"];
            }
        }];
    }
    
    // In Case with no profile Image
    else
    {
        
        [newUser setUsername:userName];
        [newUser setEmail:userEmail];
        [newUser setPassword:userPassword];
        newUser[@"name"] = userName;
        newUser[@"loginType"] = loginType;
        //newUser[@"emailVerified"] = [NSNumber numberWithBool:YES];
        
        // SignUp with gmail information on Parse
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (succeeded) {
                
                 NSLog(@"Login success with No profile Image");
                
                PFInstallation *installation = [PFInstallation currentInstallation];
                [installation setObject:newUser forKey:@"user"];
                [installation setObject:newUser.objectId forKey:@"userID"];
                [installation saveEventually];
                [OMGlobal setLogInUserDefault];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [OMGlobal showAlertTips:[error localizedDescription] title:@"Failed to Sign Up!"];
                
            }
        }];
    }
}


- (void)signInwithGoogleMail:(GIDGoogleUser*)googleUser
{

    NSString *userName = googleUser.profile.name;
    NSString *userEmail = googleUser.profile.email;
    NSString *userPassword = GMAIL_SIGNIN_KEY;
   
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:userEmail];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [OMGlobal showAlertTips:error.localizedDescription title:@"Google SignIn"];
            return;
        }
        
        if([objects count] == 0)
        {
            //In Case New Account with this google user
            [self registerWithGoogleMail:googleUser];
            return;
        }
        
        PFUser *user = (PFUser *)objects[0];
        
        if ([user objectForKey:@"Status"])
        {
            BOOL status = [[user objectForKey:@"Status"] boolValue];
            if (!status)
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [OMGlobal showAlertTips:@"Your account is suspended." title:@"Oops!"];
                return;
            }
        }
        
        [PFUser logInWithUsernameInBackground:userName password:userPassword block:^(PFUser *user, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (user) {
                
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if(error)
                    {
                        NSLog(@"Fetch error with current User");
                    }
                    PFInstallation *installation = [PFInstallation currentInstallation];
                    [installation setObject:user forKey:@"user"];
                    [installation setObject:user.objectId forKey:@"userID"];
                    [installation saveEventually];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    
                    if ([APP_DELEGATE logOut]) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadSearchData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriendData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFolderData object:nil];
                    }
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [APP_DELEGATE setLogOut:NO];
                        [OMGlobal setLogInUserDefault];
                    }];
                    
                }];
            }
            else
            {
                [OMGlobal showAlertTips:error.localizedDescription title:@"Google SignIn"];
            }
        }];
    }];
    

}

#pragma mark - Google Signin Delegate

- (void) signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if(!user) [OMGlobal showAlertTips:error.localizedDescription title:@"SignIn with Gmail"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self signInwithGoogleMail:user];
    
    NSLog(@"SignIn From Google...");
    //[[GIDSignIn sharedInstance] signOut];
}

- (void) signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    NSLog(@"GoogleSignIn Delegate: gmail SignIn disConnected");
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - GoogleUI Signin Delegate
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Google SignIn ViewController dismiss...");
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    //[[self navigationController] pushViewController:viewController animated:YES];
}

@end
