//
//  SBVideoRecorder.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) . All rights reserved.
//

#import "SBVideoRecorder.h"
#import "SBCaptureDefine.h"
#import "SBCaptureToolKit.h"
#import "SBCaptureConnection.h"
@interface SBVideoData: NSObject

@property (assign, nonatomic) CGFloat duration;
@property (strong, nonatomic) NSURL *fileURL;

@end

@implementation SBVideoData

@end

#define COUNT_DUR_TIMER_INTERVAL 0.05

@interface SBVideoRecorder ()

@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) CGFloat currentVideoDur;
@property (assign, nonatomic) NSURL *currentFileURL;
@property (assign ,nonatomic) CGFloat totalVideoDur;

@property (strong, nonatomic) NSMutableArray *videoFileDataArray;

@property (assign, nonatomic) BOOL isFrontCameraSupported;
@property (assign, nonatomic) BOOL isCameraSupported;
@property (assign, nonatomic) BOOL isTorchSupported;
@property (assign, nonatomic) BOOL isTorchOn;
@property (assign, nonatomic) BOOL isUsingFrontCamera;

@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;

@end

@implementation SBVideoRecorder

-(id)initWithView:(UIView*)preView
{
    self = [super init];
    if (self) {
        _preview = preView;
        [self initalize];
        
    }
    return self;
}

- (void)initalize
{
    [self initCapture];
    
    self.videoFileDataArray = [[NSMutableArray alloc] init];
    self.totalVideoDur = 0.0f;
}

- (void)initCapture
{
    //session---------------------------------
    effectiveScale = 1.0;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //input
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }

    [backCamera unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];

    if (self.videoDeviceInput)[_captureSession addInput:self.videoDeviceInput];
    if(audioDeviceInput) [_captureSession addInput:audioDeviceInput];
    
    //output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [_captureSession addOutput:_movieFileOutput];
    
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    
    [self setStillImageOutput:newStillImageOutput];

    
    //preset
    if(_isPhoto) _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    else _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    if ([_captureSession canAddOutput:newStillImageOutput]) {
        [_captureSession addOutput:newStillImageOutput];
    }

    //preview layer------------------
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_captureSession startRunning];
    
    UIPinchGestureRecognizer *guester = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    guester.delegate = self;
    [_preview addGestureRecognizer:guester];
    
}

- (void)startCountDurTimer
{
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
        [_delegate videoRecorder:self didRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDur recordedVideosTotalDur:_totalVideoDur];
    }
    
    if (_totalVideoDur + _currentVideoDur >= MAX_VIDEO_DUR) {
        [self stopCurrentVideoRecording];
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}

- (void)outMediaFile:(NSURL*)filePath
{
 
}


- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSError *error = nil;
        
        CGSize renderSize = CGSizeMake(0, 0);
        
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        CMTime totalDuration = kCMTimeZero;
        
       
        NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileURLArray) {
            AVAsset *asset = [AVAsset assetWithURL:fileURL];

            if (!asset) {
                continue;
            }
            
            [assetArray addObject:asset];
            
            AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
        
        CGFloat renderW = MIN(renderSize.width, renderSize.height);
        
        for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
          
            
            AVAsset *asset = (AVAsset*)[assetArray objectAtIndex:i];
            AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
            
            if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                    ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                     atTime:totalDuration
                                      error:&error];
            }
            else
            {
                NSLog(@"There is not audio file");
            }
            
            
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:assetTrack
                                 atTime:totalDuration
                                  error:&error];
            
            //fix orientationissue
            AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
            
            CGFloat rate;
            rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
            
            CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
            
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//
            
            layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//
            
            [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
            [layerInstruciton setOpacity:0.0 atTime:totalDuration];
            
            //data
            [layerInstructionArray addObject:layerInstruciton];
        }
        
        //get save path
        NSURL *mergeFileURL = [NSURL fileURLWithPath:[SBCaptureToolKit getVideoMergeFilePathString]];
        
        //export
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];//AVAssetExportPresetMediumQuality
        exporter.videoComposition = mainCompositionInst;
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                    [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
                }
            });
        }];
    });
}

- (void)makeOutPutAVData:(NSURL*) fileURLPath
{
    
}
- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _preViewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.preViewLayer;//
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [self.videoDeviceInput ports]) {//
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    //    NSLog(@"focus point: %f %f", point.x, point.y);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		AVCaptureDevice *device = [_videoDeviceInput device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
				[device setFocusMode:focusMode];
			}
            
			if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
				[device setExposureMode:exposureMode];
			}
            
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		} else {
        }
	});
}


#pragma mark - Method
- (void)focusInPoint:(CGPoint)touchPoint
{
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}



