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

@interface OMDrawTextViewController ()<JotViewControllerDelegate>{
    float rColor, gColor, bColor;
}
@property (nonatomic, strong) JotViewController *jotViewController;

@property (weak, nonatomic) IBOutlet UIView *viewCanvas;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnText;

@property (weak, nonatomic) IBOutlet UISlider *sliderRed;
@property (weak, nonatomic) IBOutlet UISlider *sliderGreen;
@property (weak, nonatomic) IBOutlet UISlider *sliderBlue;
@property (weak, nonatomic) IBOutlet UIView *viewColor;

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
    self.jotViewController.drawingStrokeWidth = IS_IPAD?5.f: 3.f;
    self.jotViewController.textAlignment = NSTextAlignmentCenter;
    self.jotViewController.drawingColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];

    
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
    rColor = gColor = bColor = 0.5;
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
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
    
    _btnText.enabled = YES;
    _btnDraw.enabled = NO;
    
    [self switchColorsPenText];
}

- (IBAction)actionText:(id)sender {
    if (self.jotViewController.textString.length == 0) {
        self.jotViewController.state = JotViewStateEditingText;
    } else {
        self.jotViewController.state = JotViewStateText;
    }
    
    _btnDraw.enabled = YES;
    _btnText.enabled = NO;

    [self switchColorsPenText];
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

#pragma Color Change Actions
- (IBAction)redChangeAction:(id)sender {
    [self changeColorsPenAndText];
}
- (IBAction)greenChangeAction:(id)sender {
    [self changeColorsPenAndText];
}
- (IBAction)blueChangeAction:(id)sender {
    [self changeColorsPenAndText];
}

-(void)changeColorsPenAndText{
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
    
    if ( !_btnText.enabled) {
        self.jotViewController.textColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
    }
    if (!_btnDraw.enabled) {
        self.jotViewController.drawingColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
    }
}

-(void)switchColorsPenText{
    float rTemp = _sliderRed.value;
    float gTemp = _sliderGreen.value;
    float bTemp = _sliderGreen.value;
    
    _sliderRed.value = rColor;
    _sliderGreen.value = gColor;
    _sliderBlue.value = bColor;
    
    rColor = rTemp;
    gColor = gTemp;
    bColor = bTemp;
    
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
}
@end
