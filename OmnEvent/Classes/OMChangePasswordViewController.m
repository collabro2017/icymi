//
//  OMChangePasswordViewController.m
//  Collabro
//
//  Created by Ellisa on 17/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMChangePasswordViewController.h"

@interface OMChangePasswordViewController ()

@end

@implementation OMChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    //    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(uploadAction)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(updatePassword)];
    
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.title = @"Change Password";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Check Current Password is correct

- (void)checkCurrentPassword
{
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    indicator.center = CGPointMake(txtForCurrentPassword.frame.size.width - indicator.frame.size.width * 1.5f, txtForCurrentPassword.frame.size.height / 2);
    
    [txtForCurrentPassword addSubview:indicator];
    [indicator setHidesWhenStopped:YES];
    
    
    __block UIActivityIndicatorView *ind = indicator;
    [ind startAnimating];

    
    [PFUser logInWithUsernameInBackground:USER.username password:txtForCurrentPassword.text block:^(PFUser *user, NSError *error) {
        [ind stopAnimating];
        [ind removeFromSuperview];
        ind = nil;
        if (error) {
            
            [OMGlobal showAlertTips:@"Your password is wrong.Please try again." title:@"Oops!"];
            
            [txtForCurrentPassword becomeFirstResponder];
            
            return;
        }
        else
        {
            NSLog(@"%@",user);
        }
        
        
        
    }];
}
// Bar button Actions

- (void)updatePassword
{
    USER.password = txtForNewPassword.text;
    
    [USER saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            [OMGlobal showAlertTips:@"Your password has been changed successfully." title:nil];            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:txtForCurrentPassword]) {
       
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if ([textField isEqual:txtForNewPassword])
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyDone;
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:txtForCurrentPassword]) {
        
        [self checkCurrentPassword];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:txtForCurrentPassword]) {
        
        [txtForNewPassword becomeFirstResponder];
    }
    else if ([textField isEqual:txtForNewPassword])
    {
        [txtForConfirmPassword becomeFirstResponder];
    }
    else
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
    
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
        default:
            break;
    }
    // Return the number of rows in the section.
    return 0;
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
