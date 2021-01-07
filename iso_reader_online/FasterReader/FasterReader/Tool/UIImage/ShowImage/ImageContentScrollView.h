//
//  ImageContentScrollView.h
//  publicwine
//
//  Created by 何伟东 on 14-1-2.
//  Copyright (c) 2014年 何伟东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"
@protocol ShowimageScrollViewDelegate <NSObject>
-(void)remove:(CGSize )size;
@end
@interface ImageContentScrollView : UIScrollView<UIScrollViewDelegate>{
    UIImageView *touchImageView;
    DACircularProgressView *_progressView;

}
@property(nonatomic,strong) UIImageView *touchImageView;
@property(nonatomic,strong) UIImageView *tempImageView;
@property (nonatomic ,weak) id<ShowimageScrollViewDelegate> delegate_size;

- (id)initWithFrame:(CGRect)frame originalImageView:(UIImageView*)originalImageView imageUrl:(NSString*)url superView:(UIScrollView *)superView;

@end
