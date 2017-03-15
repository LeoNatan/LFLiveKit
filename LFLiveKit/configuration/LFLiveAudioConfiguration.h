//
//  LFLiveAudioConfiguration.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, LFLiveAudioBitRate) {
    LFLiveAudioBitRate32Kbps = 32000,
    LFLiveAudioBitRate64Kbps = 64000,
    LFLiveAudioBitRate96Kbps = 96000,
    LFLiveAudioBitRate128Kbps = 128000,
    LFLiveAudioBitRateDefault = LFLiveAudioBitRate96Kbps
};

typedef NS_ENUM (NSUInteger, LFLiveAudioSampleRate){
    LFLiveAudioSampleRate16000Hz = 16000,
    LFLiveAudioSampleRate44100Hz = 44100,
    LFLiveAudioSampleRate48000Hz = 48000,
    LFLiveAudioSampleRateDefault = LFLiveAudioSampleRate44100Hz
};

typedef NS_ENUM (NSUInteger, LFLiveAudioQuality){
    LFLiveAudioQualityLow = 0,
	LFLiveAudioQualityMedium = 1,
    LFLiveAudioQualityHigh = 2,
    LFLiveAudioQualityVeryHigh = 3,
    LFLiveAudioQualityDefault = LFLiveAudioQualityHigh
};

@interface LFLiveAudioConfiguration : NSObject<NSCoding, NSCopying>

+ (instancetype)defaultConfiguration;
+ (instancetype)defaultConfigurationForQuality:(LFLiveAudioQuality)audioQuality;

#pragma mark - Attribute

@property (nonatomic, assign) NSUInteger numberOfChannels;
@property (nonatomic, assign) LFLiveAudioSampleRate sampleRate;
@property (nonatomic, assign) LFLiveAudioBitRate bitRate;
@property (nonatomic, assign, readonly) char *asc;
@property (nonatomic, assign, readonly) NSUInteger bufferLength;

@end
