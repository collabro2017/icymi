//
//  OMEditProfileViewController.m
//  Collabro
//
//  Created by elance on 8/15/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMEditProfileViewControllers.h"

@interface OMEditProfileViewControllers ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    PFUser *currentUser;
    
    PFObject *obj;
    CGRect buttonFrame;
    CGRect pickerFrame;
    CGRect hiddenFrame;
    BOOL is_date;
}

@end

@implementation OMEditProfileViewControllers

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
    currentUser = [PFUser currentUser];
    [btnForDone setHidden:YES];

//    [countryPicker setHidden:YES];
    pickerFrame = countryPicker.frame;
    [countryPicker setFrame:CGRectMake(0, 568, 320, 162)];
    countryPicker.tag = 20;
    countryPicker.delegate = self;
    genderPicker.delegate = self;
    genderPicker.tag = 21;
    hiddenFrame = countryPicker.frame;
    genderPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 568, 320, 162)];
    [self.view addSubview:genderPicker];
    is_date = YES;
    txtForCountry.delegate = self;
    txtForGender.delegate = self;
    
//    [btnForDone setFrame:CGRectMake(self.view.frame.size.width - btnForDone.frame.size.width + 20,  , <#CGFloat width#>, <#CGFloat height#>)]
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];
}

- (void)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender
{
    
    currentUser[@"Firstname"] = txtForFirstName.text;
    currentUser[@"Lastname"] = txtForLastName.text;
    currentUser.email = txtForEmail.text;
    currentUser[@"Location"] = lblForCountry.text;
    currentUser[@"Gender"] = lblForGender.text;
    
    
    // Name , Gender, Age, City, State, Postal Code, Email , Profile Photo;
    
//    currentUser[@"Age"]
    
    
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadProfileInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProfileInfo
{
    txtForFirstName.text = currentUser[@"Firstname"];
    txtForLastName.text = currentUser[@"Lastname"];
    txtForEmail.text = currentUser.email;
    lblForCountry.text = currentUser[@"Location"];
    lblForGender.text = currentUser[@"Gender"];

    
}
#pragma mark Country Picker 
- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    lblForCountry.text = name;
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

- (IBAction)countrySelectAction:(id)sender {
    
    is_date = YES;
    [UIView animateWithDuration:0.2f animations:^{
        
        [countryPicker setFrame:pickerFrame];
        
    } completion:^(BOOL finished) {
        
        [btnForDone setHidden:NO];
        
    }];

}

- (IBAction)genderSelectAction:(id)sender {
    is_date = NO;
    [UIView animateWithDuration:0.2f animations:^{
        
        [genderPicker setFrame:pickerFrame];
        
    } completion:^(BOOL finished) {
        
        [btnForDone setHidden:NO];
        
    }];

}

- (IBAction)doneAction:(id)sender {
    
    if (is_date) {
        
        [UIView animateWithDuration:0.2f animations:^{
            
            [countryPicker setFrame:hiddenFrame];
            
        } completion:^(BOOL finished) {
            
            [btnForDone setHidden:YES];
            
        }];

    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            
            [genderPicker setFrame:hiddenFrame];
            
        } completion:^(BOOL finished) {
            
            [btnForDone setHidden:YES];
            
        }];

    }

}

#pragma mark UIPickerView
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if (pickerView.tag == 21) {
//        
//    }
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    if (pickerView.tag == 21) {
//        return 2;
//    }
//    return 0;
//}
//
////- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
////{
////    return 0;
////}
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (pickerView.tag == 21) {
//        if (row == 0) {
//            return @"Male";
//        }
//        else
//        {
//            return @"Female";
//        }
//    }
//    return @"";
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    return 0;
//}

@end
