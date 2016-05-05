//
//  UIImage+Crop.h
//  WeatherApp
//
//  Created by rahul Sharma on 21/05/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)getSubImage:(CGRect) rect;
@end
