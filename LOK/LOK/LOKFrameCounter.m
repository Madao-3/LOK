//
//  LOKFrameCounter.m
//  LOK
//
//  Created by Madao on 12/30/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "LOKFrameCounter.h"
#import <QuartzCore/QuartzCore.h>
#import <SpriteKit/SpriteKit.h>
static NSInteger const kHardwareFramesPerSecond = 60;
static NSTimeInterval const kNormalFrameDuration = 1.0 / kHardwareFramesPerSecond;
@interface LOKFrameCounter (){
    CFTimeInterval _lastSecondOfFrameTimes[kHardwareFramesPerSecond];
}
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSInteger frameNumber;
@end

@implementation LOKFrameCounter

+ (instancetype)shareCounter {
    static LOKFrameCounter *shareCounter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCounter = [[self alloc] init];
        [shareCounter start];
    });
    return shareCounter;
}

- (void)start {
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self resetSecondOfFrameTimes];
}

- (CFTimeInterval)lastFrameTime {
    return _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond];
}


- (void)displayLinkWillDraw:(CADisplayLink *)displayLink {
    [self recordFrameTime:displayLink.timestamp];
}

- (void)recordFrameTime:(CFTimeInterval)frameTime {
    ++self.frameNumber;
    _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond] = frameTime;
}

- (void)resetSecondOfFrameTimes {
    CFTimeInterval initialFrameTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        _lastSecondOfFrameTimes[i] = initialFrameTime;
    }
    self.frameNumber = 0;
}

- (NSInteger)fps {
    if (self.frameNumber < kHardwareFramesPerSecond) {
        return 0;
    }
    return kHardwareFramesPerSecond - self.droppedFrameCountInLastSecond;
}

- (NSInteger)droppedFrameCountInLastSecond {
    NSInteger droppedFrameCount = 0;
    CFTimeInterval lastFrameTime = CACurrentMediaTime() - kNormalFrameDuration;
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        if (1.0 <= lastFrameTime - _lastSecondOfFrameTimes[i]) {
            ++droppedFrameCount;
        }
    }
    
    return droppedFrameCount;
}


@end
