//
//  OMEditProfileViewController.m
//  Collabro
//
//  Created by Ellisa on 31/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMEditProfileViewController.h"
#import "UIImage+Resize.h"
@interface OMEditProfileViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView *sexPicker;
    
    UIView *customSexPickerView;
    CGRect rectForCustomPickerView;
    
    UIPickerView *visibilityPicker;
    UIView *customVisibilityPickerView;
    CGRect rectForCustomVisibilityPickerView;
    
    UIPickerView *securityPicker;
    UIView *customSecurityPickerView;
    CGRect rectForCustomSecurityPickerView;
    
    NSMutableArray *arrayForSecurity;
    
}

@end

@implementation OMEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self initializeNavigationBar];
    [self initializeControls];
    [self displayUserInfo];
    
    [self addDoneToolBarToKeyboard:txtForPostalCode];
    [self addDoneToolBarToKeyboard:txtForAge];
    [self addDoneToolBarToKeyboard:txtForPhonenumber];

    arrayForSecurity = [NSMutableArray array];
    pfSelQuery = nil;
    [self loadSecurityQuestions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)initializeControls
{
    
    avatarChanged = NO;
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setDelegate:self];
    //
    customSexPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 200, self.view.frame.size.width, 150 + 40  )];
    
    rectForCustomPickerView = customSexPickerView.frame;
    
    sexPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 150)];
    sexPicker.delegate = self;
    sexPicker.tag = 100;
    [sexPicker setBackgroundColor:[UIColor lightGrayColor]];
    [customSexPickerView addSubview:sexPicker];
    
    customVisibilityPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 250, self.view.frame.size.width, 200 + 40)];
    
    rectForCustomVisibilityPickerView = customVisibilityPickerView.frame;
    
    visibilityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 200)];
    visibilityPicker.delegate = self;
    visibilityPicker.tag = 101;
    [visibilityPicker setBackgroundColor:[UIColor lightGrayColor]];
    [customVisibilityPickerView addSubview:visibilityPicker];
    
    customSecurityPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 200, self.view.frame.size.width, 150 + 40  )];
    
    rectForCustomSecurityPickerView = customSecurityPickerView.frame;
    
    securityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 150)];
    securityPicker.delegate = self;
    securityPicker.tag = 102;
    [securityPicker setBackgroundColor:[UIColor lightGrayColor]];
    [customSecurityPickerView addSubview:securityPicker];
    
    UIToolbar *doneToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar.barStyle = UIBarStyleDefault;
    
    doneToolBar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissPickerView)], nil];
    
    [doneToolBar sizeToFit];
    
    [customSexPickerView addSubview:doneToolBar];
    
    UIToolbar *doneToolBar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar1.barStyle = UIBarStyleDefault;
    
    doneToolBar1.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissVisibilityPickerView)], nil];
    
    [doneToolBar1 sizeToFit];
    
    [customVisibilityPickerView addSubview:doneToolBar1];
    
    UIToolbar *doneToolBar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar2.barStyle = UIBarStyleDefault;
    
    doneToolBar2.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissSecurityPickerView)], nil];
    
    [doneToolBar2 sizeToFit];
    
    [customSecurityPickerView addSubview:doneToolBar2];
    
    [self.navigationController.view addSubview:customSexPickerView];
    [self.navigationController.view addSubview:customVisibilityPickerView];
    [self.navigationController.view addSubview:customSecurityPickerView];
}

