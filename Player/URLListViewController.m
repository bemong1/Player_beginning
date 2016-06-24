//
//  PlayerListController.m
//  NewPlayer
//
//  Created by kwk on 2016. 5. 31..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "URLListViewController.h"

#import "AppDelegate.h"
#import "VideoPlayerViewController.h"


@interface URLListViewController ()

@property (nonatomic) IBOutlet NSTableView *tableView;

@property (nonatomic) VideoPlayerViewController *videoPlayerViewController;

@end

@implementation URLListViewController

static void *URLListContext = &URLListContext;


#pragma mark Init and Dealloc

- (void)viewDidLoad {
    [_tableView setTarget:self];
    [_tableView setDoubleAction:@selector(doubleClickEvent:)];    
    
    [_urlList addObserver:self forKeyPath:@"cursor" options:0 context:URLListContext];
}

- (void)dealloc {
    [_urlList removeObserver:self forKeyPath:@"cursor" context:URLListContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == URLListContext) {
        if([keyPath isEqualToString:@"cursor"]) {
            [self loadURLListInTableView];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark TableView Controller

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_urlList countOfURLs];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"name"]) {
        return [[_urlList getURL:row] lastPathComponent];
    } else if ([tableColumn.identifier isEqualToString:@"number"]) {
        return [NSString stringWithFormat:@"%ld", row + 1];
    } else {
        NSNumber *fileSizeNumber;
        [[_urlList getURL:row] getResourceValue:&fileSizeNumber forKey:NSURLFileSizeKey error:nil];
        long long fileSize = [fileSizeNumber longLongValue];
        NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
        return [NSString stringWithFormat:@"%@", displayFileSize];
    }
}

- (void)loadURLListInTableView {
    [_tableView reloadData];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_urlList getRowFromCurrentCursor]] byExtendingSelection:NO];
}


#pragma mark URLList Controller

- (void)loadMediaFile:(NSURL*)url {
    
    NSStoryboard *videoPlayerViewControllerStoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    _videoPlayerViewController = [videoPlayerViewControllerStoryboard instantiateControllerWithIdentifier:@"videoPlayerViewController"];
    [_videoPlayerViewController setDelegate:(id)self];
    [self presentViewControllerAsModalWindow:_videoPlayerViewController];
    
    [_videoPlayerViewController loadMediaFile:url];
}

- (void)removePlayerViewController {
    
    _videoPlayerViewController = nil;
}


#pragma mark Mouse event

- (void)doubleClickEvent:(id)sender {
    if([_tableView selectedRow] != -1) {
        [_urlList setCurrentCursor:[_tableView selectedRow]];
        
        [self loadMediaFile:[_urlList getURLFromCurrentCursor]];
    }
}

@end


