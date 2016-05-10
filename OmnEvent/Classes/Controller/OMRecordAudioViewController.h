//
//  OMRecordAudioViewController.h
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "F3BarGauge.h"

@interface OMRecordAudioViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    
    IBOutlet UILabel *lblForRecordTime;
    
    IBOutlet F3BarGauge *viewForStatus;
    
    IBOutlet UIButton *btnForRecord;
    
    NSData *recordedData;

}

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSData    *audioData;

@property (nonatomic, strong) PFObject *curObj;
@property (nonatomic) kTypeUpload      uploadOption;
@property (nonatomic) kTypeCapture      captureOption;
@property (nonatomic) kTypeRecord       audioOption;

- (IBAction)recordAction:(id)sender;

@end
