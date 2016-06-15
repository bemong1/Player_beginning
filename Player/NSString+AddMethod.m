//
//  NSString+Date.m
//  FifthPlayer
//
//  Created by kwk on 2016. 5. 11..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "NSString+AddMethod.h"

@implementation NSString (AddMethod)

+ (NSString*)changeTimeFloatToNSString:(float)tempTime {
    float tempHours =   floor((NSInteger)tempTime / 3600);
    float tempMinutes = floor((NSInteger)tempTime % 3600 / 60);
    float tempSeconds = floor((NSInteger)tempTime % 3600 % 60);
    
    return [NSString stringWithFormat:@"%02.f:%02.f:%02.f", tempHours, tempMinutes, tempSeconds];
}

@end
