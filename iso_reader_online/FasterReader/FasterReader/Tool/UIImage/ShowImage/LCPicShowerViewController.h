//
// 原图显示页面,首页缩略图点击/微博正文图片点击均进入此页面
//  LCPicShowerViewController.h
//  LanChaoClient
//
//  Created by xydd12345 on 11-12-3.
//  Copyright (c) 2011年 PICA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESStatus;
@class LKImageView;

@interface LCPicShowerViewController : UIViewController{
    
	IBOutlet UIScrollView *photoScrollView;
    //IBOutlet UIToolbar *funToolbar;
	BOOL isBarsHidden;
	LKImageView *imageView;
	IBOutlet UIImageView* bigImageView;
    NSInteger       type;
    BOOL        removeImage;
	BOOL		isViewAppeared;
    BOOL            isSave;
}

@property (nonatomic, retain) LKImageView *imageView;
@property (nonatomic, assign) ESStatus *theStatus;
@property (nonatomic, assign) BOOL removeImage;
@property (nonatomic, retain) NSString* imageUrl;
@property (nonatomic) int tag; //判断是否从品酒卡点进
	
- (void)cancel: (id)sender;
- (void)remove: (id)sender;

- (id)initWithAStatus:(NSString *)imageUrl;
- (id)initWithImage:(UIImage*)anImage;

/** 是否隐藏删除按钮 YES 隐藏 NO 不隐藏 */
@property (nonatomic,assign) BOOL isHiddenDeleteBtn;
	
@end
