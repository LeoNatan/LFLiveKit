//
//  LFLiveVideoConfiguration.m
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import "LFLiveVideoConfiguration.h"
#import <AVFoundation/AVFoundation.h>


@implementation LFLiveVideoConfiguration

#pragma mark -- LifeCycle

+ (instancetype)defaultConfiguration {
    LFLiveVideoConfiguration *configuration = [LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQualityDefault];
    return configuration;
}

+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality {
    LFLiveVideoConfiguration *configuration = [LFLiveVideoConfiguration defaultConfigurationForQuality:videoQuality outputImageOrientation:UIInterfaceOrientationPortrait];
    return configuration;
}

+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality outputImageOrientation:(UIInterfaceOrientation)outputImageOrientation {
    LFLiveVideoConfiguration *configuration = [LFLiveVideoConfiguration new];
    switch (videoQuality) {
    case LFLiveVideoQualityLow1:{
        configuration.sessionPreset = LFCaptureSessionPreset360x640;
        configuration.frameRate = 15;
        configuration.maxFrameRate = 15;
        configuration.minFrameRate = 10;
        configuration.bitRate = 500 * 1000;
        configuration.maxBitRate = 600 * 1000;
        configuration.minBitRate = 400 * 1000;
        configuration.size = CGSizeMake(360, 640);
    }
        break;
    case LFLiveVideoQualityLow2:{
        configuration.sessionPreset = LFCaptureSessionPreset360x640;
        configuration.frameRate = 24;
        configuration.maxFrameRate = 24;
        configuration.minFrameRate = 12;
        configuration.bitRate = 600 * 1000;
        configuration.maxBitRate = 720 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(360, 640);
    }
        break;
    case LFLiveVideoQualityLow3: {
        configuration.sessionPreset = LFCaptureSessionPreset360x640;
        configuration.frameRate = 30;
        configuration.maxFrameRate = 30;
        configuration.minFrameRate = 15;
        configuration.bitRate = 800 * 1000;
        configuration.maxBitRate = 960 * 1000;
        configuration.minBitRate = 600 * 1000;
        configuration.size = CGSizeMake(360, 640);
    }
        break;
    case LFLiveVideoQualityMedium1:{
        configuration.sessionPreset = LFCaptureSessionPreset540x960;
        configuration.frameRate = 15;
        configuration.maxFrameRate = 15;
        configuration.minFrameRate = 10;
        configuration.bitRate = 800 * 1000;
        configuration.maxBitRate = 960 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(540, 960);
    }
        break;
    case LFLiveVideoQualityMedium2:{
        configuration.sessionPreset = LFCaptureSessionPreset540x960;
        configuration.frameRate = 24;
        configuration.maxFrameRate = 24;
        configuration.minFrameRate = 12;
        configuration.bitRate = 800 * 1000;
        configuration.maxBitRate = 960 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(540, 960);
    }
        break;
    case LFLiveVideoQualityMedium3:{
        configuration.sessionPreset = LFCaptureSessionPreset540x960;
        configuration.frameRate = 30;
        configuration.maxFrameRate = 30;
        configuration.minFrameRate = 15;
        configuration.bitRate = 1000 * 1000;
        configuration.maxBitRate = 1200 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(540, 960);
    }
        break;
    case LFLiveVideoQualityHigh1:{
        configuration.sessionPreset = LFCaptureSessionPreset720x1280;
        configuration.frameRate = 15;
        configuration.maxFrameRate = 15;
        configuration.minFrameRate = 10;
        configuration.bitRate = 1000 * 1000;
        configuration.maxBitRate = 1200 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(720, 1280);
    }
        break;
    case LFLiveVideoQualityHigh2:{
        configuration.sessionPreset = LFCaptureSessionPreset720x1280;
        configuration.frameRate = 24;
        configuration.maxFrameRate = 24;
        configuration.minFrameRate = 12;
        configuration.bitRate = 1200 * 1000;
        configuration.maxBitRate = 1440 * 1000;
        configuration.minBitRate = 500 * 1000;
        configuration.size = CGSizeMake(720, 1280);
    }
        break;
    case LFLiveVideoQualityHigh3:{
        configuration.sessionPreset = LFCaptureSessionPreset720x1280;
        configuration.frameRate = 30;
        configuration.maxFrameRate = 30;
        configuration.minFrameRate = 15;
        configuration.bitRate = 1200 * 1000;
        configuration.maxBitRate = 1440 * 1000;
        configuration.minBitRate = 800 * 1000;
        configuration.size = CGSizeMake(720, 1280);
    }
        break;
    default:
        break;
    }
    configuration.sessionPreset = [configuration supportSessionPreset:configuration.sessionPreset];
    configuration.maxKeyframeInterval = configuration.frameRate*2;
    configuration.outputImageOrientation = outputImageOrientation;
    CGSize size = configuration.size;
    if(configuration.landscape) {
        configuration.size = CGSizeMake(size.height, size.width);
    } else {
        configuration.size = CGSizeMake(size.width, size.height);
    }
    return configuration;
    
}

