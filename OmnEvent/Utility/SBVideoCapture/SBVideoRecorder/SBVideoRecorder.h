//
//  SBVideoRecorder.h
//  SBVideoCaptureDemo
//

//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class SBVideoRecorder;
@protocol SBVideoRecorderDelegate <NSObject>

@optional

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;


- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;


- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur;

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error;


- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;


// Capture Image

- (void)captureManager:(SBVideoRecorder *)videoRecorder didFailWithError:(NSError *)error;
- (void)captureManagerStillImageCaptured:(SBVideoRecorder *)videoRecorder image:(UIImage *)image;

@end

@interface SBVideoRecorder : NSObject <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>
{
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
}

@property (weak, nonatomic) id <SBVideoRecorderDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIView *preview;
@property (readwrite) BOOL isPhoto;




- (id)initWithView:(UIView*) preView;
- (CGFloat)getTotalVideoDuration;
- (void)stopCurrentVideoRecording;
- (void)startRecordingToOutputFileURL:(NSURL *)fileURL;

- (void)deleteLastVideo; //
- (void)deleteAllVideo;  //
- (NSUInteger)getVideoCount;

- (void)mergeVideoFiles;

- (BOOL)isCameraSupported;
- (BOOL)isFrontCameraSupported;
- (BOOL)isTorchSupported;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;

- (void)focusInPoint:(CGPoint)touchPoint;

- (void)captureStillImage;

- (BOOL)isRecording;

- (void)initCameraView:(UIView*)preCameraView;
- (BOOL)isAdjustingFocus;


@end
