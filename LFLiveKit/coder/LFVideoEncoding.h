//
//  LFVideoEncoding.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFVideoFrame.h"
#import "LFLiveVideoConfiguration.h"

@protocol LFVideoEncoding;

@protocol LFVideoEncodingDelegate <NSObject>
@required
- (void)videoEncoder:(nullable id<LFVideoEncoding>)encoder didOutputVideoFrame:(nullable LFVideoFrame *)frame;
@end


@protocol LFVideoEncoding <NSObject>
@required
- (void)encodeVideoData:(nullable CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;
@optional
@property (nonatomic, assign) NSInteger videoBitRate;
@property (nonatomic, nullable, weak) id<LFVideoEncodingDelegate> delegate;
- (nullable instancetype)initWithVideoStreamConfiguration:(nullable LFLiveVideoConfiguration *)configuration;
- (void)stop;
@end

