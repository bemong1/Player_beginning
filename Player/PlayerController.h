
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
extern NSString *const PlayerControllerRateDidChangeNotification;


#pragma mark Init

- (id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect;
- (void)playerDidReadyToPlay;


#pragma mark Playback Controller

typedef NS_ENUM(NSInteger, PlaybackState) {
    PlaybackStatePaused,
    PlaybackStatePlaying,
    PlaybackStateBuffering,    
};

typedef NS_ENUM(NSInteger, LoadState) {
    LoadStateLoading,
    LoadStateLoaded,
    LoadStateFailed
};

typedef NS_ENUM(NSInteger, VideoGravity) {
    VideoGravityResize,
    VideoGravityResizeAspect,
    VideoGravityResizeAspectFill
};

@property (nonatomic, readonly) CGSize originalSize;

@property (nonatomic) PlaybackState latelyStateOnBuffer;
@property (nonatomic, readonly) PlaybackState playbackState;
@property (nonatomic, readonly) LoadState loadState;
@property (nonatomic) VideoGravity videoGravity;

@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic) float currentTime;
@property (nonatomic, readonly) float durationTime;

- (void)play;
- (void)pause;


@end