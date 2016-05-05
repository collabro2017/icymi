//
//  SBCaptureConnection.h
//  Forty
//
//  Created by Ellisa on 13/01/15.
//  Copyright (c) 2015 Linus Olander. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVCaptureConnection;
@interface SBCaptureConnection : NSObject
{
    
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
