//
//  LFHardwareVideoEncoder.m
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//
#import "LFHardwareVideoEncoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface LFHardwareVideoEncoder (){
    VTCompressionSessionRef _compressionSession;
    NSInteger _frameCount;
    NSData *_sps;
    NSData *_pps;
    FILE *_fp;
    BOOL _enabledWriteVideoFile;
}

@property (nonatomic, strong) LFLiveVideoConfiguration *configuration;
@property (nonatomic) NSInteger currentVideoBitRate;
@property (nonatomic) BOOL isBackGround;

@end

@implementation LFHardwareVideoEncoder

#pragma mark -- LifeCycle
- (instancetype)initWithVideoStreamConfiguration:(LFLiveVideoConfiguration *)configuration {
    if (self = [super init]) {
        NSLog(@"USE LFHardwareVideoEncoder");
        _configuration = configuration;
        [self resetCompressionSession];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
#ifdef DEBUG
        enabledWriteVideoFile = NO;
        [self initForFilePath];
#endif
        
    }
    return self;
}

- (void)resetCompressionSession {
    if (_compressionSession) {
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);

        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }

    OSStatus status = VTCompressionSessionCreate(NULL, _configuration.size.width, _configuration.size.height, kCMVideoCodecType_H264, NULL, NULL, NULL, VideoCompressonOutputCallback, (__bridge void *)self, &_compressionSession);
    if (status != noErr) {
        return;
    }

    _currentVideoBitRate = _configuration.bitRate;
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(_configuration.maxKeyframeInterval));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)@(_configuration.maxKeyframeInterval/_configuration.frameRate));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(_configuration.frameRate));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(_configuration.bitRate));
    NSArray *limit = @[@(_configuration.bitRate * 1.5/8), @(1)];
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanTrue);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_H264EntropyMode, kVTH264EntropyMode_CABAC);
    VTCompressionSessionPrepareToEncodeFrames(_compressionSession);

}

- (void)setVideoBitRate:(NSInteger)videoBitRate {
    if(_isBackGround) return;
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(videoBitRate));
    NSArray *limit = @[@(videoBitRate * 1.5/8), @(1)];
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    _currentVideoBitRate = videoBitRate;
}

- (NSInteger)videoBitRate {
    return _currentVideoBitRate;
}

- (void)dealloc {
    if (_compressionSession != NULL) {
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);

        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- LFVideoEncoder

@synthesize delegate=_delegate;

- (void)encodeVideoData:(CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp {
    if(_isBackGround) return;
    _frameCount++;
    CMTime presentationTimeStamp = CMTimeMake(_frameCount, (int32_t)_configuration.frameRate);
    VTEncodeInfoFlags flags;
    CMTime duration = CMTimeMake(1, (int32_t)_configuration.frameRate);

    NSDictionary *properties = nil;
    if (_frameCount % (int32_t)_configuration.maxKeyframeInterval == 0) {
        properties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @YES};
    }
    NSNumber *timeNumber = @(timeStamp);

    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSession, pixelBuffer, presentationTimeStamp, duration, (__bridge CFDictionaryRef)properties, (__bridge_retained void *)timeNumber, &flags);
    if(status != noErr){
        [self resetCompressionSession];
    }
}

- (void)stop {
    VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeIndefinite);
}

#pragma mark -- Notification
- (void)willEnterBackground:(NSNotification*)notification{
    _isBackGround = YES;
}

- (void)willEnterForeground:(NSNotification*)notification{
    [self resetCompressionSession];
    _isBackGround = NO;
}

#pragma mark -- VideoCallBack
static void VideoCompressonOutputCallback(void *VTref, void *VTFrameRef, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer){
    if (!sampleBuffer) return;
    CFArrayRef array = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if (!array) return;
    CFDictionaryRef dic = (CFDictionaryRef)CFArrayGetValueAtIndex(array, 0);
    if (!dic) return;

    BOOL keyframe = !CFDictionaryContainsKey(dic, kCMSampleAttachmentKey_NotSync);
    uint64_t timeStamp = [((__bridge_transfer NSNumber *)VTFrameRef) longLongValue];

    LFHardwareVideoEncoder *videoEncoder = (__bridge LFHardwareVideoEncoder *)VTref;
    if (status != noErr) {
        return;
    }

    if (keyframe && !videoEncoder->_sps) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);

        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
        if (statusCode == noErr) {
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            if (statusCode == noErr) {
                videoEncoder->_sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                videoEncoder->_pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];

                if (videoEncoder->_enabledWriteVideoFile) {
                    NSMutableData *data = [[NSMutableData alloc] init];
                    uint8_t header[] = {0x00, 0x00, 0x00, 0x01};
                    [data appendBytes:header length:4];
                    [data appendData:videoEncoder->_sps];
                    [data appendBytes:header length:4];
                    [data appendData:videoEncoder->_pps];
                    fwrite(data.bytes, 1, data.length, videoEncoder->_fp);
                }

            }
        }
    }


    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);

            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);

            LFVideoFrame *videoFrame = [LFVideoFrame new];
            videoFrame.timestamp = timeStamp;
            videoFrame.data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            videoFrame.isKeyFrame = keyframe;
            videoFrame.sps = videoEncoder->_sps;
            videoFrame.pps = videoEncoder->_pps;

            if (videoEncoder.delegate && [videoEncoder.delegate respondsToSelector:@selector(videoEncoder:didOutputVideoFrame:)]) {
                [videoEncoder.delegate videoEncoder:videoEncoder didOutputVideoFrame:videoFrame];
            }

            if (videoEncoder->_enabledWriteVideoFile) {
                NSMutableData *data = [[NSMutableData alloc] init];
                if (keyframe) {
                    uint8_t header[] = {0x00, 0x00, 0x00, 0x01};
                    [data appendBytes:header length:4];
                } else {
                    uint8_t header[] = {0x00, 0x00, 0x01};
                    [data appendBytes:header length:3];
                }
                [data appendData:videoFrame.data];

                fwrite(data.bytes, 1, data.length, videoEncoder->_fp);
            }


            bufferOffset += AVCCHeaderLength + NALUnitLength;

        }

    }
}

- (void)initForFilePath {
    NSString *path = [self GetFilePathByfileName:@"IOSCamDemo.h264"];
    NSLog(@"%@", path);
    self->_fp = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "wb");
}

- (NSString *)GetFilePathByfileName:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return writablePath;
}

@end
