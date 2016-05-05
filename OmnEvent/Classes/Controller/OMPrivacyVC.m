//
//  OMPrivacyVC.m
//  Collabro
//
//  Created by JinHua on 6/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMPrivacyVC.h"

@interface OMPrivacyVC ()<UIWebViewDelegate>
{
    
    IBOutlet UIWebView *webView;
    
    
}

@end

@implementation OMPrivacyVC

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
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];

    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    self.title = @"Privacy Policy";


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PrivacyPolicy" ofType:@"docx"];
    
    NSURL *targetUrl = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetUrl];
    
    [webView loadRequest:request];
    
    webView.scalesPageToFit = YES;
    
}

- (void)backAction
{
    
        
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
