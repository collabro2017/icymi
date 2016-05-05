//
//  OMWelcomeViewController.m
//  Collabro
//
//  Created by Ellisa on 19/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMWelcomeViewController.h"

@interface OMWelcomeViewController ()

@end

@implementation OMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        //Session is open
        NSLog(@"Session opened");
    }
    else
    {
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginWithFBAction:(id)sender {
    
    NSArray *arrForPermission = @[@"email",@"user_friends"];
    
    //Login PFUser using FB
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [PFFacebookUtils logInWithPermissions:arrForPermission block:^(PFUser *user, NSError *error) {
        
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
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    
                    if ([APP_DELEGATE logOut])
                    {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadSearchData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriendData object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
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

@end
