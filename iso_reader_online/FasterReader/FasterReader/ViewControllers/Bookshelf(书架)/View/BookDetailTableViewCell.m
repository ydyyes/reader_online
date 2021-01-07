//
//  BookDetailTableViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookDetailTableViewCell.h"

@implementation BookDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:tableViewCellId owner:self options:nil] lastObject];

	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/** 设置cell数据 */
- (void)setCellData:(BookCityChartsModel*)model AtIndexPath:(NSIndexPath *)indexPath {

	self.bookNameLb.text = model.title;// 书名
	self.bookDescLb.text = [NSString stringWithFormat:@"%@人在追 | %@%%读者留存",model.latelyFollower,model.retentionRatio];// 书籍描述
	NSString *authStr = [NSString stringWithFormat:@"%@ | %@",model.author,model.majorCate];
	self.bookAuthorLb.text = authStr;// 书的作者

	NSURL *url = [NSURL URLWithString:model.cover];// 图书封面
	[self.bookImg yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
