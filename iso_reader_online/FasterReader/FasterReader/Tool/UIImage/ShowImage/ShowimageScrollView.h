//
//  ShowimageScrollView.h
//  publicwine
//
//  Created by 何伟东 on 14-1-2.
//  Copyright (c) 2014年 何伟东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageContentScrollView.h"
@interface ShowimageScrollView : UIScrollView<UIScrollViewDelegate,ShowimageScrollViewDelegate>

@property(nonatomic,strong) UIPageControl *imagePageControl;
@property(nonatomic,strong) UIImageView   *originalImageView;
@property(nonatomic,strong) NSArray       *imageArray;
@property(nonatomic,strong) UIButton      *saveButton;
@property(nonatomic,strong) UILabel       *pageLabel;
+(ShowimageScrollView*)share;
-(void)showWithImageArray:(NSArray*)imageArray currentView:(UIView*)currentView index:(int)index;
@end
