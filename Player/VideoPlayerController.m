//
//  MoviePlayerController.m
//  Player
//
//  Created by kwk on 2016. 6. 20..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "VideoPlayerController.h"

#import "CALayer+AddMethod.h"

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
