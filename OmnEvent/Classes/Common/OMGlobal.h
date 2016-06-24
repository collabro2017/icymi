//
//  OMGlobal.h
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define MIN_VIDEO_DUR 10
#define MAX_VIDEO_DUR 60

#define MIN_AUDIO_DUR 10
#define MAX_AUDIO_DUR 60

#define KEY_GOOGLE_CLIENTID @"374815263085-i2261314k94v2gchsm60lqvfktu88qee.apps.googleusercontent.com"
#define GMAIL_SIGNIN_KEY        @"icymi.social.event!" //password

#define ADMIN_USER_NAME  @"Coline Witt"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


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

typedef enum{

    kTypeOwner,
    kTypeCoporate,
    
}kTypeFolderView;

typedef enum {
    
    kTypeEventComment,
    kTypePostComment,
    
}kTypeCommentCell;

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


@interface GlobalVar : NSObject

@property (nonatomic) BOOL gIsPhotoPreview;
@property (nonatomic) BOOL isPostLoading;
@property (nonatomic) BOOL isEventLoading;
@property (strong, nonatomic) NSMutableArray *gArrEventList;
@property (nonatomic) NSInteger gEventIndex;
@property (nonatomic) BOOL isPosting;

@property (strong, nonatomic) NSMutableArray *gArrPostList;
@property (strong, nonatomic) NSMutableArray *gArrSelectedList;

+(GlobalVar*)getInstance;

@end
