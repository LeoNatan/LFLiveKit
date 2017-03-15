//
//  LFLiveVideoConfiguration.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, LFLiveVideoSessionPreset){
    LFCaptureSessionPreset360x640 = 0,
    LFCaptureSessionPreset540x960 = 1,
    LFCaptureSessionPreset720x1280 = 2
};

typedef NS_ENUM (NSUInteger, LFLiveVideoQuality){
    LFLiveVideoQualityLow1 = 0,
    LFLiveVideoQualityLow2 = 1,
    LFLiveVideoQualityLow3 = 2,
    LFLiveVideoQualityMedium1 = 3,
    LFLiveVideoQualityMedium2 = 4,
    LFLiveVideoQualityMedium3 = 5,
    LFLiveVideoQualityHigh1 = 6,
    LFLiveVideoQualityHigh2 = 7,
    LFLiveVideoQualityHigh3 = 8,
    LFLiveVideoQualityDefault = LFLiveVideoQualityLow2
};

@interface LFLiveVideoConfiguration : NSObject<NSCoding, NSCopying>

+ (instancetype)defaultConfiguration;
+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality;

+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality outputImageOrientation:(UIInterfaceOrientation)outputImageOrientation;

#pragma mark - Attribute
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) BOOL sizeRespectingAspectRatio;

@property (nonatomic, assign) UIInterfaceOrientation outputImageOrientation;

@property (nonatomic, assign) BOOL autorotate;

@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) NSUInteger maxFrameRate;
@property (nonatomic, assign) NSUInteger minFrameRate;
@property (nonatomic, assign) NSUInteger maxKeyframeInterval;

@property (nonatomic, assign) NSUInteger bitRate;
@property (nonatomic, assign) NSUInteger maxBitRate;
@property (nonatomic, assign) NSUInteger minBitRate;

@property (nonatomic, assign) LFLiveVideoSessionPreset sessionPreset;

@property (nonatomic, assign, readonly) NSString *avSessionPreset;
@property (nonatomic, assign, readonly) BOOL landscape;

@end
