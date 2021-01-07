//
//  BookCityTableViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityTableViewCell.h"

@implementation BookCityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:BookCityTableViewId owner:self options:nil] lastObject];
		self.bookImgLeftSpace.constant = 15;
		self.bookImgWidth.constant = ([JPTool screenWidth]-15*5)/4.0;
		self.bookDescLb.numberOfLines = 3;
		if ([JPTool screenWidth] < 414) {
		self.bookDescLb.numberOfLines = 2;
		}
		[self layoutIfNeeded];

	}
	return self;
}
- (void)setCellData:(NSMutableArray*)dataArr AtIndexPath:(NSIndexPath *)indexPath {

	[Utils cutImage:self.bookImg];// 图片填充
	if (indexPath.section%2 == 0){

		if (indexPath.row==0) {
			BookCityBookModel *model = dataArr[indexPath.row];
			self.bookNameLb.text = model.title;//书籍名称

			[self.bookImg yy_setImageWithURL:[NSURL URLWithString:model.cover] placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图

			NSString *authStr = [NSString stringWithFormat:@"%@ | %@",model.author,model.majorCate];
			self.bookAuthorLb.text = authStr;// 书的作者
			self.bookDescLb.text = model.longIntro;// 描述
		}

	}else {

		BookCityBookModel *model = dataArr[indexPath.row];
		self.bookNameLb.text = model.title;//书籍名称

		[self.bookImg yy_setImageWithURL:[NSURL URLWithString:model.cover] placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图

		NSString *authStr = [NSString stringWithFormat:@"%@ | %@",model.author,model.majorCate];
		self.bookAuthorLb.text = authStr;// 书的作者
		self.bookDescLb.text = model.longIntro;// 描述
	}


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
