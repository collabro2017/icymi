//
//  OMTermsAndConditionsViewController.m
//  ICYMI
//
//  Created by Muhammad Junaid Butt on 27/12/2016.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMTermsAndConditionsViewController.h"

@interface OMTermsAndConditionsViewController ()

@end

@implementation OMTermsAndConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Terms & Conditions";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:
                                      UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    //Set up the text in the text view
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64);
    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"terms_and_conditions" ofType:@"txt"];
    NSString *privacyPolicyText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[privacyPolicyText dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    textView.attributedText = attributedString;
    textView.editable = NO;
    textView.selectable = NO;
    
    [self.view addSubview:textView];
}

- (void)backAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
