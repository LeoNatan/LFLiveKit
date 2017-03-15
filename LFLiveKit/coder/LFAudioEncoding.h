//
//  LFAudioEncoding.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LFAudioFrame.h"
#import "LFLiveAudioConfiguration.h"



@protocol LFAudioEncoding;

@protocol LFAudioEncodingDelegate <NSObject>
@required
- (void)audioEncoder:(nullable id<LFAudioEncoding>)encoder didOutputAudioFrame:(nullable LFAudioFrame *)frame;
@end

@protocol LFAudioEncoding <NSObject>
@required
- (void)encodeAudioData:(nullable NSData*)audioData timeStamp:(uint64_t)timeStamp;
- (void)stop;
@optional

@property (nonatomic, nullable, weak) id<LFAudioEncodingDelegate> delegate;

- (nullable instancetype)initWithAudioStreamConfiguration:(nullable LFLiveAudioConfiguration *)configuration;
- (nullable NSData *)adtsData:(NSInteger)channel rawDataLength:(NSInteger)rawDataLength;
@end

