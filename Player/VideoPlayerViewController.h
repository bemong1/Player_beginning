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

@protocol URLListViewControllerDelegate <NSObject>

- (void)removePlayerViewController;

@end

@interface VideoPlayerViewController : NSViewController <URLListViewControllerDelegate>

@property (nonatomic, weak) id <URLListViewControllerDelegate> delegate;

- (void)loadMediaFile:(NSURL*)url;

@end
