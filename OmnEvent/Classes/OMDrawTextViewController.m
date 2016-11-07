//
//  OMDrawTextViewController.m
//  ICYMI
//
//  Created by lion on 11/6/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMDrawTextViewController.h"
@import AssetsLibrary;
#import <Masonry/Masonry.h>
#import <jot/jot.h>


@interface OMDrawTextViewController ()<JotViewControllerDelegate>
@property (nonatomic, strong) JotViewController *jotViewController;

@property (weak, nonatomic) IBOutlet UIView *viewCanvas;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnDrawText;


@end

@implementation OMDrawTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _jotViewController = [JotViewController new];
    
    self.jotViewController.delegate = self;
    self.jotViewController.state = JotViewStateDrawing;
    self.jotViewController.textColor = [UIColor blackColor];
    self.jotViewController.font = [UIFont boldSystemFontOfSize:24.f];
    self.jotViewController.fontSize = 24.f;
    self.jotViewController.textEditingInsets = UIEdgeInsetsMake(12.f, 6.f, 0.f, 6.f);
    self.jotViewController.initialTextInsets = UIEdgeInsetsMake(6.f, 6.f, 6.f, 6.f);
    self.jotViewController.fitOriginalFontSizeToViewWidth = YES;
    self.jotViewController.textAlignment = NSTextAlignmentLeft;
    self.jotViewController.drawingColor = [UIColor cyanColor];

    
    _viewCanvas.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGRect frame = _viewCanvas.frame;
    frame = CGRectMake(0, 0, IS_IPAD?768: 320,IS_IPAD?768: 320);
   
    _viewCanvas.frame = frame;
    UIGraphicsBeginImageContext(self.viewCanvas.frame.size);
    [_image drawInRect:self.viewCanvas.bounds];
    UIImage *tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.viewCanvas.backgroundColor = [UIColor clearColor]; 
    self.viewCanvas.backgroundColor = [UIColor colorWithPatternImage:tImage];
    
    
    //--------------------------------------------------------
    [self addChildViewController:self.jotViewController];
    [self.viewCanvas addSubview:self.jotViewController.view];
    
    [self.jotViewController didMoveToParentViewController:self];
    [self.jotViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.jotViewController.state == JotViewStateText) {
        self.jotViewController.state = JotViewStateEditingText;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Actions

- (IBAction)actionClear:(id)sender {
    [self.jotViewController clearAll];
}
- (IBAction)actionDrawText:(id)sender {
    if (self.jotViewController.state == JotViewStateDrawing) {
        [_btnDrawText setImage:[UIImage imageNamed:@"dt_text"] forState:UIControlStateNormal];
        
        if (self.jotViewController.textString.length == 0) {
            self.jotViewController.state = JotViewStateEditingText;
        } else {
            self.jotViewController.state = JotViewStateText;
        }
        
    } else if (self.jotViewController.state == JotViewStateText) {
        self.jotViewController.state = JotViewStateDrawing;
        self.jotViewController.drawingColor = [UIColor colorWithRed:((double)arc4random()/UINT32_MAX) green:((double)arc4random()/UINT32_MAX) blue:((double)arc4random()/UINT32_MAX) alpha:1.0];
        [_btnDrawText setImage:[UIImage imageNamed:@"dt_pencil"] forState:UIControlStateNormal];
    }
}

- (IBAction)actionCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dtViewControllerDidCancel:)]) {
        [self.delegate dtViewControllerDidCancel:self];
    }
}

- (IBAction)actionDone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dtViewController:didFinishDTImage:)]) {
        UIImage *drawnImage = [self.jotViewController renderImageWithScale:1.0f
                                                                   onColor:self.viewCanvas.backgroundColor];
        
        [self.delegate dtViewController:self didFinishDTImage:drawnImage];
    }
}
#pragma mark - JotViewControllerDelegate

- (void)jotViewController:(JotViewController *)jotViewController isEditingText:(BOOL)isEditing
{
    //Nothing
}

@end
