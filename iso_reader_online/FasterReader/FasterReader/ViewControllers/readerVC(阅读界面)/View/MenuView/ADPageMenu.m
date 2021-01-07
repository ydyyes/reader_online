//
//  ADPageMenu.m
//  reader
//
//  Created by beequick on 2017/9/19.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADPageMenu.h"
#import "Masonry.h"
#import "UIView+ZJP.h"
#import "MSYReaderSetting.h"

static CGFloat const animateDuration = 0.3;

@interface ADPageMenu ()
@property (weak, nonatomic) IBOutlet UIView *backGrountTapView;
@property (weak, nonatomic) IBOutlet UIView *topMenuView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMenuViewToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMenuViewHeight;

@property (nonatomic, copy) showComplete showBlock;
@property (nonatomic, copy) dismissComplete dismissBlock;

@end

@implementation ADPageMenu

static inline CGFloat bottomviewHeight(){
    return (120+(ADTabBarHeight_Add));
}
static inline CGFloat fontMenuHeight(){
    return (242+(ADTabBarHeight_Add));
}
static inline CGFloat lightViewHeight(){
    return ADTabBarHeight+30;
}

+ (instancetype )pageMenu{
    return [[[NSBundle mainBundle] loadNibNamed:@"ADPageMenu" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self configUI];
}
- (void)configUI{

    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *banckViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.backGrountTapView addGestureRecognizer:banckViewGesture];

    NSLog(@"bottomviewHeight:%f",bottomviewHeight());
    
    self.bottomMenu = [ADBottomMenu bottomMenuView];
    [self addSubview: self.bottomMenu];
    //初始位置
    self.topMenuViewToTop.constant = -ADNavBarHeight;
    self.topMenuViewHeight.constant = ADNavBarHeight;
    //底部menus初始位置
    [self.bottomMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self);
        make.height.mas_equalTo(bottomviewHeight());
        make.bottom.equalTo(self).offset(bottomviewHeight());
    }];
    
    
    /// 为什么不判断白天模式?因为xib默认显示的就是dayMode
    if (![MSYReaderSetting shareInstance].setting.dayModel) {
        self.topMenuView.backgroundColor = [UIColor colorWithHexString: ADMenuSettingNightThem];
        self.titleLable.textColor = [UIColor whiteColor];
//        [self.lastChapterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)showMenuInView:(UIView *)superView{
    [superView addSubview: self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(superView);
    }];
    [self.superview layoutIfNeeded];
    [self show];
}

- (void)showMenuInView:(UIView *)superView show:(showComplete)showBlock dismiss:(dismissComplete)dismissBlock{
    [self showMenuInView: superView];
    self.showBlock = showBlock;
    self.dismissBlock = dismissBlock;
}

#pragma mark - show
- (void)show{
    [self dismissSecondView];
    [UIView animateWithDuration: animateDuration animations:^{
        self.topMenuViewToTop.constant = 0;
        [self.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(0);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showBlock();
    }];
}

- (void)dismiss{
    [self dismissWithAnimate:YES];
}

- (void)dismissWithAnimate:(BOOL)animate{
    self.dismissBlock();
    if (_settingMenuView) {
        [_settingMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(fontMenuHeight());
        }];
    }
    if (_lightView) {
        [_lightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(lightViewHeight());
        }];
    }
    
    [UIView animateWithDuration: animate ? animateDuration : 0 animations:^{
        self.topMenuViewToTop.constant = -ADNavBarHeight;
        [self.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(bottomviewHeight());
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self dismissSecondView];
    }];
}

- (void)dismissSecondView{
    if (_settingMenuView) {
        [_settingMenuView removeFromSuperview];
        _settingMenuView = nil;
    }
    if (_lightView) {
        [_lightView removeFromSuperview];
        _lightView = nil;
    }
}

- (IBAction)backAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(goBack)]) {
        [self.delegate goBack];
    }
}

-(void)setChapterTitle:(NSString *)title {
    self.titleLable.text = title;
}

#pragma mark - secondMenu
- (void)showSettingMenuView{
    [self.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(bottomviewHeight());
    }];
    [self.settingMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(0);
    }];
    [self layoutIfNeeded];
}
- (void)showLightView{
    [self.bottomMenu mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(bottomviewHeight());
    }];
    [self.lightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(0);
    }];
    [self layoutIfNeeded];
}


#pragma mark - setter && getter


-(ADMenuSettingView *)settingMenuView {
    if (!_settingMenuView) {
        _settingMenuView = [ADMenuSettingView menuSettingView];
        [self addSubview: _settingMenuView];
        [_settingMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.height.mas_equalTo(fontMenuHeight());
            make.bottom.equalTo(self).offset(fontMenuHeight());
        }];
    }
    return _settingMenuView;
}
- (ADMenuLightView *)lightView{
    if (!_lightView) {
        _lightView = [ADMenuLightView lightView];
        [self addSubview:_lightView];
        [_lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.height.mas_equalTo(lightViewHeight());
            make.bottom.equalTo(self).offset(lightViewHeight());
        }];
    }
    return _lightView;
}

@end
