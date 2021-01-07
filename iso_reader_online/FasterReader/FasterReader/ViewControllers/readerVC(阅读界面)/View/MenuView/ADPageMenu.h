//
//  ADPageMenu.h
//  reader
//
//  Created by beequick on 2017/9/19.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBottomMenu.h"
#import "ADMenuSettingView.h"

#import "ADMenuLightView.h"

typedef void(^showComplete)(void);
typedef void(^dismissComplete)(void);


@protocol ADPageMenuDelegate <NSObject>

- (void)goBack;

@end

@interface ADPageMenu : UIView

+ (instancetype)pageMenu;

@property (copy, nonatomic) void(^BottomTapAction)(NSInteger);
@property (nonatomic, strong) ADBottomMenu *bottomMenu;
@property (nonatomic, strong) ADMenuSettingView *settingMenuView;
@property (nonatomic, strong) ADMenuLightView *lightView;
@property (nonatomic,weak) id<ADPageMenuDelegate>delegate;

- (void)showMenuInView:(UIView *)superView;
- (void)showMenuInView:(UIView *)superView show:(showComplete)showBlock dismiss:(dismissComplete)dismissBlock;
- (void)dismissWithAnimate:(BOOL)animate;

- (void)dismiss;
- (void)showSettingMenuView;
- (void)showLightView;

- (void)setChapterTitle:(NSString *)title;

@end
