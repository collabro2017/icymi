//
//  OMRecordAudioViewController.m
//  Collabro
//
//  Created by XXX on 4/5/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMRecordAudioViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreText/CoreText.h>

#import "OMPostEventViewController.h"

@interface OMRecordAudioViewController () {
    
    NSString        *soundFilePath;
    NSString        *plistFilePath;
    NSURL           *outputFileURL;
    NSTimer         *timer;
    NSTimer         *timerRange;
    AVAudioPlayer   *audioPlayer;
    
    int              count;
    int              ticks;
    int              limitedRecord;
    BOOL             isRecording;
    
    NSString        *fileName;
    
    float Pitch;
}

@end

@implementation OMRecordAudioViewController
@synthesize audioRecorder;

- (void)useAudio {
    
    
    if( limitedRecord < MIN_AUDIO_DUR )
    {
        [OMGlobal showAlertTips:[NSString stringWithFormat:@"Record length needs over %is.", (int)MIN_AUDIO_DUR] title:@"Alert"];
        return;
    }
    
    recordedData = [NSData dataWithContentsOfURL:outputFileURL];
    if (recordedData) {
        
        OMPostEventViewController *postEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostEventVC"];
        
        [postEventVC setUploadOption:_uploadOption];
        [postEventVC setCaptureOption:_captureOption];
        [postEventVC setCurObj:_curObj];
        [postEventVC setAudioData:recordedData];
        [postEventVC setPostOrder:_postOrder];
        
        [self.navigationController pushViewController:postEventVC animated:YES];
    }
}

- (void)loadView {
    
    [super loadView];
    [OMGlobal setCircleView:btnForRecord borderColor:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isRecording = NO;
    ticks = 0;
    count = 0;
    limitedRecord = 0;
    
    [lblForRecordTime setHidden:YES];
    
    [self initializeAudioRecorder];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back_profile"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    //    UIBarButtonItem *tagBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_tag"] style:UIBarButtonItemStylePlain target:self action:@selector(tagAction)];
    
    
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Use" style:UIBarButtonItemStyleBordered target:self action:@selector(useAudio)];
    UIBarButtonItem *negativeSpacer1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
    negativeSpacer1.width = -6;// it was -6 in iOS 6
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, backBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer1, uploadBarButton,nil];
    
    self.title = @"Record Audio";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)backAction {
    
    [self stopRecording];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [timer invalidate];
    [timerRange invalidate];
    
}
- (void)initializeAudioRecorder {
    
    fileName = [NSString stringWithFormat:@"%@.wav",[NSDate date]];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               fileName,
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    soundFilePath=[outputFileURL path];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    // [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAMR] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    // [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //[recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //[recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    //[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    //[recordSetting setValue:[NSNumber numberWithInt: 16] forKey:AVLinearPCMBitDepthKey];
    
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    //                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:8], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                                    nil];  //CHUNGNV
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:nil];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
    
}

#pragma Actions

- (void)recordAudio {
    
    if (!audioRecorder.recording) {
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        [session setActive:YES error:nil];
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        //Start recording
        
        [audioRecorder record];
        [lblForRecordTime setHidden:NO];
        [btnForRecord setTitle:@"Stop" forState:UIControlStateNormal];
        
        if (!isRecording) {
            
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
            timerRange = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
            isRecording = YES;
        }
        
        
    } else {
        
        [audioRecorder stop];
      
        [btnForRecord setTitle:@"Record" forState:UIControlStateNormal];
        if (timer) {
            [timer invalidate];
            [timerRange invalidate];
            timerRange = nil;
            timer = nil;
            ticks = 0;
        }
        isRecording = NO;
    }
}

- (void)pause {
    
    if (audioRecorder.recording) {
        [audioRecorder pause];
        if (timer || timerRange) {
            [timer invalidate];
            [timerRange invalidate];
        }
        isRecording = NO;
    }
}

- (void)reset {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    if (success) {
        //        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:nil message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        //        [removeSuccessFulAlert show];
        
        ticks = 0;
        isRecording = NO;
    } else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void)playAudio {
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL error:nil];
    
    [audioPlayer play];
}

- (void)stopRecording {
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    if ([audioRecorder isRecording]) {
        [audioRecorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
    
    isRecording = NO;
    
    ticks = 0;
    [timer invalidate];
    [timerRange invalidate];
    timer = nil;
    timerRange = nil;
    viewForStatus.value = 0;
    
    [btnForRecord setTitle:@"Record" forState:UIControlStateNormal];
}

#pragma mark - Timer

- (void)levelTimerCallback:(NSTimer *)timer {
    
    [audioRecorder updateMeters];
    NSLog(@"Average input: %f Peak input: %f", [audioRecorder averagePowerForChannel:0], [audioRecorder peakPowerForChannel:0]);
    
    //float linear = pow (10, [audioRecorder peakPowerForChannel:0] / 20);
    //NSLog(@"linear===%f",linear);
    float linear1 = pow (10, [audioRecorder averagePowerForChannel:0] / 20);
    //NSLog(@"linear1===%f",linear1);
    
    if (linear1>0.03) {
        
        Pitch = linear1+.20;//pow (10, [audioRecorder averagePowerForChannel:0] / 20);//[audioRecorder peakPowerForChannel:0];
    } else {
        
        Pitch = 0.0;
    }
    //Pitch =linear1;
    NSLog(@"Pitch==%f",Pitch);
    
    viewForStatus.value = Pitch;//linear1+.30;
    
    //float minutes = floor(audioRecorder.currentTime/60);
    //float seconds = audioRecorder.currentTime - (minutes * 60);
    
    //NSString *time = [NSString stringWithFormat:@"%0.0f.%0.0f",minutes, seconds];
    NSLog(@"recording");
    
}

- (void)updateTimer:(NSTimer *)_timer {
    
    if (audioRecorder.recording) {
        
        ticks++;
        limitedRecord = ticks;
        NSString *strForTime = [NSString stringWithFormat:@"%02d:%02d:%02d",ticks/3600,(ticks%3600)/60,(ticks%3600) % 60];
        [lblForRecordTime setText:strForTime];
        
        if (ticks >= MAX_AUDIO_DUR && isRecording) {
            
            [self stopRecording];
            [self useAudio];
        }
    }
}

#pragma mark

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occured");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)recordAction:(id)sender {
    
    if (isRecording) {
        
        [self stopRecording];
    } else {
        
        lblForRecordTime.text = [NSString stringWithFormat:@"00:00:00"];
        [self performSelector:@selector(recordAudio) withObject:nil afterDelay:0.3f];
    }
}
@end
