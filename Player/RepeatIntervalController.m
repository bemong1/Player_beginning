//
//  RepeatIntervalController.m
//  Player
//
//  Created by kwk on 2016. 6. 21..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "RepeatIntervalController.h"


@implementation RepeatIntervalController

- (id)initWithDurationTime:(float)durationTime {
    self = [super init];
    if(self != nil) {
        _durationTime = durationTime;
        _endTime = _durationTime;
    }
    return self;
}

- (void)setStartTime:(float)startTime {
    if(_isStartTime == NO) {
        if(startTime != 0.0f) {
            _isStartTime = YES;
        } else {
            _isStartTime = NO;
        }
        _startTime = startTime;
    } else {
        _startTime = 0.0f;
        _isStartTime = NO;
    }
}

- (void)setEndTime:(float)endTime {
    if(_isEndTime == NO) {
        if(endTime != _durationTime) {
            _isEndTime = YES;
        } else {
            _isEndTime = NO;
        }
        _endTime = endTime;
    } else {
        _endTime = _durationTime;
        _isEndTime = NO;
    }
}

- (BOOL)stateRepeatInterval {
    if(_isStartTime || _isEndTime) {
        return YES;
    } else {
        return NO;
    }
}

- (float)executeRepeatInterval:(float)currentTime {
    if(_startTime - 0.01f > currentTime || _endTime < currentTime) {
        return _startTime;
    }
    NSLog(@"start:%f, current:%f, end:%f", _startTime, currentTime, _endTime);
    return currentTime;
}

@end
