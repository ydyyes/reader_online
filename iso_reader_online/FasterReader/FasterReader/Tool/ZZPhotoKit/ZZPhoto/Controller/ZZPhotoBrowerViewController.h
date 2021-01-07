//
//  ZZPhotoBrowerViewController.h
//  ZZPhotoKit
//
//  Created by 袁亮 on 16/5/27.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZResourceConfig.h"


typedef void(^PassSelectedPhotoArrayBlcok)(NSMutableArray *array);
@interface ZZPhotoBrowerViewController : UIViewController
@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, copy) NSString *enterFromPreview;

@property (nonatomic, copy) PassSelectedPhotoArrayBlcok passSelectPhotoArrayBlock;

@property (nonatomic,   copy) NSMutableArray *photoData;

@property (nonatomic, assign) NSInteger scrollIndex;
@property(nonatomic, copy) NSMutableArray *selectedPhotoArray;
@property(nonatomic, assign) NSInteger selectedCount;
@property(nonatomic, assign) NSInteger maxSelectNumber;
@property(nonatomic, strong) UIButton *rightBtn;
-(void) showIn:(UIViewController *)controller;

@end
