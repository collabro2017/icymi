//
//  OMUtilities.m
//  ICYMI
//
//  Created by Zahid Hussain on 30/11/2017.
//  Copyright © 2017 ellisa. All rights reserved.
//

#import "OMUtilities.h"

@implementation OMUtilities

+ (NSString *) getOfflinePostDataDirPath
{
    NSString * offlinePostsDataDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OfflinePostsData"];
    
    BOOL isDir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:offlinePostsDataDirPath isDirectory:&isDir]) {
        
        NSError * error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: offlinePostsDataDirPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success)
            NSLog(@"Failed to create directory at path : %@ ", offlinePostsDataDirPath);
        else
            NSLog(@"Successfully created offline posts data directory at path : %@ ", offlinePostsDataDirPath);
    }
    
    NSLog(@"Offline Data Path : %@ ", offlinePostsDataDirPath);
    return offlinePostsDataDirPath;
}

@end
