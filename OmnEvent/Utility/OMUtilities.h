//
//  OMUtilities.h
//  ICYMI
//
//  Created by Zahid Hussain on 30/11/2017.
//  Copyright © 2017 ellisa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMUtilities : NSObject

+(NSString *) getOfflinePostDataDirPath;
+(BOOL) isEventCreatedFromWebConsole:(NSString *) type;

@end
