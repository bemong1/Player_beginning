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

- (void)playerDidReadyToPlay {
    [super playerDidReadyToPlay];
    
    
}

- (void)dealloc {
    NSLog(@"VideoPlayerController destroy!");
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
    } else if(self.playbackState == PlaybackStateBuffering) {
        if(self.latelyStateOnBuffer == PlaybackStatePlaying) {
            [self play];
        } else if (self.latelyStateOnBuffer == PlaybackStatePaused) {
            [self pause];
        }
    }
    
}

- (void)increasePlaybackRate {
    if(self.rate >= _maxRate) {
        self.rate = _maxRate;
        return;
    }
    [self setRate:self.rate + 0.1f];
}

- (void)restorePlaybackRate {
//    if(self.rate == 1.0f)
//        return;
    [self setRate:1.0f];
}

- (void)decreasePlaybackRate {
    if(self.rate <= _minRate) {
        self.rate = _minRate;
        return;
    }
    [self setRate:self.rate - 0.1f];
}

- (void)changeVideoGravity {
    [self setFrame:NSMakeRect(0,
                              0,
                              self.window.frame.size.width,
                              self.window.frame.size.height)];
    self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    
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

- (void)changeVideoResize:(float)scale {
    [self setFrameSize:NSMakeSize(self.originalSize.width * scale, self.originalSize.height * scale)];
    [self setFrame:NSMakeRect((self.window.frame.size.width - self.frame.size.width) * (1/2.),
                              (self.window.frame.size.height - self.frame.size.height) * (1/2.),
                              self.frame.size.width,
                              self.frame.size.height)];
    
    self.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
}

- (void)stepBackward {
    [self setCurrentTime:self.currentTime - 5.0f];
}

- (void)stepForward {
    [self setCurrentTime:self.currentTime + 5.0f];
}


@end
