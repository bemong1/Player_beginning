//
//  listController.m
//  NewPlayer
//
//  Created by kwk on 2016. 6. 1..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "URLList.h"

#import "URLListViewController.h"

@interface URLList()

@property (nonatomic) NSMutableArray *list;
@property (nonatomic) NSUInteger cursor;

@end

@implementation URLList

#pragma mark Singleton instance

+ (URLList*)sharedURLList {
    static dispatch_once_t pred;
    static URLList *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[URLList alloc]init];
    });
    return shared;
}


#pragma mark Init

- (id)init {
    self = [super init];
    if(self != nil) {
        _list = [[NSMutableArray alloc]init];
        _cursor = 0;
    }
    return self;
}


#pragma mark List Controller

- (void)addURL:(NSURL*)URL {
    if (URL != nil) {
        for(NSURL* tempURL in _list) {
            if([[tempURL absoluteString] isEqualToString:[URL absoluteString]]) {
                return;
            }
        }
        [_list addObject:URL];
    }
}

- (void)insertURL:(NSURL*)URL atIndex:(NSUInteger)row {
    if (URL != nil) {
        for(NSURL* tempURL in _list) {
            if([[tempURL absoluteString] isEqualToString:[URL absoluteString]]) {
                return;
            }
        }
        [_list insertObject:URL atIndex:row];
    }
}

- (void)removeURL:(NSUInteger)row {
    [_list removeObjectAtIndex:row];
}

- (NSURL*)getURL:(NSUInteger)row {
    return [_list objectAtIndex:row];
}

- (NSUInteger)countOfURLs {
    return [_list count];
}

- (BOOL)isEmpty {
    return [_list count] == 0;
}

- (void)clear {
    [_list removeAllObjects];
}


#pragma mark URLs Location Controller Using (NSInteger)cursor

- (void)setCurrentCursor:(NSUInteger)cursor {
    if(_cursor < [_list count]) {
        [self setCursor:cursor];        
    }
}

- (NSInteger)getRowFromCurrentCursor {
    return _cursor;
}

- (NSURL*)getURLFromCurrentCursor {
    if ([_list count] > 0) {
        return [_list objectAtIndex:_cursor];
    }
    return nil;
}

- (void)movingCursorToNextLocation {
    if(_cursor < [self countOfURLs] - 1) {
        [self setCursor:_cursor + 1];
    } else {
        [self setCursor:0];
    }
}

- (void)movingCursorToPreviousLocation {
    if(_cursor > 0) {
        [self setCursor:_cursor - 1];
    } else {
        [self setCursor:[self countOfURLs] - 1];
    }
}

- (void)movingCursorToRandomLocation {
    NSUInteger randomValue = arc4random() % [self countOfURLs];
    [self setCursor:randomValue];
}

@end
