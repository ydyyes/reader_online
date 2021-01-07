//
//  UIFont+LDY.m
//  LDYSelectivityAlertView
//
//  Created by 李东阳 on 2018/8/15.
//

#import "UIFont+LDY.h"

@implementation UIFont (LDY)

+(UIFont *)ldy_fontFor2xPixels:(NSUInteger) fontPixels{
    NSInteger fontSize=(fontPixels+2)/2;
    return [UIFont systemFontOfSize:fontSize];
}

+(UIFont *)ldy_boldFontFor2xPixels:(NSUInteger) fontPixels{
    NSInteger fontSize=(fontPixels+2)/2;
    return [UIFont boldSystemFontOfSize:fontSize];
}

@end
