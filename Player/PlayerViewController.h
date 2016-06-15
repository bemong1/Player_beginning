//
//  PlayerViewController.h
//  Player-0610
//
//  Created by kwk on 2016. 6. 10..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlayerController.h"

@interface PlayerViewController : NSViewController

@property (nonatomic) PlayerController *playerController;

@property (nonatomic) float minRate;
@property (nonatomic) float maxRate;
@property (nonatomic) float currentRate;

@property (nonatomic) float currentTime;
@property (nonatomic, readonly) float remainingTime;
@property (nonatomic, readonly) float durationTime;

@property (nonatomic) float currentVolume;

@property (nonatomic) BOOL repeat;
@property (nonatomic) BOOL shuffle;
@property (nonatomic) BOOL mute;

@property (nonatomic) BOOL remainingTimeDisplay;

- (void)loadMediaFile:(NSURL*)url;
- (void)stopMediaFile;

- (void)playOrPause;

- (void)increasePlaybackRate;
- (void)restorePlaybackRate;
- (void)decreasePlaybackRate;
- (void)changeVideoGravity;

- (void)stepBackward;
- (void)stepForward;

//- (void)previous;
//- (void)next;

@end
