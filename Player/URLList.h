//
//  listController.h
//  NewPlayer
//
//  Created by kwk on 2016. 6. 1..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLList : NSObject

#pragma mark List Controller

- (void)addURL:(NSURL*)URL;
- (void)insertURL:(NSURL*)URL atIndex:(NSUInteger)row;
- (void)removeURL:(NSUInteger)row;
- (NSURL*)getURL:(NSUInteger)row;
- (NSUInteger)countOfURLs;
- (BOOL)isEmpty;
- (void)clear;

#pragma mark URLs Location Controller Using (NSInteger)cursor

- (NSURL*)getURLFromCurrentCursor;
- (void)setCurrentCursor:(NSUInteger)cursor;
- (NSInteger)getRowFromCurrentCursor;
- (void)movingCursorToNextLocation;
- (void)movingCursorToPreviousLocation;
- (void)movingCursorToRandomLocation;

@end
