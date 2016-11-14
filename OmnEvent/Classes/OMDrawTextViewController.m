//
//  OMDrawTextViewController.m
//  ICYMI
//
//  Created by lion on 11/6/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMDrawTextViewController.h"

@interface OMDrawTextViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewCanvas;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;

@property (weak, nonatomic) IBOutlet UISlider *sliderRed;
@property (weak, nonatomic) IBOutlet UISlider *sliderGreen;
@property (weak, nonatomic) IBOutlet UISlider *sliderBlue;
@property (weak, nonatomic) IBOutlet UIView *viewColor;

@end

@implementation OMDrawTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [(JCDrawView*)[self viewCanvas] setPreviousPoint:CGPointZero];
    [(JCDrawView*)[self viewCanvas] setPrePreviousPoint:CGPointZero];
    
    [(JCDrawView*)[self viewCanvas] setLineWidth:IS_IPAD?1.0:0.25];
    
    [[(JCDrawView*)[self viewCanvas] drawImageView1] setImage:_image];
    
    [(JCDrawView*)[self viewCanvas] setCurrentColor:[UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f]];
    
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Actions

- (IBAction)actionClear:(id)sender {
     [[(JCDrawView*)[self viewCanvas] drawImageView1] setImage:_image];
}


- (IBAction)actionCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dtViewControllerDidCancel:)]) {
        [self.delegate dtViewControllerDidCancel:self];
    }
}

- (IBAction)actionDone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dtViewController:didFinishDTImage:)]) {
        
        UIImage *squareImage = [(JCDrawView *)[self viewCanvas] image];
        [self.delegate dtViewController:self didFinishDTImage:squareImage];
    }
}

#pragma Color Change Actions
- (IBAction)redChangeAction:(id)sender {
    [self changeColors];
}
- (IBAction)greenChangeAction:(id)sender {
    [self changeColors];
}
- (IBAction)blueChangeAction:(id)sender {
    [self changeColors];
}

-(void)changeColors{
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
   
    [(JCDrawView*)[self viewCanvas] setCurrentColor:[UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f]];

}

@end
