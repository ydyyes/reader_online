//
//  ADMenuBottom.m
//  reader
//
//  Created by beequick on 2017/9/19.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADBottomMenu.h"
#import "MSYReaderSetting.h"

static NSInteger const baseTag = 309;


@interface ADBottomMenu()
@property (weak, nonatomic) IBOutlet UIButton *preChapterButton;
@property (weak, nonatomic) IBOutlet UIButton *lastChapterButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ADBottomMenu

+ (instancetype)bottomMenuView{
    return [[[NSBundle mainBundle] loadNibNamed:@"ADBottomMenu" owner:nil options:nil]lastObject];
}


- (void)awakeFromNib{
    [super awakeFromNib];

//    CGFloat width = 12.0;
//    UIImage *thumbImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#2F94F9"] size: CGSizeMake(width, width)];
//    thumbImage = [thumbImage imageByRoundCornerRadius:width * 0.5];
    
    UIImage *thumbImage= [UIImage imageNamed:@"yuan"];
    [self.sliderView setThumbImage:thumbImage forState:UIControlStateNormal];
    self.sliderView.continuous = NO;
    [self.sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents: UIControlEventValueChanged];
    
    
    NSString *dayOrNight = @"ye_icon";
    if (![MSYReaderSetting shareInstance].setting.dayModel) {
        dayOrNight = @"taiyang_icon";
    }
    
    NSArray *images = @[@"mulu_icon",
                        @"book_shezhi_icon",
                        dayOrNight];
    
    NSUInteger buttonNum = images.count;
    CGFloat buttonWidth = [JPTool screenWidth] / buttonNum;
    CGFloat buttonHeight = 50;
    CGFloat iconWidth = 25;
    CGFloat leading = (buttonWidth - iconWidth) * 0.5;
    self.lastChapterLeading.constant = leading;
    self.nextChapterTrailing.constant = leading;

    for (int i = 0; i<buttonNum; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        button.frame = CGRectMake(buttonWidth * i, -10, buttonWidth, buttonHeight);
        button.tag = baseTag + i;
        [button addTarget:self action:@selector(menuBottonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:button];
    }
    self.minValue = 1;
    self.maxValue = 2;
    self.currentValue = 1;
    
    /// 为什么不判断白天模式?因为xib默认显示的就是dayMode
    if (![MSYReaderSetting shareInstance].setting.dayModel) {
        self.contentView.backgroundColor = [UIColor colorWithHexString: ADMenuSettingNightThem];
        [self.preChapterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.lastChapterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)menuBottonOnClick:(UIButton *)button{
    if ([self.bottomDelegate respondsToSelector:@selector(bottomMenuViewActionButtonClicked:)]) {
        NSInteger tag = button.tag -  baseTag;
        TapActionType type = TapActionTypeChapters;
        switch (tag) {
            case 0:
            {
                type = TapActionTypeChapters;
                [self.bottomDelegate bottomMenuViewActionButtonClicked:type];
            }
                break;
            case 1:
            {
                type = TapActionTypeSetting;
                [self.bottomDelegate bottomMenuViewActionButtonClicked:type];
            }
                break;
            case 2:
            {
                type = TapActionTypeDayOrNight;
                [MSYReaderSetting shareInstance].setting.dayModel = ![MSYReaderSetting shareInstance].setting.dayModel;
                [self.bottomDelegate bottomMenuViewActionButtonClicked:type];
            }
                break;
            default:
                break;
        }
    }
}

- (IBAction)preChapterOnCLick:(id)sender {
    if ([self.bottomDelegate respondsToSelector:@selector(bottomMenuViewChapterChanged:)]) {
        [self.bottomDelegate bottomMenuViewChapterChanged:ChapterActionTypePre];
    }
    
}
- (IBAction)nextChapterOnCLick:(id)sender {
    if ([self.bottomDelegate respondsToSelector:@selector(bottomMenuViewChapterChanged:)]) {
        [self.bottomDelegate bottomMenuViewChapterChanged:ChapterActionTypeNext];
    }
}

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    NSLog(@"slider = %@, slider.value = %f,int = %d",slider,slider.value, (int)slider.value);
    if ([self.bottomDelegate respondsToSelector:@selector(bottomMenuViewSliderChanged:)]) {
        [self.bottomDelegate bottomMenuViewSliderChanged:(NSUInteger)slider.value];
    }
}

#pragma mark - setter && getter

- (void)setMaxValue:(NSUInteger)maxValue{
    _maxValue = maxValue;
    [self.sliderView setMaximumValue:(float)maxValue];
}

- (void)setCurrentValue:(NSUInteger)currentValue {
    _currentValue = currentValue;
    [self.sliderView setValue:(float)currentValue];
}

@end
