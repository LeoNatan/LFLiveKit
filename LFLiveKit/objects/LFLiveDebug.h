//
//  LFLiveDebug.h
//  LaiFeng
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>

@interface LFLiveDebug : NSObject

@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *uploadUrl;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) BOOL isRtmp;

@property (nonatomic, assign) double elapsedMilli;                     ///< 距离上次统计的时间 单位ms
@property (nonatomic, assign) double timeStamp;
@property (nonatomic, assign) NSUInteger dataFlow;                         ///< 总流量
@property (nonatomic, assign) double bandwidth; //Over the period of one second
@property (nonatomic, assign) double currentBandwidth; //Last bandwidth measurement

@property (nonatomic, assign) NSUInteger droppedFramesCount;
@property (nonatomic, assign) NSUInteger totalFramesCount;

@property (nonatomic, assign) NSUInteger audioCaptureCount;
@property (nonatomic, assign) NSUInteger videoCaptureCount;
@property (nonatomic, assign) NSUInteger currentAudioCaptureCount;
@property (nonatomic, assign) NSUInteger currentVideoCaptureCount;

@property (nonatomic, assign) NSUInteger unsentFramesCount;

@end
