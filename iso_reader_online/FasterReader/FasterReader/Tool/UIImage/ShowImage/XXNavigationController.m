//
//  XXNavigationController.m
//  XXNavigationController
//
//  Created by Tracy on 14-3-5.
//  Copyright (c) 2014年 Mark. All rights reserved.
//

#import "XXNavigationController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
//#define [JPTool screenHeight] [UIScreen mainScreen].bounds.size.height
//#define [JPTool screenWidth] [UIScreen mainScreen].bounds.size.width



@interface XXNavigationController ()<UIGestureRecognizerDelegate> {
    CGPoint startPoint;

    UIImageView *lastScreenShotView;// view
}

@property (nonatomic, strong) UIView *backGroundView;

@property (nonatomic, strong) NSMutableArray *screenShotList;

@property (nonatomic, assign) BOOL isMoving;

@end

//static CGFloat offset_float = 0.65;// 拉伸参数
//static CGFloat min_distance = 100;// 最小回弹距离

@implementation XXNavigationController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
