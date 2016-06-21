//
//  MoviePlayerController.m
//  Player
//
//  Created by kwk on 2016. 6. 20..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "VideoPlayerController.h"
#import "RepeatIntervalController.h"

#import "CALayer+AddMethod.h"

@interface VideoPlayerController ()

@property (nonatomic) RepeatIntervalController *repeatIntervalController;
@property (strong) NSTimer *repeatIntervalTimer;

@end


@implementation VideoPlayerController

- (id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect {
    self = [super initWithMediaFileURL:fileURL andRect:frameRect];
    if (self != nil) {
        _currentVolume = 1.0f;
        _minRate = 0.5f;
        _maxRate = 2.0f;        
    }
    return self;
}

- (void)playerDidReadyToPlay {
    [super playerDidReadyToPlay];
    
    _endTime = self.durationTime;
    [self setRate:1.0f];
}


#pragma mark Playback Controller (getter/setter)

- (void)setCurrentVolume:(float)currentVolume {
    [self setVolume:_currentVolume];
    _currentVolume = currentVolume;
}

- (void)setMute:(BOOL)mute {
    if(mute == NO) {
        [self setVolume:_currentVolume];
    } else {
        [self setVolume:0.0f];
    }
    _mute = mute;
}


#pragma mark API

- (void)playOrPause {
    if(self.playbackState == PlaybackStatePlaying) {
        [self pause];
    } else if(self.playbackState == PlaybackStatePaused) {
        [self play];
    }
}

- (void)increasePlaybackRate {
    [self setRate:self.rate + 0.1f];
    if(self.rate > (_maxRate - 0.05f)) {
        self.rate = _maxRate;
    }
}

- (void)restorePlaybackRate {
    [self setRate:1.0f];
}

- (void)decreasePlaybackRate {
    [self setRate:self.rate - 0.1f];
    if(self.rate < (_minRate + 0.05f)) {
        self.rate = _minRate;
    }
}

- (void)changeVideoGravity {
//    self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    switch(self.videoGravity) {
        case VideoGravityResize:
            self.videoGravity = VideoGravityResizeAspectFill;
            break;
        case VideoGravityResizeAspect:
            self.videoGravity = VideoGravityResize;
            break;
        case VideoGravityResizeAspectFill:
            self.videoGravity = VideoGravityResizeAspect;
            break;
    }
}

- (void)setStartTime:(float)startTime {
    if(_isStartTime == NO) {
        if(startTime != 0.0f) {
            _isStartTime = YES;
        } else {
            _isStartTime = NO;
        }
        _startTime = startTime;
    } else {
        _startTime = 0.0f;
        _isStartTime = NO;
    }
}

- (void)setEndTime:(float)endTime {
    if(_isEndTime == NO) {
        if(endTime != self.durationTime) {
            _isEndTime = YES;
        } else {
            _isEndTime = NO;
        }
        _endTime = endTime;
    } else {
        _endTime = self.durationTime;
        _isEndTime = NO;
    }    
}

- (BOOL)stateRepeatInterval {
    if(_isStartTime || _isEndTime) {
        NSLog(@"repeatInterval ON!!");
        if(_repeatIntervalTimer == nil) {
            _repeatIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(onRepeatIntervalTime:) userInfo:nil  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_repeatIntervalTimer forMode:NSRunLoopCommonModes];
        }
        return YES;
    } else {
        NSLog(@"repeatInterval!! OFF");
        if([_repeatIntervalTimer isValid]) {
            [_repeatIntervalTimer invalidate];
            _repeatIntervalTimer = nil;
        }
        return NO;
    }
}

- (void)onRepeatIntervalTime:(NSTimer*)timer {
    if(_startTime - 0.01f > self.currentTime || _endTime < self.currentTime) {
        self.currentTime = _startTime;
    }
    NSLog(@"start:%f, current:%f, end:%f", _startTime, self.currentTime, _endTime);
}

- (void)changeVideoResize {
    static int scale;
    scale ++;
    scale = scale % 4;
    [self setViewFrameScale:(float)scale + 1.0f];
}

- (void)stepBackward {
    [self setCurrentTime:self.currentTime - 5.0f];
}

- (void)stepForward {
    [self setCurrentTime:self.currentTime + 5.0f];
}

- (void)setViewFrameScale:(float)scale {
    [self willRemoveSubview:self];
    
    self.autoresizingMask = NSViewNotSizable;
    
    [self setFrameSize:NSMakeSize(self.originalSize.width * scale, self.originalSize.height * scale)];
    [self setFrame:NSMakeRect((self.window.frame.size.width - self.frame.size.width) * (1/2.),
                                                (self.window.frame.size.height - self.frame.size.height) * (1/2.),
                                                self.frame.size.width,
                                                self.frame.size.height)];
    
    self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    
    NSLog(@"%f, %f", self.frame.origin.x, self.frame.origin.y);
}

@end
