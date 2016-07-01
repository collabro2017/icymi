//
//  PDFRenderer.h
//  PDFRenderer
//
//  Created by Yuichi Fujiki on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface PDFRenderer : NSObject

+ (void)drawText:(NSString*)text inFrame:(CGRect)frame fontName:(NSString *)fontName fontSize:(int) fontSize  fontColor:(UIColor*)fontColor;

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to;

+(void)drawRect:(CGRect)rect;
    
+(void)drawImage:(UIImage*)image inRect:(CGRect)rect;

+(void)createPDF:(NSString*)filePath;

+(void)createPDF:(NSString*)filePath content:(NSMutableDictionary*)contentDic;

+(void)editPDF:(NSString*)filePath templateFilePath:(NSString*) templatePath;

+(UIImage*)roundedRectImageFromImage:(UIImage *)image size:(CGSize)imageSize withCornerRadius:(float)cornerRadius;

+(int)drawTextCell:(PFObject *)obj nCurrOffset:(int)nCurrentOffset;

+(int)drawFeedCommentCell:(NSMutableArray *)arr nCurrOffset:(int)nCurrentOffset;

+(int)drawMediaCell:(PFObject *)obj nCurrOffset:(int)nCurrentOffset IsLast:(BOOL)isLast;

@end
