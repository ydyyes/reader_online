//
//  BookMarkTableViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/6/11.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookMarkTableViewCell.h"

@implementation BookMarkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:BookMarkTableViewCellId owner:self options:nil] lastObject];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/** 设置cell数据 */
- (void)setCellData:(BookMarkModel*)model AtIndexPath:(NSIndexPath *)indexPath {

	self.titleLb.text = model.title;
	self.percentageLb.text = model.percentage;
	self.dateLb.text = model.timestemp;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
	[super layoutSubviews];

	for (UIControl *control in self.subviews) {
		if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
			continue;
		}

		for (UIView *subView in control.subviews) {
			if (![subView isKindOfClass: [UIImageView class]]) {
				continue;
			}

			UIImageView *imageView = (UIImageView *)subView;
			if (self.selected) {// 改变系统的勾选 图片或者颜色
					//				imageView.image = [UIImage imageNamed:@"xuanzhong_h copy 2"]; // 选中时的图片
				[imageView setValue:[UIColor redColor] forKey:@"tintColor"];   // 选中时的颜色
			} else {
					//				imageView.image = [UIImage imageNamed:@"share_wxc"];   // 未选中时的图片
			}

		}
	}

}
@end
