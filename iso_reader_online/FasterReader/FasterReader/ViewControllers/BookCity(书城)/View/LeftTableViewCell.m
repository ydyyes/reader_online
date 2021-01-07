//
//  LeftTableViewCell.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "LeftTableViewCell.h"

@implementation LeftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"LeftTableViewCell" owner:self options:nil] lastObject];
	}
	return self;
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
