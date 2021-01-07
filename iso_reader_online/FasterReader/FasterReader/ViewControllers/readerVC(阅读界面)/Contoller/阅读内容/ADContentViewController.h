//
//  ADContentViewController.h
//  NightReader
//
//  Created by apple on 2019/6/25.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ADChapterContentModel.h"

@class ADContentViewController;
@protocol ADContentViewControllerDelegate <NSObject>

- (void)readContentControllerShouldMenuView:(ADContentViewController *)controller;

@end

/** 阅读页面 */
@interface ADContentViewController : UIViewController

@property (nonatomic, weak) id<ADContentViewControllerDelegate> delegate;

/// 当前页码
@property (nonatomic, assign) NSUInteger pageIndex;
/// 当前章节
@property (nonatomic, assign) NSUInteger chapterIndex;
/// 当前model
@property (nonatomic, strong) ADChapterContentModel *model;

/// 当是每章的最后一页事,是否有足够的空间展示广告,默认为No
@property (nonatomic, assign, getter=isHaveEnoughSpaceToShowAd) BOOL haveEnoughSpaceToShowAd;

- (void)reloadData;

@end
