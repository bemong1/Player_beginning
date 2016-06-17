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

#pragma mark Notification

NSString *const PlayerControllerPlaybackStateDidChangeNotification = @"PlayerControllerPlaybackStateDidChangeNotification";
NSString *const PlayerControllerLoadStateDidChangeNotification = @"PlayerControllerLoadStateDidChangeNotification";
NSString *const PlayerControllerRateStateDidChangeNotification = @"PlayerControllerRateStateDidChangeNotification";
NSString *const PlayerControllerPlaybackDidPlayToEndTimeNotification = @"PlayerControllerPlaybackDidPlayToEndTimeNotification";


#pragma mark Init

- (id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        [self.layer backgroundColorRed:0.f green:0.f blue:0.f alpha:0.8f];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                
        [self setVideoGravity:VideoGravityResizeAspect];
        [self open:fileURL];
    }
    return self;
}

- (void)dealloc {    
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [_player removeObserver:self forKeyPath:@"rate"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if(context == ItemStatusContext) {
        if(_player.currentItem.status == AVPlayerStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setLoadState:LoadStateLoaded];
            });
        }
        return;
    } else if(context == PlaybackStatusContext) {
        if(_player.rate == 1.0f) {
            [self setRateState:RateStateNormal];
        } else {
            
        }
    }
}

- (void)open:(NSURL*)fileURL {
    AVURLAsset *asset= [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^() {
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            
            if(status == AVKeyValueStatusLoaded) {
                AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
                _player = [AVPlayer playerWithPlayerItem:playerItem];
                
                _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
                _playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
                _playerLayer.frame = self.bounds;
                [self.layer addSublayer:_playerLayer];
                self.layer.zPosition = -1;
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
                [_player.currentItem addObserver:self forKeyPath:@"status" options:0 context:ItemStatusContext];
                [_player addObserver:self forKeyPath:@"rate" options:0 context:PlaybackStatusContext];
                
                [self setLoadState:LoadStateLoading];
            } else {
                [self setLoadState:LoadStateFailed];
                NSLog(@"Fail");
            }
        });
    }];
}

- (void)playerItemDidReachEnd {
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerControllerPlaybackDidPlayToEndTimeNotification object:self];
}


#pragma mark Playback Controller

- (void)play {
    [_player play];
    [self setPlaybackState:PlaybackStatePlaying];
    NSLog(@"play");
}

- (void)pause {
    [_player pause];
    [self setPlaybackState:PlaybackStatePaused];
    NSLog(@"pause");
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

- (void)setRateState:(RateState)rateState {
    _rateState = rateState;
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayerControllerRateStateDidChangeNotification object:self];
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
    if(_rate > rate) {
        [self setRateState:RateStateDecrease];
        NSLog(@"decrease rate");
    } else if (_rate < rate) {
        [self setRateState:RateStateNormal];
        NSLog(@"increase rate");
    } else {
        NSLog(@"what situation??");
    }
    _player.rate = _rate = rate;
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
