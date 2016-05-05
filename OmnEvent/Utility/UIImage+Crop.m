//
//  UIImage+Crop.m
//  WeatherApp
//
//  Created by rahul Sharma on 21/05/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)
- (UIImage *)crop:(CGRect)rect {
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    
    NSLog(@"%f",self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
- (UIImage *)getSubImage:(CGRect) rect{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(rect.origin.x, rect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImg = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return smallImg;
}
@end
