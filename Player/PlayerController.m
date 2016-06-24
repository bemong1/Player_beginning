//
//  PlayerController.m
//  FinalPlayer
//
//  Created by kwk on 2016. 6. 3..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CALayer+AddMethod.h"

#import "PlayerController.h"

@interface PlayerController()

@property (nonatomic) AVPlayer* player;
@property (nonatomic) AVPlayerLayer* playerLayer;

@end


@implementation PlayerController

static void *PlaybackStatusContext = &PlaybackStatusContext;
static void *ItemStatusContext = &ItemStatusContext;
static void *RateStatusContext = &RateStatusContext;

static void *PlaybackLikelyToKeepUp = &PlaybackLikelyToKeepUp;
static void *PlaybackBufferEmpty = &PlaybackBufferEmpty;
static void *PlaybackBufferFull = &PlaybackBufferFull;
static void *PlaybackLoadedTimeRanges = &PlaybackLoadedTimeRanges;

#pragma mark Notification

NSString *const PlayerControllerPlaybackStateDidChangeNotification = @"PlayerControllerPlaybackStateDidChangeNotification";
NSString *const PlayerControllerLoadStateDidChangeNotification = @"PlayerControllerLoadStateDidChangeNotification";
NSString *const PlayerControllerPlaybackDidPlayToEndTimeNotification = @"PlayerControllerPlaybackDidPlayToEndTimeNotification";
NSString *const PlayerControllerRateDidChangeNotification = @"PlayerControllerRateDidChangeNotification";

#pragma mark Init

- (id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        [self.layer backgroundColorRed:0.f green:0.f blue:0.f alpha:0.8f];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self setVideoGravity:VideoGravityResizeAspect];
        [self open:fileURL];
        
        _rate = 1.0f;
        
    }
    return self;
}

- (void)dealloc {
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [_player removeObserver:self forKeyPath:@"rate"];
    
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" ];
    [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if(context == ItemStatusContext) {
        if(_player.currentItem.status == AVPlayerStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"onPrepared : %ld", _playbackState);
                [self playerDidReadyToPlay];
            });
        }
        return;
    }
    
    if(context == RateStatusContext) {
        if(_player.rate == 0.0f) {
            if(_playbackState != PlaybackStatePaused) {
                NSLog(@"onPause");
                [self setPlaybackState:PlaybackStatePaused];
            } else {
                if([change[NSKeyValueChangeNewKey] floatValue] != [change[NSKeyValueChangeOldKey] floatValue])
                    NSLog(@"onRateChanged");
            }
        } else {
            if(_playbackState != PlaybackStatePlaying) {
                NSLog(@"onPlay");
                [self setPlaybackState:PlaybackStatePlaying];
            } else {
                if([change[NSKeyValueChangeNewKey] floatValue] != [change[NSKeyValueChangeOldKey] floatValue])
                    NSLog(@"onRateChanged");
            }
        }
        return;
    }
    
    if (context == PlaybackLikelyToKeepUp) {
        if (_player.currentItem.playbackLikelyToKeepUp) {
            NSLog(@"Playable");
            if (_playbackState == PlaybackStateBuffering) {
                if(_latelyStateOnBuffer == PlaybackStatePaused) {
                    [self pause];
                } else if(_latelyStateOnBuffer == PlaybackStatePlaying) {
                    [self play];
                }
            }
        } else {
            NSLog(@"Impossible");
            _latelyStateOnBuffer = _playbackState;
            [self pause];
        }
        return;
    }
    
    if (context == PlaybackBufferEmpty) {
        if(_player.currentItem.playbackBufferEmpty) {
            NSLog(@"Buffering / lately state : %ld", (long)_playbackState);         

            [self setPlaybackState:PlaybackStateBuffering];
        }
        return;
    }
    
    if(context == PlaybackLoadedTimeRanges) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timeRange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            NSLog(@"Loaded Range : %.5f to %.5f", CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)));

        }
    }
}

- (void)playerDidReadyToPlay {
    [self setLoadState:LoadStateLoaded];
}

- (void)open:(NSURL*)fileURL {
    AVURLAsset *asset= [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    NSLog(@"opening...");
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^() {
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            
            if(status == AVKeyValueStatusLoaded) {
                NSLog(@"opened");
                [self setLoadState:LoadStateLoading];
                
                AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
                _player = [AVPlayer playerWithPlayerItem:playerItem];
                
                _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
                _playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
                _playerLayer.frame = self.bounds;
                
                [self.layer addSublayer:_playerLayer];
                self.layer.zPosition = -1;
                
                _originalSize = [[asset tracksWithMediaType:AVMediaTypeVideo][0] naturalSize];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
                
                [_player.currentItem addObserver:self forKeyPath:@"status" options:0 context:ItemStatusContext];
                [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:RateStatusContext];
                
                [_player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:PlaybackBufferEmpty];
                [_player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:PlaybackLikelyToKeepUp];
                [_player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:0 context:PlaybackBufferFull];
                [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:PlaybackLoadedTimeRanges];
            } else {
                [self setLoadState:LoadStateFailed];
                NSLog(@"%@", error);
            }
        });
    }];
}

- (void)playerItemDidReachEnd:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerControllerPlaybackDidPlayToEndTimeNotification object:self];
}


#pragma mark Playback Controller

- (void)play {
    NSLog(@"call play");
    if (_player.currentItem.playbackLikelyToKeepUp) {
        [self setRate:_rate];
        _player.rate = _rate;
    }
}

- (void)pause {
    NSLog(@"call pause");
    _player.rate = 0.0f;
}


#pragma mark Playback Controller (getter/setter)

- (void)setPlaybackState:(PlaybackState)playbackState {
    _playbackState = playbackState;
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerControllerPlaybackStateDidChangeNotification object:self];
}

- (void)setLoadState:(LoadState)loadState {
    _loadState = loadState;
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerControllerLoadStateDidChangeNotification object:self];
}

- (void)setVideoGravity:(VideoGravity)videoGravity {
    switch(videoGravity) {
        case VideoGravityResize:
            _playerLayer.videoGravity = AVLayerVideoGravityResize;
            _videoGravity = videoGravity;
            break;
        case VideoGravityResizeAspect:
            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            _videoGravity = videoGravity;
            break;
        case VideoGravityResizeAspectFill:
            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _videoGravity = videoGravity;
            break;
    }
}

- (void)setRate:(float)rate {
    if(rate != 0.0f) {
        if(_player.rate == 0.0f) {
            _rate = rate;
            NSLog(@"onRateChanged");
        } else {
            _player.rate = _rate = rate;
        }
    } else {
        _player.rate = rate;
    }
}

- (void)setCurrentTime:(float)currentTime {
    [_player seekToTime:CMTimeMakeWithSeconds(currentTime, _player.currentItem.asset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (float)currentTime {
    return CMTimeGetSeconds(_player.currentItem.currentTime);
}

- (float)durationTime {
    if(_player.currentItem == nil) {
        return 0.0f;
    }
    return CMTimeGetSeconds(_player.currentItem.duration);
}

- (void)setVolume:(float)volume {
    _player.volume = _volume = volume;
}

@end
