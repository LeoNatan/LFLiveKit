//
//  LFVideoCapture.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LFLiveVideoConfiguration.h"

@class LFVideoCapture;
/** LFVideoCapture callback videoData */
@protocol LFVideoCaptureDelegate <NSObject>
- (void)videoCapture:(nullable LFVideoCapture *)capture didOutputPixelBuffer:(nullable CVPixelBufferRef)pixelBuffer;
@end

@interface LFVideoCapture : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/** The delegate of the capture. captureData callback */
@property (nullable, nonatomic, weak) id<LFVideoCaptureDelegate> delegate;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

/** The preview will show OpenGL ES view*/
@property (null_resettable, nonatomic, strong) UIView *previewView;

/** The captureDevicePosition control camraPosition ,default front*/
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

/** The torch control camera zoom scale default 1.0, between 1.0 ~ 3.0 */
@property (nonatomic, assign) CGFloat zoomScale;

/** The frameRate control videoCapture output data count */
@property (nonatomic, assign) NSInteger frameRate;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
   The designated initializer. Multiple instances with the same configuration will make the
   capture unstable.
 */
- (nullable instancetype)initWithVideoConfiguration:(nullable LFLiveVideoConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end