- (void)initializeNavigationBar
{
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backAction)];
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                     target:self
                                                                                     action:@selector(saveProfileInfo)];
  
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, uploadBarButton,nil];
    
    self.title = @"Edit Profile";

}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayUserInfo
{
    
    if ([USER[@"loginType"] isEqualToString:@"email"] || [USER[@"loginType"] isEqualToString:@"gmail"]) {
        
        PFFile *avatarFile = (PFFile *)USER[@"ProfileImage"];
        
        if (avatarFile) {
            
            [imageViewForAvatar setImageWithURL:[NSURL URLWithString:avatarFile.url] placeholderImage:nil];
            
        }
       
    }
    else if ([USER[@"loginType"] isEqualToString:@"facebook"])
    {
        
        [imageViewForAvatar setImageWithURL:[NSURL URLWithString:USER[@"profileURL"]] placeholderImage:nil];
        
    }
    
    if ([USER objectForKey:@"name"]) {
        txtForName.text = [USER objectForKey:@"name"];
    }
    
    txtForUsername.text = USER.username;
    
    if (USER.email) {
        
        txtForEmail.text = USER.email;
    }
    
    if ([USER objectForKey:@"Bio"]) {
        
        txtForGender.text = [USER objectForKey:@"Bio"];
    }

    
    
    if ([USER objectForKey:@"Gender"]) {
        
        txtForGender.text = [USER objectForKey:@"Gender"];
    }
    if ([USER objectForKey:@"Age"]) {
        
        txtForAge.text = [USER objectForKey:@"Age"];
    }
    if ([USER objectForKey:@"City"]) {
        
        txtForCity.text = [USER objectForKey:@"City"];
    }
    if ([USER objectForKey:@"State"]) {
        
        txtForState.text = [USER objectForKey:@"State"];
    }
    if ([USER objectForKey:@"zipcode"]) {
        
        txtForPostalCode.text = [USER objectForKey:@"zipcode"];
    }
    if ([USER objectForKey:@"phone"]) {
        
        txtForPhonenumber.text = [USER objectForKey:@"phone"];
    }
    if ([USER objectForKey:@"country"]) {
        
        txtForCountry.text = [USER objectForKey:@"country"];
    }
    if ([USER objectForKey:@"visibility"])
    {
        txtForVisiblity.text = [USER objectForKey:@"visibility"];
    }
    if ([USER objectForKey:@"Query"])
    {
        NSLog(@"USER Query = %@", [USER objectForKey:@"Query"]);
        
        PFQuery *queryForSecurity = [PFQuery queryWithClassName:@"SecurityQuestions"];
        [queryForSecurity whereKey:@"objectId" equalTo:[USER objectForKey:@"Query"]];
        [queryForSecurity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects == nil || [objects count] == 0) {
                
                //            [OMGlobal showAlertTips:@"You have had not any following yet. Please post new one." title:nil];
                
                
                return;
            }
            if (!error) {
                
                PFObject* pfSec = (PFObject* )[objects objectAtIndex:0];
                txtForSecurity.text = [pfSec objectForKey:@"Query"];
            }
        }];

    
        txtForAnswer.text = [USER objectForKey:@"Answer"];
    }
}

- (void)saveProfileInfo
{
//    USER.username = txtForUsername.text;
    USER.email = txtForEmail.text;
    USER[@"Gender"] = txtForGender.text;
    USER[@"name"] = txtForName.text;
    USER[@"Age"] = txtForAge.text;
    USER[@"City"] = txtForCity.text;
    USER[@"Bio"] = txtForBio.text;
    USER[@"State"] = txtForState.text;
    USER[@"zipcode"] = txtForPostalCode.text;
    USER[@"country"] = txtForCountry.text;
    USER[@"phone"] = txtForPhonenumber.text;
    USER[@"visibility"] = txtForVisiblity.text;
    if(pfSelQuery != nil) USER[@"Query"] =  pfSelQuery.objectId;
    USER[@"Answer"] = txtForAnswer.text;
    
    if (changedAvatarImage) {
        
        PFFile *avatarPhoto = [PFFile fileWithName:@"avatar.jpg" data:UIImageJPEGRepresentation(changedAvatarImage, 0.7)];
        USER[@"ProfileImage"] = avatarPhoto;
    }
    
    [MBProgressHUD showMessag:@"Updating..." toView:self.view];
    [USER saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (succeeded) {
            
            NSLog(@"Updated Successfully");
            [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFeedData object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadProfileData object:nil];

                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                    }];

                    
                }
                
            }];
            
                 }
        else if (error)
        {
            NSLog(@"Profile Update Error: %@", error);
            [OMGlobal showAlertTips:@"Failed to update Profile." title:@"Oops!"];
        }
        
    }];
}

