//
//  LFLiveAudioConfiguration.m
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import "LFLiveAudioConfiguration.h"
#import <sys/utsname.h>

@implementation LFLiveAudioConfiguration

#pragma mark -- LifyCycle
+ (instancetype)defaultConfiguration {
    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQualityDefault];
    return audioConfig;
}

+ (instancetype)defaultConfigurationForQuality:(LFLiveAudioQuality)audioQuality {
    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration new];
    audioConfig.numberOfChannels = 2;
    switch (audioQuality) {
    case LFLiveAudioQualityLow: {
        audioConfig.bitRate = audioConfig.numberOfChannels == 1 ? LFLiveAudioBitRate32Kbps : LFLiveAudioBitRate64Kbps;
        audioConfig.sampleRate = LFLiveAudioSampleRate16000Hz;
    }
        break;
    case LFLiveAudioQualityMedium: {
        audioConfig.bitRate = LFLiveAudioBitRate96Kbps;
        audioConfig.sampleRate = LFLiveAudioSampleRate44100Hz;
    }
        break;
    case LFLiveAudioQualityHigh: {
        audioConfig.bitRate = LFLiveAudioBitRate128Kbps;
        audioConfig.sampleRate = LFLiveAudioSampleRate44100Hz;
    }
        break;
    case LFLiveAudioQualityVeryHigh: {
        audioConfig.bitRate = LFLiveAudioBitRate128Kbps;
        audioConfig.sampleRate = LFLiveAudioSampleRate48000Hz;
    }
        break;
    default:{
        audioConfig.bitRate = LFLiveAudioBitRate96Kbps;
        audioConfig.sampleRate = LFLiveAudioSampleRate44100Hz;
    }
        break;
    }

    return audioConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        _asc = malloc(2);
    }
    return self;
}

- (void)dealloc {
    if (_asc) free(_asc);
}

#pragma mark Setter
- (void)setSampleRate:(LFLiveAudioSampleRate)sampleRate {
    _sampleRate = sampleRate;
    NSInteger sampleRateIndex = [self sampleRateIndex:sampleRate];
    self.asc[0] = 0x10 | ((sampleRateIndex>>1) & 0x7);
    self.asc[1] = ((sampleRateIndex & 0x1)<<7) | ((self.numberOfChannels & 0xF) << 3);
}

- (void)setNumberOfChannels:(NSUInteger)numberOfChannels {
    _numberOfChannels = numberOfChannels;
    NSInteger sampleRateIndex = [self sampleRateIndex:self.sampleRate];
    self.asc[0] = 0x10 | ((sampleRateIndex>>1) & 0x7);
    self.asc[1] = ((sampleRateIndex & 0x1)<<7) | ((numberOfChannels & 0xF) << 3);
}

- (NSUInteger)bufferLength{
    return 1024*2*self.numberOfChannels;
}

#pragma mark -- CustomMethod
- (NSInteger)sampleRateIndex:(NSInteger)frequencyInHz {
    NSInteger sampleRateIndex = 0;
    switch (frequencyInHz) {
    case 96000:
        sampleRateIndex = 0;
        break;
    case 88200:
        sampleRateIndex = 1;
        break;
    case 64000:
        sampleRateIndex = 2;
        break;
    case 48000:
        sampleRateIndex = 3;
        break;
    case 44100:
        sampleRateIndex = 4;
        break;
    case 32000:
        sampleRateIndex = 5;
        break;
    case 24000:
        sampleRateIndex = 6;
        break;
    case 22050:
        sampleRateIndex = 7;
        break;
    case 16000:
        sampleRateIndex = 8;
        break;
    case 12000:
        sampleRateIndex = 9;
        break;
    case 11025:
        sampleRateIndex = 10;
        break;
    case 8000:
        sampleRateIndex = 11;
        break;
    case 7350:
        sampleRateIndex = 12;
        break;
    default:
        sampleRateIndex = 15;
    }
    return sampleRateIndex;
}

#pragma mark -- Encoder
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.numberOfChannels) forKey:@"numberOfChannels"];
    [aCoder encodeObject:@(self.sampleRate) forKey:@"sampleRate"];
    [aCoder encodeObject:@(self.bitRate) forKey:@"bitrate"];
    [aCoder encodeObject:[NSString stringWithUTF8String:self.asc] forKey:@"asc"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _numberOfChannels = [[aDecoder decodeObjectForKey:@"numberOfChannels"] unsignedIntegerValue];
    _sampleRate = [[aDecoder decodeObjectForKey:@"sampleRate"] unsignedIntegerValue];
    _bitRate = [[aDecoder decodeObjectForKey:@"bitRate"] unsignedIntegerValue];
    _asc = strdup([[aDecoder decodeObjectForKey:@"asc"] cStringUsingEncoding:NSUTF8StringEncoding]);
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        LFLiveAudioConfiguration *object = other;
        return object.numberOfChannels == self.numberOfChannels &&
               object.bitRate == self.bitRate &&
               strcmp(object.asc, self.asc) == 0 &&
               object.sampleRate == self.sampleRate;
    }
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    NSArray *values = @[@(_numberOfChannels),
                        @(_sampleRate),
                        [NSString stringWithUTF8String:self.asc],
                        @(_bitRate)];

    for (NSObject *value in values) {
        hash ^= value.hash;
    }
    return hash;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LFLiveAudioConfiguration *other = [self.class defaultConfiguration];
    return other;
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    [desc appendFormat:@"<LFLiveAudioConfiguration: %p>", self];
    [desc appendFormat:@" numberOfChannels:%zi", self.numberOfChannels];
    [desc appendFormat:@" sampleRate:%zi", self.sampleRate];
    [desc appendFormat:@" bitRate:%zi", self.bitRate];
    [desc appendFormat:@" audioHeader:%@", [NSString stringWithUTF8String:self.asc]];
    return desc;
}

@end
