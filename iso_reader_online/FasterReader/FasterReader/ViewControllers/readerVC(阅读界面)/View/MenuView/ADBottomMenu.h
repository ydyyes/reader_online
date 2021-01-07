//
//  ADMenuBottom.h
//  reader
//
//  Created by beequick on 2017/9/19.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChapterActionType) {
    ChapterActionTypePre,
    ChapterActionTypeNext
};
typedef NS_ENUM(NSUInteger,TapActionType) {
    TapActionTypeChapters,
    TapActionTypeSetting,
    TapActionTypeDayOrNight
};
@protocol ADBottomMenuDelegate <NSObject>

- (void)bottomMenuViewChapterChanged:(ChapterActionType)actionType;
- (void)bottomMenuViewSliderChanged:(NSUInteger)value;
- (void)bottomMenuViewActionButtonClicked:(TapActionType)actionType;

@end
@interface ADBottomMenu : UIView

+ (instancetype)bottomMenuView;

@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastChapterLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextChapterTrailing;

/** 默认的为2 */
@property (nonatomic, assign) NSUInteger maxValue;
/** 默认的为1 */
@property (nonatomic, assign) NSUInteger minValue;
/** 默认的为1 */
@property (nonatomic, assign) NSUInteger currentValue;

@property (nonatomic, weak) id<ADBottomMenuDelegate> bottomDelegate;



@end
