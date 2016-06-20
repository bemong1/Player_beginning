//
//  PlayerViewController.h
//  Player-0610
//
//  Created by kwk on 2016. 6. 10..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlayerController.h"
#import "VideoPlayerController.h"

@interface VideoPlayerViewController : NSViewController

@property (nonatomic) VideoPlayerController *videoPlayerController;

- (void)loadMediaFile:(NSURL*)url;
- (void)stopMediaFile;

@end