- (void)openTorch:(BOOL)open
{
    self.isTorchOn = open;
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera
{
    if (!_isFrontCameraSupported || !_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_isTorchOn) {
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession commitConfiguration];
}

- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isFrontCameraSupported;
}

- (void)mergeVideoFiles
{
    NSMutableArray *fileURLArray = [[NSMutableArray alloc] init];
    for (SBVideoData *data in _videoFileDataArray) {
        [fileURLArray addObject:data.fileURL];
    }
    
    [self mergeAndExportVideosAtFileURLs:fileURLArray];
}

- (CGFloat)getTotalVideoDuration
{
    return _totalVideoDur;
}

- (NSUInteger)getVideoCount
{
    return [_videoFileDataArray count];
}

- (void)startRecordingToOutputFileURL:(NSURL *)fileURL
{
    if (_totalVideoDur >= MAX_VIDEO_DUR) {
        return;
    }
    _movieFileOutput.movieFragmentInterval = CMTimeMake(MAX_VIDEO_DUR + 3, 1);
    [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)stopCurrentVideoRecording
{
    [self stopCountDurTimer];
    [_movieFileOutput stopRecording];
}

- (void)deleteAllVideo
{
    for (SBVideoData *data in _videoFileDataArray) {
        NSURL *videoFileURL = data.fileURL;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    NSLog(@"deleteAllVideo:%@", error);
                }
            }
        });
    }
}

- (void)deleteLastVideo
{
    if ([_videoFileDataArray count] == 0) {
        return;
    }
    
    SBVideoData *data = (SBVideoData *)[_videoFileDataArray lastObject];
    
    NSURL *videoFileURL = data.fileURL;
    CGFloat videoDuration = data.duration;
    [_videoFileDataArray removeLastObject];
    _totalVideoDur -= videoDuration;
    //delete
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //delegate
                if ([_delegate respondsToSelector:@selector(videoRecorder:didRemoveVideoFileAtURL:totalDur:error:)]) {
                    [_delegate videoRecorder:self didRemoveVideoFileAtURL:videoFileURL totalDur:_totalVideoDur error:error];
                }
            });
        }
    });
}

#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.currentFileURL = fileURL;
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    self.totalVideoDur = 0;
    
    if (!error) {
        SBVideoData *data = [[SBVideoData alloc] init];
        data.duration = _currentVideoDur;
        data.fileURL = outputFileURL;
        
        // This will make one Record file from Camera.
        [_videoFileDataArray removeAllObjects];
        // Always this is added on empty array.
        [_videoFileDataArray addObject:data];
    }
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDur totalDur:_totalVideoDur error:error];
    }
}



#pragma mark - Custom

- (void) captureStillImage
{
    
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
//    if ([device hasTorch] && _flashOn)
//    {
//        [device lockForConfiguration:nil];
//        [device setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
//        [device unlockForConfiguration];
//    }
//    
    AVCaptureConnection *stillImageConnection = [SBCaptureConnection connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    [stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
    
    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                             
                                                             ALAssetsLibraryWriteImageCompletionBlock completionBlock = ^(NSURL *assetURL, NSError *error) {
                                                                 if (error) {
                                                                     if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                                                         [[self delegate] captureManager:self didFailWithError:error];
                                                                     }
                                                                 }
                                                                 else
                                                                 {
                                                                     
                                                                     NSLog(@"%@",assetURL);
                                                                 }
                                                             };
                                                             
                                                             if (imageDataSampleBuffer != NULL)
                                                             {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 
                                                                 if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:image:)]) {
                                                                     
                                                                     UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                                                                     [[self delegate] captureManagerStillImageCaptured:self image:image];
                                                                     
                                                                 }
                                                                 
                                                                 
                                                                 
                                                             }
                                                             else
                                                                 completionBlock(nil, error);
                                                             
															                                              
                                }];
    
    
}

- (BOOL)isRecording
{
   return [[self movieFileOutput] isRecording];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}

// scale image depending on users pinch gesture
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:_preview];
        CGPoint convertedLocation = [_preViewLayer convertPoint:location fromLayer:_preViewLayer.superlayer];
        if ( ! [_preViewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        effectiveScale = beginGestureScale * recognizer.scale;
        if (effectiveScale < 1.0)
            effectiveScale = 1.0;
        CGFloat maxScaleAndCropFactor = [[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        if (effectiveScale > maxScaleAndCropFactor)
            effectiveScale = maxScaleAndCropFactor;
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [_preViewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
        [CATransaction commit];
    }
}

- (void)initCameraView:(UIView*)preCameraView
{
    effectiveScale = 1.0;
    [CATransaction begin];
    [_preViewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];
}

- (BOOL) isAdjustingFocus
{
    return [self.videoDeviceInput.device isAdjustingFocus];
}

@end
