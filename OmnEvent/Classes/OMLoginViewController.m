//
//  OMLoginViewController.m
//  OmnEvent
//
//  Created by elance on 7/16/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMLoginViewController.h"

#import "OMAppDelegate.h"

@interface OMLoginViewController ()
{
    
    CGFloat tempValue;
    
}

@end

@implementation OMLoginViewController

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
//    [self setEdgesForExtendedLayout:UIRectEdgeTop];

//    [self initTxtFields];
    // Do any additional setup after loading the view.
    
    
    
    tempValue = constraintForHeight.constant;
    //Registering for keyboard Notification
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIKeyboard Delegate Methods

- (void)keyboardDidHide:(NSNotification *)_notification
{
    
}


- (void)keyboardWillHide:(NSNotification *)_notification
{
    [btnForLogin setHidden:NO];
    [btnForForgot setHidden:NO];
    constraintForHeight.constant = tempValue;
    
    [self.view layoutIfNeeded];
    
}

- (void)keyboardWillShow:(NSNotification *)_notification
{
    [btnForLogin setHidden:YES];
    [btnForForgot setHidden:YES];
    
    CGRect keyboardFrame = [_notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSLog(@"%f",tempValue - (self.view.frame.size.height - btnForLogin.frame.origin.y - keyboardFrame.size.height));

    constraintForHeight.constant = tempValue - (self.view.frame.size.height - btnForLogin.frame.origin.y - keyboardFrame.size.height);
    
    
    [self.view layoutIfNeeded];
    
    
}

- (void)keyboardDidShow:(NSNotification *)_notification
{
    
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:txtForUsername]) {
        
        textField.returnKeyType = UIReturnKeyNext;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyGo;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    if ([textField isEqual:txtForUsername]) {
        
        [txtForPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];        
        
        [self signIn];

    }
    return NO;
}

//Check empty field

- ( BOOL ) checkEmail
{
    BOOL            filter = YES ;
    NSString*       filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSString*       laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*" ;
    NSString*       emailRegex = filter ? filterString : laxString ;
    NSPredicate*    emailTest = [ NSPredicate predicateWithFormat : @"SELF MATCHES %@", emailRegex ] ;
    
    if( [emailTest evaluateWithObject : txtForUsername.text] == NO )
    {
        return NO ;
    }
    
    return YES ;
}

- (void)signIn
{
    if (![self validateTextFiels]) {
        
        return;
    }
    
    if (![self checkEmail]){
        [[[UIAlertView alloc] initWithTitle:@"Invalid Info!" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:txtForUsername.text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            return;
        }
        if (!objects || [objects count] == 0) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Wrong email. No user name please." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            return;
        }
        
        PFObject *userObj = [objects objectAtIndex:0];
        
        if ([userObj objectForKey:@"Status"])
        {
            BOOL status = [[userObj objectForKey:@"Status"] boolValue];
            if (!status)
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your account is suspended." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                return;
            }
        }
        [PFUser logInWithUsernameInBackground:[[userObj valueForKey:@"username"] lowercaseString] password:[txtForPassword.text lowercaseString] block:^(PFUser *user, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (!error) {
                if(user)
                {
                    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        NSLog(@"%@",object);
                        
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        [installation setObject:user forKey:@"user"];
                        [installation setObject:user.objectId forKey:@"userID"];

                        [installation saveEventually];

                        [OMGlobal setLogInUserDefault];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                        
                        if ([APP_DELEGATE logOut]) {
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadSearchData object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFriendData object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFolderData object:nil];
                        }
                        
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            
                            [APP_DELEGATE setLogOut:NO];
                            
                        }];

                    }];
                }
                else
                {
                    NSLog(@"User Fetch Error!!!");
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            }
        }];
    }];

    
}

- (BOOL)validateTextFiels
{
    if ([txtForUsername.text isEqualToString:@""] || [txtForPassword.text isEqualToString:@""]) {
        [OMGlobal showAlertTips:@"Please input right values." title:@"Invalid info!"];
        return NO;
    }
    
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)signInAction:(id)sender {
    
    [self signIn];
}

- (IBAction)forgotPasswordAction:(id)sender {
    
    
}

- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
