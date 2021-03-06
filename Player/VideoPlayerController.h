//
//  MoviePlayerController.h
//  Player
//
//  Created by kwk on 2016. 6. 20..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "PlayerController.h"

@interface VideoPlayerController : PlayerController 


- (id)initWithMediaFileURL:(NSURL*)fileURL andRect:(NSRect)frameRect;


@property (nonatomic) float minRate;
@property (nonatomic) float maxRate;

@property (nonatomic) float currentVolume;

@property (nonatomic) BOOL repeat;
@property (nonatomic) BOOL shuffle;
@property (nonatomic) BOOL mute;

- (void)playOrPause;

- (void)increasePlaybackRate;
- (void)restorePlaybackRate;
- (void)decreasePlaybackRate;

- (void)changeVideoGravity;
- (void)changeVideoResize:(float)scale;

- (void)stepBackward;
- (void)stepForward;


@end
