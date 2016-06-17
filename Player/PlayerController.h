
//
//  PlayerController.h
//  FinalPlayer
//
//  Created by kwk on 2016. 6. 3..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlayerController : NSView

#pragma mark Notification

extern NSString *const PlayerControllerPlaybackStateDidChangeNotification;
extern NSString *const PlayerControllerLoadStateDidChangeNotification;
extern NSString *const PlayerControllerPlaybackDidPlayToEndTimeNotification;


#pragma mark Init

-(id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect;


#pragma mark Playback Controller

typedef NS_ENUM(NSInteger, PlaybackState) {
    PlaybackStatePaused,
    PlaybackStatePlaying,    
};

typedef NS_ENUM(NSInteger, LoadState) {
    LoadStateLoading,
    LoadStateLoaded,
    LoadStateFailed
};

typedef NS_ENUM(NSInteger, RateState) {
    RateStateNormal,
    RateStateIncrease,
    RateStateDecrease,
};

typedef NS_ENUM(NSInteger, VideoGravity) {
    VideoGravityResize,
    VideoGravityResizeAspect,
    VideoGravityResizeAspectFill
};

@property (nonatomic, readonly) PlaybackState playbackState;
@property (nonatomic, readonly) LoadState loadState;
@property (nonatomic, readonly) RateState rateState;
@property (nonatomic) VideoGravity videoGravity;

@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic) float currentTime;
@property (nonatomic, readonly) float durationTime;

- (void)play;
- (void)pause;

@end