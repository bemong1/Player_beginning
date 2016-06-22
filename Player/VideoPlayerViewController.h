//
//  PlayerViewController.h
//  Player-0610
//
//  Created by kwk on 2016. 6. 10..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlayerController.h"
#import "MediaFileExplorer.h"
#import "VideoPlayerController.h"

@protocol MediaFileExplorerDelegate <NSObject>

- (void)removePlayerViewController;

@end

@interface VideoPlayerViewController : NSViewController <MediaFileExplorerDelegate>

@property (nonatomic, weak) id <MediaFileExplorerDelegate> delegate;

@property (nonatomic) VideoPlayerController *videoPlayerController;

- (void)loadMediaFile:(NSURL*)url;
- (void)stopMediaFile;

@end