#pragma mark -- Setter Getter
- (NSString *)avSessionPreset {
    NSString *avSessionPreset = nil;
    switch (self.sessionPreset) {
    case LFCaptureSessionPreset360x640:{
        avSessionPreset = AVCaptureSessionPreset640x480;
    }
        break;
    case LFCaptureSessionPreset540x960:{
        avSessionPreset = AVCaptureSessionPresetiFrame960x540;
    }
        break;
    case LFCaptureSessionPreset720x1280:{
        avSessionPreset = AVCaptureSessionPreset1280x720;
    }
        break;
    default: {
        avSessionPreset = AVCaptureSessionPreset640x480;
    }
        break;
    }
    return avSessionPreset;
}

- (BOOL)landscape{
    return (self.outputImageOrientation == UIInterfaceOrientationLandscapeLeft || self.outputImageOrientation == UIInterfaceOrientationLandscapeRight) ? YES : NO;
}

- (CGSize)size{
    if(_sizeRespectingAspectRatio){
        return self.aspectRatioVideoSize;
    }
    return _size;
}

- (void)setMaxBitRate:(NSUInteger)maxBitRate {
    if (maxBitRate <= _bitRate) return;
    _maxBitRate = maxBitRate;
}

- (void)setMinBitRate:(NSUInteger)minBitRate {
    if (minBitRate >= _bitRate) return;
    _minBitRate = minBitRate;
}

- (void)setMaxFrameRate:(NSUInteger)maxFrameRate {
    if (maxFrameRate <= _frameRate) return;
    _maxFrameRate = maxFrameRate;
}

- (void)setMinFrameRate:(NSUInteger)minFrameRate {
    if (minFrameRate >= _frameRate) return;
    _minFrameRate = minFrameRate;
}

- (void)setSessionPreset:(LFLiveVideoSessionPreset)sessionPreset{
    _sessionPreset = sessionPreset;
    _sessionPreset = [self supportSessionPreset:sessionPreset];
}

#pragma mark -- Custom Method
- (LFLiveVideoSessionPreset)supportSessionPreset:(LFLiveVideoSessionPreset)sessionPreset {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *inputCamera;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices){
        if ([device position] == AVCaptureDevicePositionFront){
            inputCamera = device;
        }
    }
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([session canAddInput:videoInput]){
        [session addInput:videoInput];
    }
    
    if (![session canSetSessionPreset:self.avSessionPreset]) {
        if (sessionPreset == LFCaptureSessionPreset720x1280) {
            sessionPreset = LFCaptureSessionPreset540x960;
            if (![session canSetSessionPreset:self.avSessionPreset]) {
                sessionPreset = LFCaptureSessionPreset360x640;
            }
        } else if (sessionPreset == LFCaptureSessionPreset540x960) {
            sessionPreset = LFCaptureSessionPreset360x640;
        }
    }
    return sessionPreset;
}

- (CGSize)captureOutVideoSize{
    CGSize videoSize = CGSizeZero;
    switch (_sessionPreset) {
        case LFCaptureSessionPreset360x640:{
            videoSize = CGSizeMake(360, 640);
        }
            break;
        case LFCaptureSessionPreset540x960:{
            videoSize = CGSizeMake(540, 960);
        }
            break;
        case LFCaptureSessionPreset720x1280:{
            videoSize = CGSizeMake(720, 1280);
        }
            break;
            
        default:{
            videoSize = CGSizeMake(360, 640);
        }
            break;
    }
    
    if (self.landscape){
        return CGSizeMake(videoSize.height, videoSize.width);
    }
    return videoSize;
}

- (CGSize)aspectRatioVideoSize{
    CGSize size = AVMakeRectWithAspectRatioInsideRect(self.captureOutVideoSize, CGRectMake(0, 0, _size.width, _size.height)).size;
    NSInteger width = ceil(size.width);
    NSInteger height = ceil(size.height);
    if(width %2 != 0) width = width - 1;
    if(height %2 != 0) height = height - 1;
    return CGSizeMake(width, height);
}

