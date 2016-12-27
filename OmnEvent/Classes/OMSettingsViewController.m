//
//  OMSettingsViewController.m
//  Collabro
//
//  Created by Ellisa on 17/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMSettingsViewController.h"

@interface OMSettingsViewController ()

@end

@implementation OMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
//    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(uploadAction)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, uploadBarButton,nil];
    
    self.title = @"SETTINGS";
    
    [self displayInfo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)displayInfo
{
    if ([USER[@"loginType"] isEqualToString:@"email"] || [USER[@"loginType"] isEqualToString:@"gmail"]) {
        
        PFFile *avatarFile = (PFFile *)USER[@"ProfileImage"];
        
        if (avatarFile) {
            
            [imageViewForAvatar setImageWithURL:[NSURL URLWithString:avatarFile.url] placeholderImage:nil];
            
        }
        else if ([USER[@"loginType"] isEqualToString:@"facebook"])
        {
            
            [imageViewForAvatar setImageWithURL:[NSURL URLWithString:USER[@"profileURL"]] placeholderImage:nil];
            
        }
        
        
    }
    
    lblForUsername.text = USER.username;

}

- (void)backAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)signOut
{
    OMAppDelegate *appDelegate = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        OMAppDelegate *appDel = (OMAppDelegate *)[UIApplication sharedApplication].delegate;
        FTTabBarController *tab = [appDel tabBarController];
        [tab signOut];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 6;
            break;
        case 2:
            return 1;
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
            [self performSegueWithIdentifier:@"kIdentifierToEditProfile" sender:nil];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [self supportOurApp];
                }
                    break;
                case 1:
                {
                    [self showTermsAndConditions];
                }
                    break;
                case 2:
                {
                    [self rateOurApp];
                }
                    break;
                case 3:
                {
                    [self aboutOurApp];
                }
                    break;
                case 4:
                {
                    [self suspendAccount];
                }
                    break;
                case 5:
                {
                    [self deleteAccount];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            [self signOut];
        }
            break;
        default:
            break;
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles: nil];
        [alert show];
    }/* else {
      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Mail transfered successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [self dismissViewControllerAnimated:YES completion:nil];
      } */
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)supportOurApp
{
    //support@icymi-incaseyoumissedit.com
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setToRecipients:[NSArray arrayWithObject:@"support@icymi-incaseyoumissedit.com"]];
//        [mailView setSubject:currentObject[@"eventname"]];
//        [mailView setMessageBody:[NSString stringWithFormat:@"You are invited to join Collabro and %@ by %@!", currentObject[@"eventname"], USER.username ] isHTML:YES];
        
        //        UIImage *newImage = self.detail_imgView.image;
        
//        NSData *attachmentData = UIImageJPEGRepresentation(postImgView.image, 1.0);
//        [mailView addAttachmentData:attachmentData mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [self.navigationController presentViewController:mailView animated:YES completion:nil];
        //        [mailView release];
        
    }
}

- (void)showTermsAndConditions {
    [self performSegueWithIdentifier:@"TermsSegue" sender:nil];
}

- (void)rateOurApp
{
    NSString* strBaseUrl = @"";
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        strBaseUrl = @"itms-apps://itunes.apple.com/app/id%@";
    }
    else {
        strBaseUrl = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
    
    NSString* url = [NSString stringWithFormat:strBaseUrl, APP_ID];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url ]];
    
}

- (void)aboutOurApp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.icymi-incaseyoumissedit.com"]];
    
}

- (void) suspendAccount
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Critical" message:@"Do you want really to suspend your account?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    alert.tag = 1000;
    alert.delegate = self;
    [alert show];
}

-(void) deleteAccount
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Critical" message:@"Do you want really to delete your account?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    alert.tag = 1001;
    alert.delegate = self;
    [alert show];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 1000) && (buttonIndex == 0))
    {
        NSLog(@"Your account is suspended");
        
        USER[@"Status"] = @NO;
        
        [MBProgressHUD showMessag:@"Suspending..." toView:self.view];
        [USER saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (succeeded) {
                
                NSLog(@"Updated Successfully");
                [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if (!error) {

                        [self signOut];
                    }
                    
                }];
                
            }
            else if (error)
            {
                NSLog(@"Profile Update Error: %@", error);
                [OMGlobal showAlertTips:@"Failed to suspend Profile." title:@"Oops!"];
            }
            
        }];
        
    }
    else if ((alertView.tag == 1001) && (buttonIndex == 0))
    {
        NSLog(@"Your account is deleted");
        
 
        [self signOut];

        [MBProgressHUD showMessag:@"Deleting..." toView:self.view];

        [USER deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (succeeded) {
                
                NSLog(@"Deleted Successfully");
                        
                
            }
            else if (error)
            {
                NSLog(@"Profile Deleteing Error: %@", error);
                [OMGlobal showAlertTips:@"Failed to delete Profile." title:@"Oops!"];
            }
            
        }];
        
    }
}


@end
