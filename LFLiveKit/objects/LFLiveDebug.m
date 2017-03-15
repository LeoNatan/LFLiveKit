//
//  LFLiveDebug.m
//  LaiFeng
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import "LFLiveDebug.h"

@implementation LFLiveDebug

- (NSString *)description {
    return [NSString stringWithFormat:@"Dropped Frames: %lu\tFrame Count: %lu\tCaptured Audio Count: %lu\tCaptured Video Count: %lu\tUnsent Count: %lu\tTotal: %lu",(unsigned long)_droppedFramesCount,(unsigned long)_totalFramesCount,(unsigned long)_currentAudioCaptureCount,(unsigned long)_currentVideoCaptureCount,(unsigned long)_unsentFramesCount,(unsigned long)_dataFlow];
}


@end