#pragma mark -- encoder
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithCGSize:self.size] forKey:@"size"];
    [aCoder encodeObject:@(self.frameRate) forKey:@"frameRate"];
    [aCoder encodeObject:@(self.maxFrameRate) forKey:@"maxFrameRate"];
    [aCoder encodeObject:@(self.minFrameRate) forKey:@"minFrameRate"];
    [aCoder encodeObject:@(self.maxKeyframeInterval) forKey:@"maxKeyframeInterval"];
    [aCoder encodeObject:@(self.bitRate) forKey:@"bitRate"];
    [aCoder encodeObject:@(self.maxBitRate) forKey:@"maxBitRate"];
    [aCoder encodeObject:@(self.minBitRate) forKey:@"minBitRate"];
    [aCoder encodeObject:@(self.sessionPreset) forKey:@"sessionPreset"];
    [aCoder encodeObject:@(self.outputImageOrientation) forKey:@"outputImageOrientation"];
    [aCoder encodeObject:@(self.autorotate) forKey:@"autorotate"];
    [aCoder encodeObject:@(self.sizeRespectingAspectRatio) forKey:@"sizeRespectingAspectRatio"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _size = [[aDecoder decodeObjectForKey:@"size"] CGSizeValue];
    _frameRate = [[aDecoder decodeObjectForKey:@"frameRate"] unsignedIntegerValue];
    _maxFrameRate = [[aDecoder decodeObjectForKey:@"maxFrameRate"] unsignedIntegerValue];
    _minFrameRate = [[aDecoder decodeObjectForKey:@"minFrameRate"] unsignedIntegerValue];
    _maxKeyframeInterval = [[aDecoder decodeObjectForKey:@"maxKeyframeInterval"] unsignedIntegerValue];
    _bitRate = [[aDecoder decodeObjectForKey:@"bitRate"] unsignedIntegerValue];
    _maxBitRate = [[aDecoder decodeObjectForKey:@"maxBitRate"] unsignedIntegerValue];
    _minBitRate = [[aDecoder decodeObjectForKey:@"minBitRate"] unsignedIntegerValue];
    _sessionPreset = [[aDecoder decodeObjectForKey:@"sessionPreset"] unsignedIntegerValue];
    _outputImageOrientation = [[aDecoder decodeObjectForKey:@"outputImageOrientation"] unsignedIntegerValue];
    _autorotate = [[aDecoder decodeObjectForKey:@"autorotate"] boolValue];
    _sizeRespectingAspectRatio = [[aDecoder decodeObjectForKey:@"sizeRespectingAspectRatio"] unsignedIntegerValue];
    return self;
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    NSArray *values = @[[NSValue valueWithCGSize:self.size],
                        @(self.frameRate),
                        @(self.maxFrameRate),
                        @(self.minFrameRate),
                        @(self.maxKeyframeInterval),
                        @(self.bitRate),
                        @(self.maxBitRate),
                        @(self.minBitRate),
                        self.avSessionPreset,
                        @(self.sessionPreset),
                        @(self.outputImageOrientation),
                        @(self.autorotate),
                        @(self.sizeRespectingAspectRatio)];

    for (NSObject *value in values) {
        hash ^= value.hash;
    }
    return hash;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        LFLiveVideoConfiguration *object = other;
        return CGSizeEqualToSize(object.size, self.size) &&
               object.frameRate == self.frameRate &&
               object.maxFrameRate == self.maxFrameRate &&
               object.minFrameRate == self.minFrameRate &&
               object.maxKeyframeInterval == self.maxKeyframeInterval &&
               object.bitRate == self.bitRate &&
               object.maxBitRate == self.maxBitRate &&
               object.minBitRate == self.minBitRate &&
               [object.avSessionPreset isEqualToString:self.avSessionPreset] &&
               object.sessionPreset == self.sessionPreset &&
               object.outputImageOrientation == self.outputImageOrientation &&
               object.autorotate == self.autorotate &&
               object.sizeRespectingAspectRatio == self.sizeRespectingAspectRatio;
    }
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LFLiveVideoConfiguration *other = [self.class defaultConfiguration];
    return other;
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    [desc appendFormat:@"<LFLiveVideoConfiguration: %p>", self];
    [desc appendFormat:@" size:%@", NSStringFromCGSize(self.size)];
    [desc appendFormat:@" sizeRespectingAspectRatio:%zi",self.sizeRespectingAspectRatio];
    [desc appendFormat:@" frameRate:%zi", self.frameRate];
    [desc appendFormat:@" maxFrameRate:%zi", self.maxFrameRate];
    [desc appendFormat:@" minFrameRate:%zi", self.minFrameRate];
    [desc appendFormat:@" maxKeyframeInterval:%zi", self.maxKeyframeInterval];
    [desc appendFormat:@" bitRate:%zi", self.bitRate];
    [desc appendFormat:@" maxBitRate:%zi", self.maxBitRate];
    [desc appendFormat:@" minBitRate:%zi", self.minBitRate];
    [desc appendFormat:@" avSessionPreset:%@", self.avSessionPreset];
    [desc appendFormat:@" sessionPreset:%zi", self.sessionPreset];
    [desc appendFormat:@" outputImageOrientation:%zi", self.outputImageOrientation];
    [desc appendFormat:@" autorotate:%zi", self.autorotate];
    return desc;
}

@end
