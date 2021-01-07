//
//  ADMenuFontView.m
//  reader
//
//  Created by beequick on 2017/9/21.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADMenuSettingView.h"
#import "MSYReaderSetting.h"
#import "Masonry.h"
#import "UIView+ZJP.h"
#import "ADPageMenu.h"


@interface ADMenuSettingView()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *fontSizeView;
@property (weak, nonatomic) IBOutlet UIView *fontTTFView;
@property (weak, nonatomic) IBOutlet UIView *linespaceView;
@property (weak, nonatomic) IBOutlet UIView *themeVIew;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secButtonConstraint;
@property (strong, nonatomic) IBOutlet UIButton *unsimplifiedBtn;

@end
@implementation ADMenuSettingView

+ (instancetype)menuSettingView{
    return [[[NSBundle mainBundle] loadNibNamed:@"ADMenuSettingView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib{
    [super awakeFromNib];

    [self configUI];
}
#pragma mark - method

- (IBAction)setFontSmaller:(id)sender {
    if ([MSYReaderSetting shareInstance].setting.fontSize >= 15) {
        [MSYReaderSetting shareInstance].setting.fontSize--;
    }
}

- (IBAction)setFontBiger:(id)sender {
	if ([MSYReaderSetting shareInstance].setting.fontSize <= 25) {
		[MSYReaderSetting shareInstance].setting.fontSize++;
	}
}

- (IBAction)lineSpaceFirst:(id)sender {
    [MSYReaderSetting shareInstance].setting.lineSpace = 6;
}
- (IBAction)lineSpaceSecond:(id)sender {
    [MSYReaderSetting shareInstance].setting.lineSpace = 12;
}
- (IBAction)lineSpaceThird:(id)sender {
    [MSYReaderSetting shareInstance].setting.lineSpace = 20;
}
- (IBAction)lineSpaceNone:(id)sender {
    [MSYReaderSetting shareInstance].setting.lineSpace = 10;
}

/** 繁体  */
- (IBAction)unsimplifiedAction:(id)sender {
    [MSYReaderSetting shareInstance].setting.unsimplified = YES;
}
/** 简体 */
- (IBAction)simplifiedAction:(id)sender {
    [MSYReaderSetting shareInstance].setting.unsimplified = NO;
}
- (IBAction)colorSelectFirst:(id)sender {
    [MSYReaderSetting shareInstance].setting.backGroundColor = ADMenuSettingFirstThem;
}
- (IBAction)colorSelectSecond:(id)sender {
    [MSYReaderSetting shareInstance].setting.backGroundColor = ADMenuSettingNightThem;
}

- (IBAction)colorSelectThird:(id)sender {
    [MSYReaderSetting shareInstance].setting.backGroundColor = ADMenuSettingThirdThem;
}

- (IBAction)colorSelectLast:(id)sender {
    
    [MSYReaderSetting shareInstance].setting.backGroundColor = ADMenuSettingFourthThem;
}


#pragma mark - setter && getter
- (void)configUI{
    CGFloat rate = [JPTool screenWidth]/675.0;
    self.buttonConstraint.constant = rate*20;
    self.secButtonConstraint.constant = rate*20;
//    self.backView.backgroundColor = [UIColor blackColor];
//    self.backView.alpha = [ADReaderSetting shareInstance].setting.alphaValue;
	if ([MSYReaderSetting shareInstance].setting.unsimplified) {
		[self.unsimplifiedBtn setTitle:@"简体" forState:UIControlStateNormal];
	}else{
		[self.unsimplifiedBtn setTitle:@"繁体" forState:UIControlStateNormal];
	}
    
    /// 为什么不判断白天模式?因为xib默认显示的就是dayMode
    if (![MSYReaderSetting shareInstance].setting.dayModel) {

        self.contentView.backgroundColor = [UIColor colorWithHexString: ADMenuSettingNightThem];
     
        [self setNightColorForUI: self.fontSizeView];
        [self setNightColorForUI: self.fontTTFView];
        [self setNightColorForUI: self.linespaceView];
        [self setNightColorForUI: self.themeVIew];

    }
}

-(void)setNightColorForUI:(UIView *)superView {
    
    UIColor *nightColor = [UIColor whiteColor];
    for (UIView *view in superView.subviews) {
        if ( [view isKindOfClass: [UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = nightColor;
        }else if ( [view isKindOfClass: [UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor: nightColor forState: UIControlStateNormal];
        }
    }
}
//- (void)configFontSizeView{
//    [self initialLable:@"字号" superView:self.fontSizeView];
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"小" forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont systemFontOfSize:15];
//    [self.fontSizeView addSubview:button];
//    button.layer.cornerRadius = singleViewHieght*0.5;
//    button.layer.borderWidth = 1;
//    button.layer.borderColor = [UIColor colorWithHexString:@"#808080"].CGColor;
//    button.layer.masksToBounds = YES;
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(self.fontSizeView);
//        make.right.equalTo(self.fontSizeView).offset(-15);
//        make.width.mas_equalTo(100);
//    }];
//
//}
//- (void)configfFontTTFView{}
//- (void)configlLinespaceView{}
//- (void)configThemeVIew{}

//- (void)initialLable:(NSString *)text superView:(UIView *)superView{
//    UILabel *lable = [[UILabel alloc] init];
//    lable.text = text;
//    lable.font = [UIFont systemFontOfSize:14];
//    lable.textColor = [UIColor whiteColor];
//    [superView addSubview:lable];
//    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(superView);
//        make.left.equalTo(superView).offset(15);
//    }];
//}

@end
