//
//  ZZPhotoPickerCell.m
//  ZZFramework
//
//  Created by Yuan on 15/7/7.
//  Copyright (c) 2015年 zzl. All rights reserved.
//

#import "ZZPhotoPickerCell.h"
#import "ZZAlumAnimation.h"
@implementation ZZPhotoPickerCell
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _photo = [[UIImageView alloc]initWithFrame:self.bounds];
        
        _photo.layer.masksToBounds = YES;
        
        _photo.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:_photo];
        
        CGFloat btnSize = self.frame.size.width / 2;

        _hookImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - btnSize-3, 3, btnSize, btnSize)];
        _hookImgView.userInteractionEnabled = YES;
        _hookImgView.contentMode =  UIViewContentModeTopRight;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectPhotoButtonMethod:)];
        [_hookImgView addGestureRecognizer:tap];
        [self.contentView addSubview:_hookImgView];
        
    }
    return self;
}

#pragma  mark 选中图片点击
-(void) selectPhotoButtonMethod:(UIImageView *)sender{
    self.selectBlock();
}
#pragma  mark 设置选中图片状态样式
-(void)setIsSelect:(BOOL)isSelect {
    if (isSelect == YES) {
        _hookImgView.image = Pic_Btn_Selected;
    }else{
        _hookImgView.image = Pic_btn_UnSelected;
    }
}

#pragma  mark 设置 cell 数据
-(void)loadPhotoData:(ZZPhoto *)photo {
    if (photo.isSelect == YES) {
        _hookImgView.image = Pic_Btn_Selected;
    }else{
        _hookImgView.image = Pic_btn_UnSelected;
    }
    
    if ([photo isKindOfClass:[ZZPhoto class]]) {
        [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            self.photo.image = result;
        }];
    }
}
@end
