//
//  OMSignUpViewController.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMSignUpViewController.h"

@interface OMSignUpViewController ()
{
    CGFloat tempValue;
    
    UITextField *flagTextField;
    
    CGRect keyboardRect;
    
    BOOL isKeyboardShown;
}

@end

@implementation OMSignUpViewController

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
    picker = [[UIImagePickerController alloc] init];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [imgViewForAvatar addGestureRecognizer:gesture];
    [OMGlobal setCircleView:imgViewForAvatar borderColor:[UIColor greenColor]];
    // Do any additional setup after loading the view.
    
    tempValue = constraintForTopspace.constant;
    
    //Registering for keyboard Notification
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    if (IS_IPAD) {
        self.contraintLeft.constant = self.contraintRight.constant = 150;
        self.contrainTop.constant = 100;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - UIKeyboard Delegate Methods

- (void)keyboardDidHide:(NSNotification *)_notification
{
    isKeyboardShown = NO;
}


- (void)keyboardWillHide:(NSNotification *)_notification
{

    constraintForTopspace.constant = tempValue;
    
    [self.view layoutIfNeeded];
    
}

- (void)keyboardWillShow:(NSNotification *)_notification
{
    
    CGFloat delta = 0;
    
    CGRect keyboardFrame = [_notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardRect = keyboardFrame;
    
    if ([flagTextField isEqual:txtForEmail] || [flagTextField isEqual:txtForUsername] || [flagTextField isEqual:txtForPassword]) {
        delta = self.view.frame.size.height - viewForHead.frame.size.height - viewForHead.frame.origin.y - keyboardFrame.size.height;
        NSLog(@"%f",delta);
        constraintForTopspace.constant = tempValue + delta;

    }
    else
    {
        delta = self.view.frame.size.height - viewForBottom.frame.size.height - viewForBottom.frame.origin.y - keyboardFrame.size.height;
        NSLog(@"%f",delta);
        constraintForTopspace.constant = tempValue + delta;

    }
    [self.view layoutIfNeeded];
    
    
}

- (void)keyboardDidShow:(NSNotification *)_notification
{
    isKeyboardShown = YES;
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    flagTextField = textField;
    if (isKeyboardShown) {
        
        CGFloat delta = 0;
        
        if ([textField isEqual:txtForEmail] || [textField isEqual:txtForUsername] || [textField isEqual:txtForPassword]) {
            
//            delta = self.view.frame.size.height - viewForHead.frame.size.height - viewForHead.frame.origin.y - keyboardRect.size.height;
            
            delta = self.view.frame.size.height - viewForHead.frame.size.height - constraintForTopspace.constant - keyboardRect.size.height;

            NSLog(@"%f",delta);
            constraintForTopspace.constant = tempValue + delta;
            [self.view layoutIfNeeded];
            
            
        }
        else
        {
            delta = self.view.frame.size.height - viewForBottom.frame.size.height - viewForBottom.frame.origin.y - keyboardRect.size.height;
            NSLog(@"%f",delta);
            constraintForTopspace.constant = tempValue + delta;
            [self.view layoutIfNeeded];
            
            
        }

        
    }
    
    

  
    
//    if ([textField isEqual:txtForEmail]) {
//        
//        
//        
//    }
//    else if ([textField isEqual:txtForUsername])
//    {
//        
//    }
//    else if ([textField isEqual:txtForPassword])
//    {
//        
//    }
//    else if ([textField isEqual:txtForFirstname])
//    {
//        
//    }
//    else if ([textField isEqual:txtForLastname])
//    {
//        
//    }
    
    
    
    
    if ([textField isEqual:txtForLastname]) {
        
        textField.returnKeyType = UIReturnKeyDone;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    if ([textField isEqual:txtForEmail]) {
        
        [txtForUsername becomeFirstResponder];
        flagTextField = txtForUsername;

    }
    else if ([textField isEqual:txtForUsername])
    {
        [txtForPassword becomeFirstResponder];
        flagTextField = txtForPassword;

    }
    else if ([textField isEqual:txtForPassword])
    {
        [txtForFirstname becomeFirstResponder];
        flagTextField = txtForFirstname;

    }
    else if ([textField isEqual:txtForFirstname])
    {
        [txtForLastname becomeFirstResponder];
        flagTextField = txtForLastname;

    }
    else if ([textField isEqual:txtForLastname])
    {
        [textField resignFirstResponder];

    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Junaid: Force the user to add only lower-case letters for email
    if (textField == txtForEmail) {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string lowercaseString]];
            return NO;
        }
    }
    
    return YES;
}

//Check empty field

- (BOOL)validateInputInView
{
    
    if ([txtForEmail.text isEqualToString:@""] || [txtForUsername.text isEqualToString:@""] || [txtForPassword.text isEqualToString:@""] || [txtForFirstname.text isEqualToString:@""] || [txtForLastname.text isEqualToString:@""]) {
        
        
        return NO;
    }
    return YES;
}

- (void)tapAvatar:(UIGestureRecognizer*)_gesture
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose from album.",nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
        {
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            [self presentViewController:picker animated:YES completion:nil];

            
            
            break;
        }
        case 1:
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];

            break;
        }
        default:
            break;
    }
    
}


