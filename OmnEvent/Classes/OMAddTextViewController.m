//
//  OMAddTextViewController.m
//  ICYMI
//
//  Created by lion on 11/12/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import "OMAddTextViewController.h"
#import "IQLabelView.h"

@interface OMAddTextViewController ()<IQLabelViewDelegate>{
    IQLabelView *currentlyEditingLabel;
    NSMutableArray *labels;
}

@property (weak, nonatomic) IBOutlet UISlider *sliderRed;
@property (weak, nonatomic) IBOutlet UISlider *sliderGreen;
@property (weak, nonatomic) IBOutlet UISlider *sliderBlue;
@property (weak, nonatomic) IBOutlet UIView *viewColor;
@property (weak, nonatomic) IBOutlet UIImageView *imagePicture;


@property (nonatomic, strong) NSArray *colors;
@end

@implementation OMAddTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imagePicture.image = _image;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *)visibleImage
{
    UIGraphicsBeginImageContextWithOptions(self.imagePicture.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGRectGetMinX(self.imagePicture.frame), -CGRectGetMinY(self.imagePicture.frame));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *visibleViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return visibleViewImage;
}

#pragma mark - Custom Actions
- (IBAction)actionCancel:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(atViewControllerDidCancel:)]) {
        [self.delegate atViewControllerDidCancel:self];
    }
    
}

- (IBAction)actionDone:(id)sender {
    //hide editing status.
    [currentlyEditingLabel hideEditingHandles];
    if ([self.delegate respondsToSelector:@selector(dtViewController:didFinishDTImage:)]) {
                
        [self.delegate atViewController:self didFinishDTImage:[self visibleImage]];
    }
    
}
- (IBAction)addTextAction:(id)sender {
    [self addLabel];
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
    if (currentlyEditingLabel != nil) {
        currentlyEditingLabel.textColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
    }
    _viewColor.backgroundColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];   
}


- (void)addLabel
{
    [currentlyEditingLabel hideEditingHandles];
    CGRect labelFrame = CGRectMake(CGRectGetMidX(self.imagePicture.frame) - arc4random() % 20,
                                   CGRectGetMidY(self.imagePicture.frame) - arc4random() % 20,
                                   60, 50);
    
    IQLabelView *labelView = [[IQLabelView alloc] initWithFrame:labelFrame];
    [labelView setDelegate:self];
    [labelView setShowsContentShadow:NO];
    [labelView setEnableMoveRestriction:YES];
    [labelView setFontName:@"Helvetica Neue"];
    if (IS_IPAD) {
        [labelView setFontSize:26.0];
    }else
        [labelView setFontSize:20.0];
    
    
    [self.imagePicture addSubview:labelView];
    [self.imagePicture setUserInteractionEnabled:YES];
    
    [labelView setAttributedPlaceholder:[[NSAttributedString alloc]
                                         initWithString:NSLocalizedString(@"Placeholder", nil)
                                         attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] }]];
    
    currentlyEditingLabel = labelView;
    currentlyEditingLabel.textColor = [UIColor colorWithRed:_sliderRed.value green:_sliderGreen.value blue:_sliderBlue.value alpha:1.f];
    [labels addObject:labelView];
  
}

#pragma mark - Gesture

- (void)touchOutside:(UITapGestureRecognizer *)touchGesture
{
    [currentlyEditingLabel hideEditingHandles];
}

#pragma mark - IQLabelDelegate

- (void)labelViewDidClose:(IQLabelView *)label
{
    // some actions after delete label
    [labels removeObject:label];
}

- (void)labelViewDidBeginEditing:(IQLabelView *)label
{
    // move or rotate begin
}

- (void)labelViewDidShowEditingHandles:(IQLabelView *)label
{
    // showing border and control buttons
    currentlyEditingLabel = label;
}

- (void)labelViewDidHideEditingHandles:(IQLabelView *)label
{
    // hiding border and control buttons
    currentlyEditingLabel = nil;
}

- (void)labelViewDidStartEditing:(IQLabelView *)label
{
    // tap in text field and keyboard showing
    currentlyEditingLabel = label;
}


@end
