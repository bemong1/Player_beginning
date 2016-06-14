//
//  ViewController.m
//  Player
//
//  Created by kwk on 2016. 6. 13..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) IBOutlet NSTableView *tableView;

@property (nonatomic) NSArray *mediaFileType;

@property (nonatomic) NSMutableArray *currentDirectoryFileArray;
@property (nonatomic) NSString *currentDirectoryPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tableView setDoubleAction:@selector(doubleClickEvent:)];
    
    _mediaFileType = @[@"mov", @"m4v", @"mp4"];
    
    _currentDirectoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [self setCurrentDirectoryPath:_currentDirectoryPath];
}

- (void)setCurrentDirectoryPath:(NSString *)currentDirectoryPath {
    _currentDirectoryPath = currentDirectoryPath;
    _currentDirectoryFileArray = (NSMutableArray*)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentDirectoryPath error:nil];

    [self filterMediaFilesAndDirectories];
    
    [self orderByName];
    [self addParentDirectory];
    
}

- (void)filterMediaFilesAndDirectories {
    [_currentDirectoryFileArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id object, NSUInteger index, BOOL *stop) {
        NSString* tempPath = [_currentDirectoryPath stringByAppendingPathComponent:object];
        
        if(([self fileType:tempPath] != NSFileTypeDirectory) && (![_mediaFileType containsObject:[object pathExtension]])) {
            NSLog(@"%@", object);
            [_currentDirectoryFileArray removeObject:object];
        }
    }];
}

- (void)orderByName {
    NSMutableArray *directoryArray = [[NSMutableArray alloc]init];
    NSMutableArray *mediaFileArray = [[NSMutableArray alloc]init];
    
    for(id object in _currentDirectoryFileArray) {
        NSString* tempPath = [_currentDirectoryPath stringByAppendingPathComponent:object];
        if([self fileType:tempPath] == NSFileTypeDirectory) {
            [directoryArray addObject:object];
        } else {
            [mediaFileArray addObject:object];
        }
    }
    
    NSMutableArray *directorySorted = (NSMutableArray*)[directoryArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *mediaFileSorted = (NSMutableArray*)[mediaFileArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [_currentDirectoryFileArray removeAllObjects];
    
    for(id object in directorySorted) {
        [_currentDirectoryFileArray addObject:object];
    }
    for(id object in mediaFileSorted) {
        [_currentDirectoryFileArray addObject:object];
    }
}

- (void)addParentDirectory {
    if([_currentDirectoryPath isEqualToString:@"/"])
        return;
    
    [_currentDirectoryFileArray insertObject:@".." atIndex:0];
}

- (NSString*)fileType:(NSString*)filePath {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    return [attributes objectForKey:NSFileType];
}

- (void)changeCurrentDirectoryToParentDirectory {
    [self setCurrentDirectoryPath:[_currentDirectoryPath stringByDeletingLastPathComponent]];
}

- (void)changeCurrentDirectoryToSubDirectory:(NSString*)pathComponent {
    NSString *selectedPath = [_currentDirectoryPath stringByAppendingPathComponent:pathComponent];
    [self setCurrentDirectoryPath:selectedPath];
}

- (void)test {
    
}


#pragma mark TableView Controller

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_currentDirectoryFileArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"icon"]) {
        NSString *tempPath = [_currentDirectoryPath stringByAppendingPathComponent:[_currentDirectoryFileArray objectAtIndex:row]];
        return [self fileType:tempPath];
    } else {
        return [_currentDirectoryFileArray objectAtIndex:row];
    }
}

#pragma mark Mouse event

- (void)doubleClickEvent:(id)sender {
    if([_tableView selectedRow] == 0) {
        [self changeCurrentDirectoryToParentDirectory];
        [_tableView reloadData];
    } else if ([_tableView selectedRow] != -1) {
        NSString *selectedPath = [_currentDirectoryPath stringByAppendingPathComponent:[_currentDirectoryFileArray objectAtIndex:[_tableView selectedRow]]];
        
        if([self fileType:selectedPath] == NSFileTypeDirectory) {
            [self setCurrentDirectoryPath:selectedPath];
            [_tableView reloadData];
        }
    }
}

@end
