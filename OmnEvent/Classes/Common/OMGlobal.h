//
//  OMGlobal.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    
    kTypeUploadEvent = 0,
    kTypeUploadPost
    
}kTypeUpload;

typedef enum {
    
    kTypeCaptureAll = 0,
    kTypeCaptureVideo,
    kTypeCapturePhoto,
    kTypeCaptureAudio,
    kTypeCaptureText
    
}kTypeCapture;

typedef enum {
    
    kTypeRecordAudio = 0
    
}kTypeRecord;

@interface OMGlobal : NSObject

+ (void)setLogInUserDefault;
+ (void)showAlertTips:(NSString *)_message title:(NSString *)_title;
+ (NSDate *)getFirstDayOfThisMonth;

+ (void)setCircleView : (UIView *)view borderColor:(UIColor *)color;
+ (void)setRoundView : (UIView *)view cornorRadius:(float)radian   borderColor:(UIColor *)color borderWidth:(float)border;
+ (void)setImageURLWithAsync:(NSString *)_urlStr
                positionView:(UIView *)_positionView
              displayImgView:(UIImageView *)_displayImgView;

+ (NSString *)showTime:(NSDate *)_date;
+ (NSArray *)showDetailTime:(NSDate *)_date;

+ (CGSize)getBoundingOfString:(NSString *)text width:(float)_width;

+ (CGFloat)heightForCellWithPost:(NSString *)str;

+ (UIImage *)croppedImage:(UIImage *)originalImage;
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (void)removeImage:(NSString *)fileName;

@end
