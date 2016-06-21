//
//  RepeatIntervalController.h
//  Player
//
//  Created by kwk on 2016. 6. 21..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepeatIntervalController : NSObject

- (id)initWithDurationTime:(float)durationTime;

@property (nonatomic, readonly) float durationTime;

@property (nonatomic) float startTime;
@property (nonatomic) float endTime;
@property (nonatomic, readonly) BOOL isStartTime;
@property (nonatomic, readonly) BOOL isEndTime;
@property (nonatomic, readonly) BOOL stateRepeatInterval;

- (float)executeRepeatInterval:(float)currentTime;

@end
