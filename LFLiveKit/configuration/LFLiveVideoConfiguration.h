//
//  LFLiveVideoConfiguration.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LFLiveVideoConfiguration : NSObject<NSCoding, NSCopying>

+ (instancetype)defaultConfiguration;

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

@property (nonatomic, assign, readonly) BOOL landscape;

@end
