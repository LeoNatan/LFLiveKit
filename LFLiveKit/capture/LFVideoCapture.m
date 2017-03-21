//
//  LFVideoCapture.m
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import "LFVideoCapture.h"

@interface LFVideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
	LFLiveVideoConfiguration* _configuration;
	AVCaptureSession* _captureSession;
	AVCaptureVideoPreviewLayer* _previewLayer;
	AVCaptureDevice* _captureDevice;
	AVCaptureDeviceInput* _captureDeviceInput;
	AVCaptureVideoDataOutput* _captureOutput;
}

@end

@implementation LFVideoCapture

#pragma mark -- LifeCycle
- (instancetype)initWithVideoConfiguration:(LFLiveVideoConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
		
		_captureSession = [AVCaptureSession new];
		
		[_captureSession beginConfiguration];
		
		_captureDevicePosition = AVCaptureDevicePositionBack;
		
		_captureOutput = [AVCaptureVideoDataOutput new];
		[_captureOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)];
		
		[self _setupCaptureDevice];
		
        self.zoomScale = 1.0;
		self.frameRate = configuration.frameRate;
		
		[_captureSession addOutput:_captureOutput];
		[[_captureOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
		
		
		[_captureSession commitConfiguration];
    }
    return self;
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupCaptureDevice
{
	if(_captureDeviceInput)
	{
		[_captureSession removeInput:_captureDeviceInput];
		_captureDevice = nil;
		_captureDeviceInput = nil;
	}
	
	[[AVCaptureDevice devices] enumerateObjectsUsingBlock:^(AVCaptureDevice* _Nonnull captureDevice, NSUInteger idx, BOOL * _Nonnull stop) {
		if(captureDevice.position == _captureDevicePosition)
		{
			_captureDevice = captureDevice;
			*stop = YES;
		}
	}];
	
	int32_t l = MIN(_configuration.size.width, _configuration.size.height);
	int32_t h = MAX(_configuration.size.width, _configuration.size.height);
	
	__block AVCaptureDeviceFormat* candidateFormat = nil;
	[_captureDevice.formats enumerateObjectsUsingBlock:^(AVCaptureDeviceFormat* _Nonnull format, NSUInteger idx, BOOL * _Nonnull stop) {
		CMVideoDimensions dim = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
		
		int32_t ll = MIN(dim.width, dim.height);
		int32_t hh = MAX(dim.width, dim.height);
		
		if(ll == l && hh == h)
		{
			AVFrameRateRange* currentFrameRateRange = format.videoSupportedFrameRateRanges.firstObject;
			AVFrameRateRange* candidateFrameRateRange = candidateFormat.videoSupportedFrameRateRanges.firstObject;
			
			if(candidateFormat == nil || currentFrameRateRange.maxFrameRate >= candidateFrameRateRange.maxFrameRate)
			{
				candidateFormat = format;
			}
		}
	}];
	
	if(candidateFormat == nil)
	{
		NSLog(@"Was not able to find a capture device with %@ size.", NSStringFromCGSize(_configuration.size));
		candidateFormat = _captureDevice.formats.lastObject;
	}
	
	_captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:NULL];
	[_captureSession addInput:_captureDeviceInput];
	
	[_captureDevice lockForConfiguration:NULL];
	_captureDevice.activeFormat = candidateFormat;
	[_captureDevice unlockForConfiguration];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
	[self.delegate videoCapture:self didOutputPixelBuffer:pixelBuffer];
}

#pragma mark -- Setter Getter

- (void)setRunning:(BOOL)running {
    if (_running == running) return;
    _running = running;
    
    if (_running) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
		[_captureSession startRunning];
	} else {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
		[_captureSession stopRunning];
	}
}

- (void)setPreviewView:(UIView *)previewView {
	_previewView = previewView;
	
	if(_previewLayer)
	{
		[_previewLayer removeFromSuperlayer];
	}
	
	if(_previewLayer == nil)
	{
		_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
	}
	
	[_previewView.layer insertSublayer:_previewLayer atIndex:0];
	_previewLayer.frame = previewView.layer.frame;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition
{
    if(_captureDevicePosition == captureDevicePosition) return;
	
	[self _setupCaptureDevice];
	[self setFrameRate:self.frameRate];
}

- (void)setFrameRate:(NSInteger)frameRate
{
	AVFrameRateRange* candidateFrameRateRange = _captureDevice.activeFormat.videoSupportedFrameRateRanges.firstObject;
	
	frameRate = MIN(frameRate, candidateFrameRateRange.maxFrameRate);
	[_captureDevice lockForConfiguration:NULL];
	_captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)frameRate);
	[_captureDevice unlockForConfiguration];
	
	_frameRate = frameRate;
}

- (void)setZoomScale:(CGFloat)zoomScale {
	AVCaptureDevice *device = _captureDevice;
	if ([device lockForConfiguration:nil]) {
		device.videoZoomFactor = zoomScale;
		[device unlockForConfiguration];
		_zoomScale = zoomScale;
	}
}

#pragma mark Notification

- (void)willEnterBackground:(NSNotification *)notification {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [self.videoCamera pauseCameraCapture];
}

- (void)willEnterForeground:(NSNotification *)notification {
//    [self.videoCamera resumeCameraCapture];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

//- (void)statusBarChanged:(NSNotification *)notification {
//    NSLog(@"UIApplicationWillChangeStatusBarOrientationNotification. UserInfo: %@", notification.userInfo);
//    UIInterfaceOrientation statusBar = [[UIApplication sharedApplication] statusBarOrientation];
//
//    if(self.configuration.autorotate){
//        if (self.configuration.landscape) {
//            if (statusBar == UIInterfaceOrientationLandscapeLeft) {
//                self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
//            } else if (statusBar == UIInterfaceOrientationLandscapeRight) {
//                self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
//            }
//        } else {
//            if (statusBar == UIInterfaceOrientationPortrait) {
//                self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
//            } else if (statusBar == UIInterfaceOrientationPortraitUpsideDown) {
//                self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//            }
//        }
//    }
//}

@end
