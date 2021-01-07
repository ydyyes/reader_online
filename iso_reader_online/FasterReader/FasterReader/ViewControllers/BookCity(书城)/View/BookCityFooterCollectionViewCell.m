//
//  BookCityFooterCollectionViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityFooterCollectionViewCell.h"

@implementation BookCityFooterCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"BookCityFooterCollectionViewCell" owner:nil options:nil] lastObject];
//		self.bookNameLb.lineBreakMode = NSLineBreakByTruncatingTail;
//		self.bookNameLb.numberOfLines = 2;
//		[self.bookNameLb setVerticalAlignment:VerticalAlignmentTop];

	}
	return self;
}

- (void)setCellData:(NSMutableArray*)dataArr AtIndexPath:(NSIndexPath *)indexPath {

	BookCityBookModel *model = dataArr[indexPath.row];
	self.bookNameLb.text = model.title;//书籍名称
	[Utils cutImage:self.bookImg];
	[self.bookImg yy_setImageWithURL:[NSURL URLWithString:model.cover] placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图

	NSString *authStr = [NSString stringWithFormat:@"%@",model.author];
	self.bookAuthorLb.text = authStr;// 书的作者

}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
