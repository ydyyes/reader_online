//
//  UIColor+LDY.m
//  LDYSelectivityAlertView
//
//  Created by 李东阳 on 2018/8/15.
//

#import "UIColor+LDY.h"

@implementation UIColor (LDY)

+(UIColor *)ldyBase_colorWithHexadecimal:(NSUInteger) hexColorValue{
    CGFloat red = ((float)((hexColorValue & 0xFF0000) >> 16));
    CGFloat green = ((float)((hexColorValue & 0xFF00) >> 8));
    CGFloat blue = ((float)(hexColorValue & 0xFF));
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:1];
}

@end
