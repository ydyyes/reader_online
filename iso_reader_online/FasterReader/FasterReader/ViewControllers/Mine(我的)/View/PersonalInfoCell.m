//
//  PersonalInfoCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/10.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "PersonalInfoCell.h"

@interface PersonalInfoCell()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headImgHeight;

@end

@implementation PersonalInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:PersonalInfoCell_Identifier owner:self options:nil] lastObject];
		self.headImgHeight.constant = 56;
		self.headImg.layer.cornerRadius  = 56/2.0;
		self.headImg.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setCellData:(NSMutableDictionary*)dataDict AtIndexPath:(NSIndexPath *)indexPath {

	NSMutableArray *leftArray = [dataDict objectForKey:@"left"];
	NSMutableArray *rightArray = [dataDict objectForKey:@"right"];
	if (indexPath.row == 0) {
		self.rightTitleLb.hidden = YES;
		self.headImg.hidden = NO;
        
        NSURL *url = [NSURL URLWithString:[JPTool USER_AVATAR]];
        [self.headImg yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"touxiang"]];

	}else{
		self.rightTitleLb.hidden = NO;
		self.headImg.hidden = YES;
		self.rightTitleLb.text = rightArray[indexPath.row];
	}

	self.leftTitleLb.text = leftArray[indexPath.row];
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
