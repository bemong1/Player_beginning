//
//  PlayerListController.h
//  NewPlayer
//
//  Created by kwk on 2016. 5. 31..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "URLList.h"


@interface URLListViewController : NSViewController <NSWindowDelegate>

@property (nonatomic) URLList *urlList;


#pragma mark URLList Controller

- (void)loadURLListInTableView;
- (void)loadMediaFile:(NSURL*)url;

@end