#pragma mark-UIImagePickerController  Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    avatarImg = [info objectForKey:UIImagePickerControllerEditedImage];
    [imgViewForAvatar setImage:avatarImg];
    
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)_picker
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)registerAction:(id)sender {
    
    if (![self validateInputInView]) {
        [OMGlobal showAlertTips:@"Please input right values." title:@"Invalid info!"];
        return;
    }
    
    if ([txtForUsername.text rangeOfString:@" "].location != NSNotFound){
        [OMGlobal showAlertTips:@"Please input right values. Username should not include blank." title:@"Invalid info!"];
        return;
    }
    
    if (!avatarImg) {
        [OMGlobal showAlertTips:@"Please select your avatar." title:@"Oops!"];
        return;
    }
    
    if (![self checkEmail]){
        [[[UIAlertView alloc] initWithTitle:@"Invalid Info!" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"_Role"];
    [query getObjectInBackgroundWithId:@"XVr1sAmAQl" block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        PFUser *user = [[PFUser alloc] init];
        [user setUsername:txtForUsername.text];
        [user setEmail:txtForEmail.text.lowercaseString];
        [user setPassword:txtForPassword.text];
        user[@"loginType"] = @"email";
        user[@"user_type"] = object;
        
        PFFile *postFile = [PFFile fileWithName:@"avatar.jpg" data:UIImageJPEGRepresentation(avatarImg, 0.7)];
        user[@"ProfileImage"] = postFile;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (succeeded) {
                PFInstallation *installation = [PFInstallation currentInstallation];
                [installation setObject:user forKey:@"user"];
                [installation setObject:user.objectId forKey:@"userID"];
                [installation saveEventually];
                [OMGlobal showAlertTips:@"Please verify your email address." title:@"Successfully signed up."];
                [self.navigationController popViewControllerAnimated:YES];

//                [OMGlobal setLogInUserDefault];
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                
            }
            else
            {
                //@"Failed to Sign Up!"
                [OMGlobal showAlertTips:[error localizedDescription] title:@"Failed to Sign Up!"];
            }
        }];
    }];
    
    //Request a background execution task to allow us to finish uploading the photo even if the app is background
    
}

- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- ( BOOL ) checkEmail
{
    BOOL            filter = YES ;
    NSString*       filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSString*       laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*" ;
    NSString*       emailRegex = filter ? filterString : laxString ;
    NSPredicate*    emailTest = [ NSPredicate predicateWithFormat : @"SELF MATCHES %@", emailRegex ] ;
    
    if( [emailTest evaluateWithObject : txtForEmail.text] == NO )
    {
        return NO ;
    }
    
    return YES ;
}

@end
