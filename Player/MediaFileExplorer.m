//
//  ViewController.m
//  Player
//
//  Created by kwk on 2016. 6. 13..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "MediaFileExplorer.h"

#import "URLList.h"
#import "URLListViewController.h"


@interface MediaFileExplorer ()

@property (nonatomic) URLList *urlList;
@property (nonatomic) URLListViewController *urlListViewController;

@property (nonatomic) IBOutlet NSTableView *tableView;

@property (nonatomic, readonly) NSArray *mediaFileType;

@property (nonatomic) NSString *currentDirectoryURL;
@property (nonatomic, readonly) NSMutableArray *fileNamesInCurrentDirectory;

@end

@implementation MediaFileExplorer


#pragma mark Init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView setDoubleAction:@selector(doubleClickEvent:)];
    
    _mediaFileType = @[@"mov", @"m4v", @"mp4"];
    [self setCurrentDirectoryURL:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]];    
}


#pragma mark Implementation setter and getter

- (void)setCurrentDirectoryURL:(NSString *)currentDirectoryURL {
    _currentDirectoryURL = currentDirectoryURL;
    [self setFileNamesInCurrentDirectory:(NSMutableArray*)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentDirectoryURL error:nil]];

    [self filterMediaFilesAndDirectories];
    [self orderByName];
    [self addParentDirectoryInCurrentDictory];
}

- (void)setFileNamesInCurrentDirectory:(NSMutableArray *)fileNamesInCurrentDirectory {
    _fileNamesInCurrentDirectory = fileNamesInCurrentDirectory;
    if(_fileNamesInCurrentDirectory == nil)
        _fileNamesInCurrentDirectory = [[NSMutableArray alloc]init];
}

- (void)addParentDirectoryInCurrentDictory {
    if([_currentDirectoryURL isEqualToString:@"/"])
        return;
    
    [_fileNamesInCurrentDirectory insertObject:@".." atIndex:0];
}


#pragma mark File Explorer Filtering/Sorting

- (NSString*)setURLOfFile:(NSString *)fileName {
    return [_currentDirectoryURL stringByAppendingPathComponent:fileName];
}

- (NSString*)fileType:(NSString*)fileName {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self setURLOfFile:fileName] error:NULL];
    return [attributes objectForKey:NSFileType];
}

- (void)filterMediaFilesAndDirectories {
    [_fileNamesInCurrentDirectory enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id object, NSUInteger index, BOOL *stop) {
        BOOL mediaFileType = NO;
        for (NSString* str in _mediaFileType) {
            if ([str caseInsensitiveCompare:[object pathExtension]] == NSOrderedSame) {
                mediaFileType = YES;
                break;
            }
        }
        if(([self fileType:object] != NSFileTypeDirectory) && mediaFileType == NO) {
            [_fileNamesInCurrentDirectory removeObject:object];
        }
        if([object isEqualToString:@"$RECYCLE.BIN"]) {
            [_fileNamesInCurrentDirectory removeObject:object];
        }
    }];
}

- (void)orderByName {
    NSMutableArray *directoryArray = [[NSMutableArray alloc]init];
    NSMutableArray *mediaFileArray = [[NSMutableArray alloc]init];
    
    for(id object in _fileNamesInCurrentDirectory) {        
        if([self fileType:object] == NSFileTypeDirectory) {
            [directoryArray addObject:object];
        } else {
            [mediaFileArray addObject:object];
        }
    }    
    NSArray *directorySorted = [directoryArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSArray *mediaFileSorted = [mediaFileArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [_fileNamesInCurrentDirectory removeAllObjects];
    
    for(id object in directorySorted) {
        [_fileNamesInCurrentDirectory addObject:object];
    }
    for(id object in mediaFileSorted) {
        [_fileNamesInCurrentDirectory addObject:object];
    }
}


#pragma mark File and Directory Setting

- (void)moveToParentDirectory {
    [self setCurrentDirectoryURL:[_currentDirectoryURL stringByDeletingLastPathComponent]];
}

- (void)moveToSubDirectory:(NSString*)directoryName {
    [self setCurrentDirectoryURL:[self setURLOfFile:directoryName]];
}

- (void)createURLListViewController:(NSString*)fileName {

    NSStoryboard *urlListViewControllerStoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    _urlListViewController = [urlListViewControllerStoryboard instantiateControllerWithIdentifier:@"urlListViewController"];
    [self presentViewControllerAsModalWindow:_urlListViewController];
    _urlList = [[URLList alloc]init];
    [_urlListViewController setUrlList:_urlList];
    
    int count = 0;
    for(id object in _fileNamesInCurrentDirectory) {
        
        if([self fileType:object] == NSFileTypeRegular) {
            NSString* aFilePathUsingURL = [NSString stringWithFormat:@"file://"];
            aFilePathUsingURL = [aFilePathUsingURL stringByAppendingString:[self setURLOfFile:object]];
            aFilePathUsingURL = [aFilePathUsingURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            NSURL* fileURL = [NSURL URLWithString:aFilePathUsingURL];
            
            [_urlList addURL:fileURL];
            
            if([object isEqualToString:fileName]) {
                NSLog(@"cursor : %d", count);
                [_urlList setCurrentCursor:count];
            }
            count++;
        }
    }
    
    //Temp Media File using Buffering Test
    NSURL *url = [NSURL URLWithString:@"http://eng-media-02.cdngc.net/cdnlab/cs1/mega/sample_studio.MP4"];
    [_urlList addURL:url];
    [_urlListViewController loadURLListInTableView];
}


#pragma mark tableView Controller

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_fileNamesInCurrentDirectory count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"type"]) {
        if([[_fileNamesInCurrentDirectory objectAtIndex:row] isEqualToString:@".."]) {
            return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
        } else if([self fileType:[_fileNamesInCurrentDirectory objectAtIndex:row]] == NSFileTypeDirectory) {
            return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
        } else {
            return [NSImage imageNamed:@"play.png"];
        }
    } else {
        return [_fileNamesInCurrentDirectory objectAtIndex:row];
    }
}


#pragma mark Mouse event

- (void)doubleClickEvent:(id)sender {
    if ([_tableView selectedRow] != -1) {
        if([[_fileNamesInCurrentDirectory objectAtIndex:[_tableView selectedRow]] isEqualToString:@".."]) {
            [self moveToParentDirectory];
            [_tableView reloadData];
        } else if([self fileType:[_fileNamesInCurrentDirectory objectAtIndex:[_tableView selectedRow]]] == NSFileTypeDirectory) {
            [self moveToSubDirectory:[_fileNamesInCurrentDirectory objectAtIndex:[_tableView selectedRow]]];
            [_tableView reloadData];
        } else if([self fileType:[_fileNamesInCurrentDirectory objectAtIndex:[_tableView selectedRow]]] == NSFileTypeRegular){
            [self createURLListViewController:[_fileNamesInCurrentDirectory objectAtIndex:[_tableView selectedRow]]];
        }
    } else {
        NSLog(@"Fail");
    }
    [self.view.window setTitle:_currentDirectoryURL];
}

@end