- (void)changeAvatar
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"From Album", nil];
    
    [actionSheet showInView:self.view];
    
    
    
}

-(void)showImagePickerView
{
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showGenderPickerView
{
    
    [UIView animateWithDuration:0.2f animations:^{
       
        [customSexPickerView setFrame:CGRectMake(customSexPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - customSexPickerView.frame.size.height, customSexPickerView.frame.size.width, customSexPickerView.frame.size.height)];

        
    } completion:^(BOOL finished) {
        
        
        
    }];
    

}

- (void)showVisibilityPickerView
{
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [customVisibilityPickerView setFrame:CGRectMake(customVisibilityPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - customVisibilityPickerView.frame.size.height, customVisibilityPickerView.frame.size.width, customVisibilityPickerView.frame.size.height)];
        
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
    
}

- (void)showSecurityPickerView
{
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [customSecurityPickerView setFrame:CGRectMake(customSecurityPickerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - customSecurityPickerView.frame.size.height, customSecurityPickerView.frame.size.width, customSecurityPickerView.frame.size.height)];
        
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
    
}



- (void)doneButtonClikedDismissPickerView
{
    [UIView animateWithDuration:0.2f animations:^{
      
        [customSexPickerView setFrame:rectForCustomPickerView];
        
    } completion:^(BOOL finished) {        
        
        
    }];

}

- (void)doneButtonClikedDismissVisibilityPickerView
{
    [UIView animateWithDuration:0.2f animations:^{
        
        
        [customVisibilityPickerView setFrame:rectForCustomVisibilityPickerView];
        
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
}

- (void)doneButtonClikedDismissSecurityPickerView
{
    [UIView animateWithDuration:0.2f animations:^{
        
        
        [customSecurityPickerView setFrame:rectForCustomSecurityPickerView];
        
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
}


- (void)addDoneToolBarToKeyboard:(UITextField *)_textField
{
    UIToolbar *doneToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolBar.barStyle = UIBarStyleBlackTranslucent;
    
    doneToolBar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClikedDismissKeyboard)], nil];
    
    [doneToolBar sizeToFit];
    _textField.inputAccessoryView = doneToolBar;
}

- (void)doneButtonClikedDismissKeyboard
{
 
    if ([txtForAge isFirstResponder]) {
        
        [txtForAge resignFirstResponder];
        
    }
    else if ([txtForPostalCode isFirstResponder])
        [txtForPostalCode resignFirstResponder];
    else if ([txtForPhonenumber isFirstResponder])
        [txtForPhonenumber resignFirstResponder];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int nItCount = 0;
    if (pickerView.tag == 100)
        nItCount = 3;
    else if (pickerView.tag == 101)
        nItCount = 4;
    else
        nItCount = [arrayForSecurity count];
    
    return nItCount;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 100)
    {
    switch (row) {
        case 0:
            return @"No Match";
            break;
        case 1:
            return @"Male";
            break;
        case 2:
            return @"Female";
            break;
            
        default:
            break;
    }
    }
    else if (pickerView.tag == 101)
    {
        switch (row) {
            case 0:
                return @"Public";
                break;
            case 1:
                return @"Friend only";
                break;
            case 2:
                return @"Private";
                break;
            case 3:
                return @"Hidden";
                break;
                
            default:
                break;
        }
    }
    else
    {
        PFObject* pfSecurity = [arrayForSecurity objectAtIndex:row];
        return pfSecurity[@"Query"];
    }

    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 100)
    {
    switch (row) {
        case 0:
        {
            txtForGender.text = @"No Match";
            
        }
            break;
        case 1:
        {
            [txtForGender setText:@"Male"];
        }
            
            break;
        case 2:
        {
            [txtForGender setText:@"Female"];
        }
            break;
            
        default:
            break;
    }
    }
    else if (pickerView.tag == 101)
    {
        switch (row) {
            case 0:
            {
                txtForVisiblity.text = @"Public";
                
            }
                break;
            case 1:
            {
                [txtForVisiblity setText:@"Friend only"];
            }
                
                break;
            case 2:
            {
                [txtForVisiblity setText:@"Private"];
            }
                break;
            case 3:
            {
                [txtForVisiblity setText:@"Hidden"];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        pfSelQuery = [arrayForSecurity objectAtIndex:row];
        [txtForSecurity setText:pfSelQuery[@"Query"]];
    }

}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                
                [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
                
            }
        }
            break;
        case 1:
        {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];

        }
            break;
        default:
            break;
    }
    
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    image = [image resizedImageToSize:CGSizeMake(AVATAR_SIZE, AVATAR_SIZE)];
    
    avatarChanged = YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
       
        [imageViewForAvatar setImage:image];
        changedAvatarImage = image;
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    avatarChanged = NO;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:txtForName]) {
        
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForEmail])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForBio])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }

    else if ([textField isEqual:txtForGender])
    {
        [textField resignFirstResponder];
        [self showGenderPickerView];
    }
    else if ([textField isEqual:txtForAge])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForCity])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForState])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForPostalCode])
    {
        textField.returnKeyType = UIReturnKeyDone;
    }
    else if ([textField isEqual:txtForCountry])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForPhonenumber])
    {
        textField.returnKeyType = UIReturnKeyDone;
    }
    else if ([textField isEqual:txtForVisiblity])
    {
        [textField resignFirstResponder];
        [self showVisibilityPickerView];
    }
    else if ([textField isEqual:txtForSecurity])
    {
        [textField resignFirstResponder];
        [self showSecurityPickerView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([textField isEqual:txtForName]) {

        [txtForEmail becomeFirstResponder];
    }
    else if ([textField isEqual:txtForEmail])
    {
        [txtForBio becomeFirstResponder];

    }
    else if ([textField isEqual:txtForBio])
    {
        [txtForGender becomeFirstResponder];
        
    }

    else if ([textField isEqual:txtForGender])
    {
    }
    else if ([textField isEqual:txtForAge])
    {
        [txtForCity becomeFirstResponder];
    }
    else if ([textField isEqual:txtForCity])
    {
        [txtForState becomeFirstResponder];
    }
    else if ([textField isEqual:txtForState])
    {
        [txtForPostalCode becomeFirstResponder];
    }
    else if ([textField isEqual:txtForPostalCode])
    {
        [txtForCountry becomeFirstResponder];
    }
    else if ([textField isEqual:txtForCountry])
    {
        [txtForPhonenumber becomeFirstResponder];
    }
    else if ([textField isEqual:txtForPhonenumber])
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 15;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            [self changeAvatar];
        }
            break;
        case 1:
        {
            if (indexPath.row == 3) {
                
                [self performSegueWithIdentifier:@"kIdentifierChangePassword" sender:nil];
            }
            else if (indexPath.row == 4)
            {
                
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark Security Questions

-(void) loadSecurityQuestions
{
    PFQuery *queryForSecurity = [PFQuery queryWithClassName:@"SecurityQuestions"];
    [queryForSecurity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects == nil || [objects count] == 0) {
            
            //            [OMGlobal showAlertTips:@"You have had not any following yet. Please post new one." title:nil];
            
            
            return;
        }
        if (!error) {

            [arrayForSecurity removeAllObjects];
            [arrayForSecurity addObjectsFromArray:objects];
            
            [securityPicker reloadAllComponents];

        }
    }];
    

}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
