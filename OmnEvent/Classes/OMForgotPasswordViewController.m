//
//  OMForgotPasswordViewController.m
//  Collabro
//
//  Created by elance on 8/21/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMForgotPasswordViewController.h"

@interface OMForgotPasswordViewController ()

@end

@implementation OMForgotPasswordViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetPassword
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser requestPasswordResetForEmailInBackground:txtForEmail.text block:^(BOOL succeeded, NSError *error) {

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Request sent successfully.\nPlease check your inbox." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        else
        {
            
        }
    }];
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)submitAction:(id)sender {
    
    [self resetPassword];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
