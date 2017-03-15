//
//  OMGlobal.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMGlobal.h"

#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "UIImage+Crop.h"


@implementation GlobalVar

static GlobalVar *_instance = nil;

+(GlobalVar*)getInstance
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[GlobalVar alloc] init];
        }
    }
    return _instance;
}

@end

@implementation OMGlobal



+ (void)setLogInUserDefault
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOG_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)showAlertTips:(NSString *)_message title:(NSString *)_title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_title
                                                        message:_message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (NSDate *)getFirstDayOfThisMonth
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [gregorian dateFromComponents:components];
}

+ (void)setCircleView:(UIView *)view
          borderColor:(UIColor *)color
{
    float borderWidth = 2.0f;
    
    if (color == nil)
    {
        borderWidth = 0;
    }
    
    view.layer.cornerRadius = roundf(view.frame.size.height/2.0f);
    view.layer.masksToBounds = YES;
    
    CALayer *borderLayer = [CALayer layer];
    
    CGRect borderFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setCornerRadius:view.frame.size.width/2];
    [borderLayer setBorderColor:color.CGColor];
    [borderLayer setBorderWidth:borderWidth];
    [view.layer addSublayer:borderLayer];
}

+ (void)setRoundView:(UIView *)view
        cornorRadius:(float)radian
         borderColor:(UIColor *)color
         borderWidth:(float)border
{
    view.layer.cornerRadius = radian;
    view.layer.masksToBounds = YES;
    
    CALayer *borderLayer = [CALayer layer];
    
    CGRect borderFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setCornerRadius:view.frame.size.width/2];
    [borderLayer setBorderColor:color.CGColor];
    [borderLayer setBorderWidth:border];
    [view.layer addSublayer:borderLayer];
    
}


+ (void)setImageURLWithAsync:(NSString *)_urlStr
                positionView:(UIView *)_positionView
              displayImgView:(UIImageView *)_displayImgView
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_urlStr]];
    UIActivityIndicatorView *activities = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activities setBackgroundColor:[UIColor clearColor]];
    activities.center = _displayImgView.center;
    [_positionView addSubview:activities];
    [activities setHidesWhenStopped:YES];
    [activities startAnimating];
    
    __block UIImageView *_feedImgView = _displayImgView;
    __block UIActivityIndicatorView *indicator = activities;
    
    [_displayImgView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"avatar.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        [indicator stopAnimating];
        [_feedImgView setImage:image];
        
        [indicator removeFromSuperview];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];
    
}

+ (NSString *)showTime:(NSDate *)_date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MMMM d, YYYY"];
    
    return [dateFormatter stringFromDate:_date];
    
    
}

+ (NSArray *)showDetailTime:(NSDate *)_date
{
    //display past time since post
    
    NSInteger year, month, day, hour,  min, sec = 0;
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:_date toDate:[NSDate date] options:0];
    
    year = (components.year > 0) ? components.year : 0;
    month = (components.month > 0) ? components.month : 0;
    day = (components.day > 0) ? components.day : 0;
    hour = (components.hour > 0) ? components.hour : 0;
    min = (components.minute > 0 ) ? components.minute : 0;
    sec = (components.second > 0) ? components.second : 0;
    NSArray *arr = [NSArray arrayWithObjects:[NSNumber numberWithInteger:year],[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day], [NSNumber numberWithInteger:hour] , [NSNumber numberWithInteger:min], [NSNumber numberWithInteger:sec], nil];
    
    return arr;
    
    
}

+ (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fileName error:&error];
    if (success) {
//        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removeSuccessFulAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}



#pragma mark

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef = [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                        actualTime:NULL
                                             error:&igError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", igError );
    
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    return thumbnailImage;
}


+ (UIImage *)croppedImage:(UIImage *)originalImage
{
    
    NSLog(@"%f, -- ,%f",originalImage.size.width,originalImage.size.height);
    if (originalImage.size.width < originalImage.size.height) {
        return [originalImage crop:CGRectMake((originalImage.size.height - originalImage.size.width) / 2, 0, originalImage.size.width, originalImage.size.width)];
        
    }
    else if (originalImage.size.width == originalImage.size.height)
    {
        return originalImage;
    }
    else
    {
        return [originalImage crop:CGRectMake((originalImage.size.width - originalImage.size.height) / 2, 0, originalImage.size.height, originalImage.size.height)];
        
    }
    return [originalImage crop:CGRectMake(420, 0, originalImage.size.width, originalImage.size.width)];
}

+ (CGFloat)heightForCellWithPost:(NSString *)str
{
    
    //CGSize sizeToFit = [str sizeWithFont:[UIFont systemFontOfSize:11.0f]
    //                   constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 60.0f, CGFLOAT_MAX)
    //                       lineBreakMode:NSLineBreakByWordWrapping];
    
    //CGSize size = [str sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.0f]}];
    
    // Values are fractional -- you should take the ceilf to get equivalent values
    //CGSize sizeToFit = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [str boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 60.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    CGSize sizeToFit = textRect.size;
    
    return fmaxf(15.0f, (float)sizeToFit.height + 20.0f);
    
}


+ (CGSize)getBoundingOfString:(NSString *)text width:(float)_width
{
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGSize sizeToFit;
    CGFloat messageMaxWidth = _width;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    sizeToFit = [text boundingRectWithSize: CGSizeMake(messageMaxWidth, CGFLOAT_MAX)
                                   options: NSStringDrawingUsesLineFragmentOrigin
                                attributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:14.0f] }
                                   context: nil].size;
#else
    sizeToFit = [text sizeWithFont:[[UIFont systemFontOfSize:14.0f]
                                    constrainedToSize:CGSizeMake(messageMaxWidth, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
#endif
    return sizeToFit;
}
                 
@end
