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
#import "UIImage+Resize.h"

@interface OMDrawTextViewController ()<JotViewControllerDelegate>
@property (nonatomic, strong) JotViewController *jotViewController;

@property (weak, nonatomic) IBOutlet UIView *viewCanvas;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnText;


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
    self.jotViewController.drawingStrokeWidth = 5.f;
    self.jotViewController.textAlignment = NSTextAlignmentLeft;
    self.jotViewController.drawingColor = [UIColor cyanColor];

    
    //_viewCanvas.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

    _btnDraw.enabled = NO;
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
- (IBAction)actionDraw:(id)sender {
    
    self.jotViewController.state = JotViewStateDrawing;
    self.jotViewController.drawingColor = [UIColor colorWithRed:((double)arc4random()/UINT32_MAX) green:((double)arc4random()/UINT32_MAX) blue:((double)arc4random()/UINT32_MAX) alpha:1.0];
   
    _btnText.enabled = YES;
    _btnDraw.enabled = NO;
}

- (IBAction)actionText:(id)sender {
    if (self.jotViewController.textString.length == 0) {
        self.jotViewController.state = JotViewStateEditingText;
    } else {
        self.jotViewController.state = JotViewStateText;
    }
    
    _btnDraw.enabled = YES;
    _btnText.enabled = NO;
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
        UIImage *squareImage = [drawnImage resizedImageToSize:CGSizeMake(2000.f, 2000.f)];
        
        [self.delegate dtViewController:self didFinishDTImage:squareImage];
    }
}
#pragma mark - JotViewControllerDelegate

- (void)jotViewController:(JotViewController *)jotViewController isEditingText:(BOOL)isEditing
{
    //Nothing
}

@end
