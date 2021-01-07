//
//  SerachTabViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "SerachTabViewCell.h"

@implementation SerachTabViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:tableViewCellId owner:self options:nil] lastObject];

	}
	return self;
}
- (void)setCellDate:(NSIndexPath*)indexPath withDate:(SerachResultModel *)model {
	

	NSURL *url = [NSURL URLWithString:model.cover];
	[self.bookImg yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图
	self.bookNameLb.text = model.title;// 书名
	self.bookDescLb.text = model.longIntro;// 书籍描述
	NSString *authStr = [NSString stringWithFormat:@"%@人在追|%@%%读者留存|%@著",model.latelyFollower,model.retentionRatio,model.author];
	self.bookDescLb.text = authStr;// 书的作者
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
