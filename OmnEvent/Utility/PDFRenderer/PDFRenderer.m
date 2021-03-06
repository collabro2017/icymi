//
//  PDFRenderer.m
//  PDFRenderer
//
//  Created by Yuichi Fujiki on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFRenderer.h"
#define PDF_PAGE_WIDTH 612.0f
#define PDF_PAGE_HEIGHT 792.0f
#define PDF_CONTENT_HEIGHT 720.0f
#define PDF_START_OffSet 35

@implementation PDFRenderer

+(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frame fontName:(NSString *)fontName fontSize:(int) fontSize fontColor:(UIColor*)fontColor
{
    if (!textToDraw) return;
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    
    // Prepare the text using a Core Text Framesetter.
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font, fontColor.CGColor };
    CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                              sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, attr);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGRect frameRect = (CGRect){frame.origin.x, -1 * frame.origin.y, frame.size};
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    // CGContextTranslateCTM(currentContext, 0, 100);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Revert coordinate
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(frameSetter);
}

+(void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.2, 0.2, 0.2, 0.3};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

+(int)drawTextCell:(PFObject *)obj nCurrOffset:(int)nCurrentOffset
{
    float rScale = PDF_PAGE_WIDTH/320;
    __block int nCurrOffset = nCurrentOffset;
    
    PFObject *currentObj = obj;
    PFUser* user = currentObj[@"user"];
    
    if ((nCurrOffset + 8) * rScale > PDF_CONTENT_HEIGHT) {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        
        if (avatarFile) {
            
            UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
            
            CGRect frame = CGRectMake(8 * rScale, (nCurrOffset+ 8) * rScale, 35 * rScale, 35 * rScale);
            
            UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
            
            [PDFRenderer drawImage:newImage inRect:frame];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"profileURL"]]]];
        
        CGRect frame = CGRectMake(8 * rScale, (nCurrOffset + 8) * rScale, 35 * rScale, 35 * rScale);
        
        UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
        
        [PDFRenderer drawImage:newImage inRect:frame];
    }
    
    [PDFRenderer drawText:user.username inFrame:CGRectMake(51 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];
    
    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    NSLog(@"str_date = %@",str_date);
    
    [PDFRenderer drawText:str_date inFrame:CGRectMake(200 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor grayColor]];
    
    int nTitleHeight = [OMGlobal getBoundingOfString:currentObj[@"title"] width:250].height;
    if (((nCurrOffset + nTitleHeight) * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    [PDFRenderer drawText:currentObj[@"title"] inFrame:CGRectMake(51 * rScale, (nCurrOffset + nTitleHeight + 40) * rScale, 250 * rScale, nTitleHeight * rScale) fontName:@"HelveticaNeue-Light" fontSize:12 * rScale fontColor:[UIColor grayColor]];

    nCurrOffset += nTitleHeight;
    nCurrOffset += 40;
    
    int nDescHeight = [OMGlobal getBoundingOfString:currentObj[@"description"] width:250].height;
    
    if (((nCurrOffset + nDescHeight) * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    [PDFRenderer drawText:currentObj[@"description"] inFrame:CGRectMake(52 * rScale, (nCurrOffset + nDescHeight + 20) * rScale, 250 * rScale, nDescHeight * rScale) fontName:@"Roboto-Regular" fontSize:11 * rScale fontColor:[UIColor blackColor]];
    
    nCurrOffset += nDescHeight;
    nCurrOffset += 20;
    //------------------------------------------------------------//
    
    if ((nCurrOffset + 27) * rScale > PDF_CONTENT_HEIGHT) {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    if (currentObj[@"commentsUsers"])
    [PDFRenderer drawText:[NSString stringWithFormat:@"%lu",(unsigned long) [currentObj[@"commentsUsers"] count]] inFrame:CGRectMake(149 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"HelveticaNeue-Light" fontSize:15 * rScale  fontColor:[UIColor grayColor]];
    else
    [PDFRenderer drawText:[NSString stringWithFormat:@"0"] inFrame:CGRectMake(149 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor grayColor]];
    
    UIImage* comment = [UIImage imageNamed:@"btn_comment"];
    CGRect frame = CGRectMake(115 * rScale, (nCurrOffset) * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:comment inRect:frame];
    
    int likeCount = 0;
    
    if (currentObj[@"likers"]) {
        likeCount = (int)[currentObj[@"likers"] count];
        
    }
    else
    {
        likeCount = 0;
    }
    
    UIImage* like;
    
    if (likeCount)
    like = [UIImage imageNamed:@"btn_like_selected"];
    else
    like = [UIImage imageNamed:@"btn_like_unselected"];
    
    frame = CGRectMake(19 * rScale, (nCurrOffset- 5) * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:like inRect:frame];
    
    [PDFRenderer drawText:[NSString stringWithFormat:@"%d",likeCount] inFrame:CGRectMake(59 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"HelveticaNeue-Light" fontSize:15 * rScale  fontColor:[UIColor grayColor]];
    
    UIImage* more = [UIImage imageNamed:@"btn_more"];
    frame = CGRectMake(289 * rScale, (nCurrOffset) * rScale, 16 * rScale, 4 * rScale);
    
    [PDFRenderer drawImage:more inRect:frame];
    
    nCurrOffset += 30;
    
    if ((nCurrOffset * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    return nCurrOffset;
}

+(int)drawFeedCommentCell:(NSMutableArray *)arr nCurrOffset:(int)nCurrentOffset
{
    float rScale = 612.0f / 320;
    __block int nCurrOffset = nCurrentOffset;
    
    if (nCurrentOffset * rScale > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrentOffset = PDF_START_OffSet;
    }
    
    for(int i = 0; i < [arr count]; i++)
    {
        PFObject* tempObj = [arr objectAtIndex:i];
        
        PFUser* commenter = tempObj[@"Commenter"];
        
        [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                if ((nCurrOffset + 8) * rScale > PDF_CONTENT_HEIGHT) {
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                    nCurrOffset = PDF_START_OffSet;
                }
                
                if ([commenter[@"loginType"] isEqualToString:@"email"] || [commenter[@"loginType"] isEqualToString:@"gmail"]) {
                    PFFile *avatarFile = (PFFile *)commenter[@"ProfileImage"];
                    if (avatarFile) {
                        UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
                        
                        CGRect frame = CGRectMake(8 * rScale, (nCurrOffset+ 8) * rScale, 35 * rScale, 35 * rScale);
                        
                        UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                        
                        [PDFRenderer drawImage:newImage inRect:frame];
                    }
                    
                }
                else if ([commenter[@"loginType"] isEqualToString:@"facebook"])
                {
                    UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:commenter[@"profileURL"]]]];
                    
                    CGRect frame = CGRectMake(8 * rScale, (nCurrOffset + 8) * rScale, 35 * rScale, 35 * rScale);
                    
                    UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                    
                    [PDFRenderer drawImage:newImage inRect:frame];
                }
                
                [PDFRenderer drawText:commenter.username inFrame:CGRectMake(51 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
                
                NSString *str_date = [dateFormat stringFromDate:tempObj.createdAt];
                NSLog(@"str_date = %@",str_date);
                
                [PDFRenderer drawText:str_date inFrame:CGRectMake(200 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor grayColor]];
                
                //-----------------------------------------------------------//
                int nDesHeight = [OMGlobal getBoundingOfString:tempObj[@"Comments"] width:250].height;
                
                if (((nCurrOffset + nDesHeight) * rScale) > PDF_CONTENT_HEIGHT)
                {
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                    nCurrOffset = PDF_START_OffSet;
                }
                
                [PDFRenderer drawText:tempObj[@"Comments"] inFrame:CGRectMake(51 * rScale, (nCurrOffset + nDesHeight + 40) * rScale, 250 * rScale, nDesHeight * rScale) fontName:@"HelveticaNeue-Light " fontSize:12 * rScale fontColor:[UIColor grayColor]];
                //-----------------------------------------------------------//
                
                nCurrOffset += nDesHeight + 40;
                
                if ((nCurrOffset * rScale) > PDF_CONTENT_HEIGHT)
                {
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                    nCurrOffset = PDF_START_OffSet;
                }
            }
        }];
    }
    
    if([arr count] > 0)
    {
        CGPoint from = CGPointMake(0, nCurrOffset * rScale);
        CGPoint to = CGPointMake(322 * rScale, nCurrOffset * rScale);
        [PDFRenderer drawLineFromPoint:from toPoint:to];
        nCurrOffset += 20;
    }
    
    return nCurrOffset;
}

+(int)drawMediaCell:(PFObject *)obj nCurrOffset:(int)nCurrentOffset IsLast:(BOOL) isLast
{
    PFObject *currentObj = obj;
    PFUser* user = currentObj[@"user"];
    int nCurrOffset = nCurrentOffset;
    float rScale = 612.0f / 320;
    
    if ((nCurrOffset + 8) * rScale > PDF_CONTENT_HEIGHT) {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        if (avatarFile) {
            UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
            
            CGRect frame = CGRectMake(8 * rScale, (nCurrOffset + 8) * rScale, 35 * rScale, 35 * rScale);
            
            UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
            
            [PDFRenderer drawImage:newImage inRect:frame];
        }
        
    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"profileURL"]]]];
        
        CGRect frame = CGRectMake(8 * rScale, (nCurrOffset + 8) * rScale, 35 * rScale, 35 * rScale);
        
        UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
        
        [PDFRenderer drawImage:newImage inRect:frame];
    }
    
    if (user)
    [PDFRenderer drawText:user.username inFrame:CGRectMake(51 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mm a"];//Dec 14 2011 1:50 PM
    
    NSString *str_date = [dateFormat stringFromDate:currentObj.createdAt];
    NSLog(@"str_date = %@",str_date);
    
    [PDFRenderer drawText:str_date inFrame:CGRectMake(200 * rScale, (nCurrOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor grayColor]];
    
    NSString *strCountryInfo = currentObj[@"country"];
    if (strCountryInfo && ![strCountryInfo isEqualToString:@""])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_GEOCODE_ENABLED"]) {
            if (currentObj[@"countryLatLong"] && ![currentObj[@"countryLatLong"] isEqualToString:@""]) {
                strCountryInfo = currentObj[@"countryLatLong"];
            }
        }
    } else {
        strCountryInfo = @"Unkown";
    }
    
    [PDFRenderer drawText:strCountryInfo inFrame:CGRectMake(51 * rScale, (nCurrOffset + 40) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor grayColor]];
    
    if ((nCurrOffset + 60) * rScale > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    int nDescTitleHeight = [OMGlobal getBoundingOfString:currentObj[@"title"] width:250].height;
    
    if ((nCurrOffset + nDescTitleHeight) * rScale > PDF_CONTENT_HEIGHT) {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    if (currentObj[@"title"])
    [PDFRenderer drawText:currentObj[@"title"] inFrame:CGRectMake(25 * rScale, (nCurrOffset + nDescTitleHeight + 60) * rScale, 250 * rScale, nDescTitleHeight * rScale) fontName:@"Roboto-Regular" fontSize:11 * rScale fontColor:[UIColor blackColor]];
    
    nCurrOffset += nDescTitleHeight;
    nCurrOffset += 60;
    
    if ((nCurrOffset * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    PFFile *postImgFile = (PFFile *)currentObj[@"thumbImage"];
    
    if (postImgFile) {
        
        int nImageWidth = 200;
        
        if (((nCurrOffset + nImageWidth) * rScale) > PDF_CONTENT_HEIGHT)
        {
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
            nCurrOffset = PDF_START_OffSet;
        }
        
        UIImage* mediaImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:postImgFile.url]]];
        
        CGRect frame = CGRectMake(50 * rScale, (nCurrOffset + 8) * rScale, nImageWidth * rScale, nImageWidth * rScale);
        
        [PDFRenderer drawImage:mediaImage inRect:frame];
        
        nCurrOffset += nImageWidth;
        nCurrOffset += 8;
    }
    
    int nDescHeight = [OMGlobal getBoundingOfString:currentObj[@"description"] width:250].height;
    //*********************************//
    
    if (((nCurrOffset + nDescHeight) * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    //*********************************//
    [PDFRenderer drawText:currentObj[@"description"] inFrame:CGRectMake(25 * rScale, (nCurrOffset + nDescHeight + 20) * rScale, 250 * rScale, nDescHeight * rScale) fontName:@"Roboto-Regular" fontSize:11 * rScale fontColor:[UIColor blackColor]];
    
    nCurrOffset += nDescHeight;
    nCurrOffset += 30;
    
    if ((nCurrOffset + 27) * rScale > PDF_CONTENT_HEIGHT) {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrOffset = PDF_START_OffSet;
    }
    
    if (currentObj[@"commentsUsers"])
    [PDFRenderer drawText:[NSString stringWithFormat:@"%lu",(unsigned long) [currentObj[@"commentsUsers"] count]] inFrame:CGRectMake(149 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"HelveticaNeue-Light" fontSize:15 * rScale  fontColor:[UIColor grayColor]];
    else
    [PDFRenderer drawText:[NSString stringWithFormat:@"0"] inFrame:CGRectMake(149 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor grayColor]];
    
    UIImage* comment = [UIImage imageNamed:@"btn_comment"];
    CGRect frame = CGRectMake(115 * rScale, (nCurrOffset) * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:comment inRect:frame];
    
    int likeCount = 0;
    
    if (currentObj[@"likers"]) {
        likeCount = (int)[currentObj[@"likers"] count];
        
    }
    else
    {
        likeCount = 0;
    }
    
    UIImage* like;
    
    if (likeCount)
    like = [UIImage imageNamed:@"btn_like_selected"];
    else
    like = [UIImage imageNamed:@"btn_like_unselected"];
    
    frame = CGRectMake(19 * rScale, (nCurrOffset- 5) * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:like inRect:frame];
    
    [PDFRenderer drawText:[NSString stringWithFormat:@"%d",likeCount] inFrame:CGRectMake(59 * rScale, (nCurrOffset + 27) * rScale, 46 * rScale, 30 * rScale) fontName:@"HelveticaNeue-Light" fontSize:15 * rScale  fontColor:[UIColor grayColor]];
    
    UIImage* more = [UIImage imageNamed:@"btn_more"];
    frame = CGRectMake(289 * rScale, (nCurrOffset) * rScale, 16 * rScale, 4 * rScale);
    
    [PDFRenderer drawImage:more inRect:frame];
    
    nCurrOffset += 30;
    
    if(!isLast)
    {
        if ((nCurrOffset * rScale) > PDF_CONTENT_HEIGHT)
        {
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
            nCurrOffset = PDF_START_OffSet;
        }
    }
    
    return nCurrOffset;
    
}



+(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //this should be white color with 0.7 opacity right
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.45);
    CGContextFillRect(context, rect);
}

+(void)drawImage:(UIImage*)image inRect:(CGRect)rect
{
    [image drawInRect:rect];
}

+(void)createPDF:(NSString*)filePath
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil);
    
    [PDFRenderer drawText:@"Hello World" inFrame:CGRectMake(150, 150, 300, 50) fontName:@"Times" fontSize:36 fontColor:[UIColor blackColor]];
    
    CGPoint from = CGPointMake(0, 0);
    CGPoint to = CGPointMake(200, 300);
    [PDFRenderer drawLineFromPoint:from toPoint:to];
    
    UIImage* logo = [UIImage imageNamed:@"apple-icon.png"];
    CGRect frame = CGRectMake(20, 100, 60, 60);
    
    [PDFRenderer drawImage:logo inRect:frame];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

+(void)createPDF:(NSString*)filePath content:(NSMutableDictionary*)contentDic
{
    float rScale = PDF_PAGE_WIDTH/320;
    __block int nCurrentOffset = 0;
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil);
    
    PFObject *currentObject = [contentDic objectForKey:@"currentObject"];
    PFUser* user = currentObject[@"user"];
    PFFile *postImgFile = (PFFile *)currentObject[@"thumbImage"];
    
    if (postImgFile) {
        
        UIImage* postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:postImgFile.url]]];
        
        CGRect frame = CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_WIDTH);
        
        [PDFRenderer drawImage:postImage inRect:frame];
    }
    //
    
    NSString *profileMode = contentDic[@"profileMode"];
    if (![profileMode isEqualToString:@"company_profile"]) {
        if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
            PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
            if (avatarFile) {
                UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
                CGRect frame = CGRectMake(8 * rScale, 8 * rScale, 35 * rScale, 35 * rScale);
                UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale)
                                                   withCornerRadius:(35 * rScale / 2)];
                [PDFRenderer drawImage:newImage inRect:frame];
            }
        }
        else if ([user[@"loginType"] isEqualToString:@"facebook"])
        {
            UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"profileURL"]]]];
            CGRect frame = CGRectMake(8 * rScale, 8 * rScale, 35 * rScale, 35 * rScale);
            UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale)
                                               withCornerRadius:(35 * rScale / 2)];
            [PDFRenderer drawImage:newImage inRect:frame];
        }
    }
    
    if ([profileMode isEqualToString:@"company_profile"]) {
        NSString *companyName = contentDic[@"companyName"];
        NSString *text = [NSString stringWithFormat:@"%@ | Company: %@", user.username, companyName];
        int txtH = [OMGlobal getBoundingOfString:text width:211].height;
        int y = 40;
        if (txtH > 16) {
            y = 60;
            txtH += 10;
        } else {
            txtH = 21;
        }
        
        [PDFRenderer drawText:text inFrame:CGRectMake(51 * rScale, y * rScale, 211 * rScale, txtH * rScale)
                     fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor whiteColor]];
    } else {
        [PDFRenderer drawText:user.username inFrame:CGRectMake(51 * rScale, 40 * rScale, 211 * rScale, 21 * rScale)
                     fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor whiteColor]];
    }
    
    [PDFRenderer drawRect:CGRectMake(8 * rScale, 281 * rScale, 180 * rScale, 31 * rScale)];
    
    [PDFRenderer drawRect:CGRectMake(267 * rScale, 281 * rScale, 45 * rScale, 31 * rScale)];
    
    UIImage* logo = [UIImage imageNamed:@"btn_more_white"];
    CGRect frame = CGRectMake(279 * rScale, 293 * rScale, 16 * rScale, 4 * rScale);
    
    [PDFRenderer drawImage:logo inRect:frame];
    
    UIImage* comment = [UIImage imageNamed:@"btn_comment_white"];
    frame = CGRectMake(115 * rScale, 287 * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:comment inRect:frame];
    
    int likeCount;
    
    if (currentObject[@"likers"]) {
        likeCount = (int)[currentObject[@"likers"] count];
    }
    else
    {
        likeCount = 0;
    }
    
    UIImage* like;
    
    if (likeCount)
    like = [UIImage imageNamed:@"btn_like_white_selected"];
    else
    like = [UIImage imageNamed:@"btn_like_white"];
    
    frame = CGRectMake(19 * rScale, 287 * rScale, 16 * rScale, 16 * rScale);
    
    [PDFRenderer drawImage:like inRect:frame];
    
    [PDFRenderer drawText:[NSString stringWithFormat:@"%d",likeCount] inFrame:CGRectMake(57 * rScale, 317 * rScale, 46 * rScale, 30 * rScale) fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor whiteColor]];
    
    if (currentObject[@"commenters"])
    [PDFRenderer drawText:[NSString stringWithFormat:@"%lu",(unsigned long) [currentObject[@"commenters"] count]] inFrame:CGRectMake(149 * rScale, 317 * rScale, 46 * rScale, 30 * rScale) fontName:@"Roboto-Medium" fontSize:15 * rScale  fontColor:[UIColor whiteColor]];
    else
    [PDFRenderer drawText:[NSString stringWithFormat:@"0"] inFrame:CGRectMake(144 * rScale, 317 * rScale, 46 * rScale, 30 * rScale) fontName:@"Roboto-Medium" fontSize:15 * rScale fontColor:[UIColor whiteColor]];
    
    int nLblDescW = 250;
    int nLblDescH = [OMGlobal getBoundingOfString:currentObject[@"description"] width:nLblDescW].height;
    nCurrentOffset = 312;
    
    if ((nCurrentOffset + nLblDescH) * rScale > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrentOffset = PDF_START_OffSet;
    }
    
    [PDFRenderer drawText:currentObject[@"description"] inFrame:CGRectMake(20 * rScale, (nCurrentOffset + nLblDescH + 30) * rScale, nLblDescW * rScale, nLblDescH * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
    
    nCurrentOffset += nLblDescH;
    nCurrentOffset += 30;
    
    if ([currentObject objectForKey:@"commenters"]) {
        
        for(int i = 0; i < [currentObject[@"commenters"] count]; i++) {
            
            PFUser* commenter = [currentObject[@"commenters"] objectAtIndex:i];
            NSString* comment = [currentObject[@"commentsArray"] objectAtIndex:i];
            
            //NSLog(@"---------here run-------------%@", commenter);
            
            NSDictionary *temp = [currentObject[@"commenters"] objectAtIndex:i];
            NSString *objectId = [temp objectForKey:@"objectId"];
            
            if (objectId != nil){
                
                PFQuery *query = [PFUser query];
                [query whereKey:@"objectId" equalTo:objectId];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if (error || !objects) {
                        return;
                    } else {
                        
                        PFUser *temp_commenter = (PFUser *)objects[0];
                        
                        if ((nCurrentOffset + 8) * rScale > PDF_CONTENT_HEIGHT)
                        {
                            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                            nCurrentOffset = PDF_START_OffSet;
                        }
                        
                        if ([temp_commenter[@"loginType"] isEqualToString:@"email"] || [temp_commenter[@"loginType"] isEqualToString:@"gmail"]) {
                            
                            PFFile *avatarFile = (PFFile *)temp_commenter[@"ProfileImage"];
                            
                            if (avatarFile) {
                                
                                UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
                                CGRect frame = CGRectMake(8 * rScale, (nCurrentOffset+ 8) * rScale, 35 * rScale, 35 * rScale);
                                UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                                
                                [PDFRenderer drawImage:newImage inRect:frame];
                            }
                            
                        } else if ([temp_commenter[@"loginType"] isEqualToString:@"facebook"]) {
                            
                            UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:commenter[@"profileURL"]]]];
                            
                            CGRect frame = CGRectMake(8 * rScale, (nCurrentOffset + 8) * rScale, 35 * rScale, 35 * rScale);
                            
                            UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                            
                            [PDFRenderer drawImage:newImage inRect:frame];
                        }
                        
                        [PDFRenderer drawText:temp_commenter.username inFrame:CGRectMake(51 * rScale, (nCurrentOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
                        
                        int nDesHeight = [OMGlobal heightForCellWithPost:comment];
                        
                        [PDFRenderer drawText:comment inFrame:CGRectMake(51 * rScale, (nCurrentOffset + nDesHeight + 15) * rScale, 250 * rScale, nDesHeight * rScale) fontName:@"HelveticaNeue-Light " fontSize:12 * rScale fontColor:[UIColor grayColor]];
                        
                        nCurrentOffset += 15;
                        
                        if ((nCurrentOffset * rScale) > PDF_CONTENT_HEIGHT) {
                            
                            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                            nCurrentOffset = PDF_START_OffSet;
                        }
                    }
                }];
                
            } else {
                
                [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if (!error) {
                        NSLog(@"%@",commenter.username);
                        if ((nCurrentOffset + 8) * rScale > PDF_CONTENT_HEIGHT)
                        {
                            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                            nCurrentOffset = PDF_START_OffSet;
                        }
                        
                        if ([commenter[@"loginType"] isEqualToString:@"email"] || [commenter[@"loginType"] isEqualToString:@"gmail"]) {
                            PFFile *avatarFile = (PFFile *)commenter[@"ProfileImage"];
                            if (avatarFile) {
                                UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarFile.url]]];
                                
                                CGRect frame = CGRectMake(8 * rScale, (nCurrentOffset+ 8) * rScale, 35 * rScale, 35 * rScale);
                                
                                UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                                
                                [PDFRenderer drawImage:newImage inRect:frame];
                            }
                            
                        } else if ([commenter[@"loginType"] isEqualToString:@"facebook"]) {
                            
                            UIImage* avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:commenter[@"profileURL"]]]];
                            
                            CGRect frame = CGRectMake(8 * rScale, (nCurrentOffset + 8) * rScale, 35 * rScale, 35 * rScale);
                            
                            UIImage* newImage = [self roundedRectImageFromImage:avatarImage size:CGSizeMake(35* rScale, 35 * rScale) withCornerRadius:(35 * rScale / 2)];
                            
                            [PDFRenderer drawImage:newImage inRect:frame];
                        }
                        
                        [PDFRenderer drawText:commenter.username inFrame:CGRectMake(51 * rScale, (nCurrentOffset + 20) * rScale, 211 * rScale, 21 * rScale) fontName:@"Roboto-Regular" fontSize:12 * rScale fontColor:[UIColor blackColor]];
                        
                        int nDesHeight = [OMGlobal heightForCellWithPost:comment];
                        
                        //----------------------------------------------------//
                        if (((nCurrentOffset + nDesHeight) * rScale) > PDF_CONTENT_HEIGHT)
                        {
                            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                            nCurrentOffset = PDF_START_OffSet;
                        }
                        
                        
                        [PDFRenderer drawText:comment inFrame:CGRectMake(51 * rScale, (nCurrentOffset + nDesHeight + 15) * rScale, 250 * rScale, nDesHeight * rScale) fontName:@"HelveticaNeue-Light" fontSize:12 * rScale fontColor:[UIColor grayColor]];
                        nCurrentOffset += nDesHeight;
                        nCurrentOffset += 15;
                        //---------------------------------------------------//
                        
                        if ((nCurrentOffset * rScale) > PDF_CONTENT_HEIGHT) {
                            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
                            nCurrentOffset = PDF_START_OffSet;
                        }
                    }
                }];
            }
        }
    }
    
    CGPoint from = CGPointMake(0, nCurrentOffset * rScale);
    CGPoint to = CGPointMake(322 * rScale, nCurrentOffset * rScale);
    [PDFRenderer drawLineFromPoint:from toPoint:to];
    
    nCurrentOffset += 20;
    
    if ((nCurrentOffset * rScale) > PDF_CONTENT_HEIGHT)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil); // start second page
        nCurrentOffset = PDF_START_OffSet;
    }
    
    NSMutableArray *arrForDetail = [contentDic objectForKey:@"arrDetail"];
    
    for (int i = 0 ; i < [arrForDetail count]; i++)
    {
        PFObject *tempObj = [arrForDetail objectAtIndex:i];
        
        if ([tempObj[@"postType"] isEqualToString:@"text"])
        {
            nCurrentOffset = [PDFRenderer drawTextCell:tempObj nCurrOffset:nCurrentOffset];
            
            NSMutableArray *arr = nil;
            
            if (tempObj[@"commentsArray"]) {
                
                arr = tempObj[@"commentsArray"];
                
                nCurrentOffset = [PDFRenderer drawFeedCommentCell:arr nCurrOffset:nCurrentOffset];
            }
            else
            {
                CGPoint from = CGPointMake(0, nCurrentOffset * rScale);
                CGPoint to = CGPointMake(322 * rScale, nCurrentOffset * rScale);
                [PDFRenderer drawLineFromPoint:from toPoint:to];
                
                nCurrentOffset += 30;
            }
        }
        else
        {
            if(i >= [arrForDetail count]-1)
            {
                nCurrentOffset = [PDFRenderer drawMediaCell:tempObj nCurrOffset:nCurrentOffset IsLast:YES];
            }
            else
            {
                nCurrentOffset = [PDFRenderer drawMediaCell:tempObj nCurrOffset:nCurrentOffset IsLast:NO];
            }
            
            
            NSMutableArray *arr = nil;
            
            if (tempObj[@"commentsArray"]) {
                
                arr = tempObj[@"commentsArray"];
                
                nCurrentOffset = [PDFRenderer drawFeedCommentCell:arr nCurrOffset:nCurrentOffset];
            }
            else
            {
                
                CGPoint from = CGPointMake(0, nCurrentOffset * rScale);
                CGPoint to = CGPointMake(322 * rScale, nCurrentOffset * rScale);
                [PDFRenderer drawLineFromPoint:from toPoint:to];
                
                nCurrentOffset += 30;
            }
        }
    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

+(UIImage*)roundedRectImageFromImage:(UIImage *)image
                                size:(CGSize)imageSize
                    withCornerRadius:(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);   //  <= notice 0.0 as third scale parameter. It is important cause default draw scale ≠ 1.0. Try 1.0 - it will draw an ugly image..
    CGRect bounds=(CGRect){CGPointZero,imageSize};
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+(void)editPDF:(NSString*)filePath templateFilePath:(NSString*) templatePath
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, PDF_PAGE_WIDTH, PDF_PAGE_HEIGHT), nil);
    
    //open template file
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (__bridge CFStringRef)templatePath, kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
    //get bounds of template page
    CGPDFPageRef templatePage = CGPDFDocumentGetPage(templateDocument, 1);
    CGRect templatePageBounds = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //flip context due to different origins
    CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //copy content of template page on the corresponding page in new file
    CGContextDrawPDFPage(context, templatePage);
    
    //flip context back
    CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Edit body
    [PDFRenderer drawText:@"Hello World" inFrame:CGRectMake(150, 550, 300, 50) fontName:@"Times" fontSize:36 fontColor:[UIColor blackColor]];
    
    CGPoint from = CGPointMake(0, 400);
    CGPoint to = CGPointMake(200, 700);
    [PDFRenderer drawLineFromPoint:from toPoint:to];
    
    UIImage* logo = [UIImage imageNamed:@"apple-icon.png"];
    CGRect frame = CGRectMake(20, 500, 60, 60);
    
    [PDFRenderer drawImage:logo inRect:frame];
    
    
    CGPDFDocumentRelease(templateDocument);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}
@end
