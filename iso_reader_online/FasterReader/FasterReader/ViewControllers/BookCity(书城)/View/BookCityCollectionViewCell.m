//
//  BookCityCollectionViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityCollectionViewCell.h"

@implementation BookCityCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"BookCityCollectionViewCell" owner:nil options:nil] lastObject];
		self.bookImgHeight.constant = 100*[JPTool WidthScale];
	}
	return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];


}

- (void)setCellData:(BookCityBookModel*)model {

	 self.bookNameLb.text = model.title;//书籍名称
	[self.bookImg yy_setImageWithURL:[NSURL URLWithString:model.cover] placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图
	if ([model.over isEqualToString:@"1"]) {//完结
		self.bookStateImg.image = [UIImage imageNamed:@"wangjie"];
	}else{//连载
		self.bookStateImg.image = [UIImage imageNamed:@"lianzai"];
	}
}
//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//	[self setNeedsLayout];
//	[self layoutIfNeeded];
//	CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
//	CGRect cellFrame = layoutAttributes.frame;
//	cellFrame.size.height = size.height;
//	layoutAttributes.frame = cellFrame;
//	return layoutAttributes;
//}

@end
