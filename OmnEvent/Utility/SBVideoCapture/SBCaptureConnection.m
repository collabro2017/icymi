//
//  SBCaptureConnection.m
//  Forty
//
//  Created by Ellisa on 13/01/15.
//  Copyright (c) 2015 Linus Olander. All rights reserved.
//

#import "SBCaptureConnection.h"
#import <AVFoundation/AVFoundation.h>

@implementation SBCaptureConnection

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for (AVCaptureConnection *connection in connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:mediaType]) {
                
                return connection;
            }
            
        }
    }
    return nil;
}

@end
