//
//  CALayer+ModifyProperty.m
//  Player
//
//  Created by kwk on 2016. 5. 20..
//  Copyright © 2016년 kwk.self. All rights reserved.
//

#import "CALayer+AddMethod.h"

@implementation CALayer (AddMethod)

-(void)backgroundColorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    CGColorRef color = CGColorCreateGenericRGB(red, green, blue, alpha);
    [self setBackgroundColor:color];
    CGColorRelease(color);
}

@end
