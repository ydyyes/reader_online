//
//  UIImage+ColorImage.h
//  publicwine
//
//  Created by 胡智斌 on 14-1-20.
//  Copyright (c) 2014年 何伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorImage)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end
