//
//  UIColor+Hex.m
//  lian
//
//  Created by Fire on 15-9-7.
//  Copyright (c) 2015年 DuoLaiDian. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)mainBlue_2F94F9 {
	return [self colorWithHexString:@"2F94F9"];
}

+ (UIColor *)buttonNor {
	return [self colorWithHexString:@"2F94F9"];
}

+ (UIColor *)buttonHigh {
	return [self colorWithHexString:@"85b8fb"];
}

+ (UIColor *)lightGray_F2F2F2 {
	return [self colorWithHexString:@"F2F2F2"];
}

+ (UIColor *)lightGray_F0F0F0 {
	return [self colorWithHexString:@"F0F0F0"];
}

+ (UIColor *)lightGary_999999 {
	return [self colorWithHexString:@"999999"];
}

+ (UIColor *)black_222222 {
	return [self colorWithHexString:@"222222"];
}

+ (UIColor *)black_333333 {
	return [self colorWithHexString:@"333333"];
}



+ (UIColor *)lightGray_666666 {
	return [self colorWithHexString:@"666666"];
}

+ (UIColor *)lightGray_cccccc {
	return [self colorWithHexString:@"cccccc"];
}

+ (UIColor *)lightGrayLineColor_dddddd {
	return [self colorWithHexString:@"dddddd"];
}

+ (UIColor *)lightGray_e5e5e5 {
	return [self colorWithHexString:@"e5e5e5"];
}

+ (UIColor *)lightGray_b2b2b2 {
	return [self colorWithHexString:@"b2b2b2"];
}

+ (UIColor *)blue_00a2e0 {
	return [self colorWithHexString:@"00a2e0"];
}

+ (UIColor *)lightGray_d5d8dc {
	return [self colorWithHexString:@"d5d8dc"];
}

+ (UIColor *)lightGray_a8a8a8 {
	return [self colorWithHexString:@"a8a8a8"];
}

+ (UIColor *)red_ff4141 {
	return [self colorWithHexString:@"ff4141"];
}

+ (UIColor *)lightGray_eeeeee {
	return [self colorWithHexString:@"eeeeee"];
}


+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}

@end
