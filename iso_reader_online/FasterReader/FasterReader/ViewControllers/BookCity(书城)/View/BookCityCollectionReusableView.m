//
//  BokCityCollectionReusableView.m
//  NightReader
//
//  Created by 张俊平 on 2019/2/27.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityCollectionReusableView.h"

@interface BookCityCollectionReusableView()

@property(nonatomic,assign) NSInteger tagNum;

@end
@implementation BookCityCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {

		self = [[[NSBundle mainBundle] loadNibNamed:@"BookCityCollectionReusableView" owner:nil options:nil] firstObject];
		self.tagNum = 100;
		self.buttonLeftSpace.constant = 0;
		self.buttonMidSpace.constant = 20;
		self.buttonWidth.constant = ([JPTool screenWidth]-80 - self.buttonLeftSpace.constant*2 - self.buttonMidSpace.constant-16*2)/2;
		[self setButtonConfigure:self.buttonOne];
		[self setButtonConfigure:self.buttonTwo];
		[self setButtonConfigure:self.buttonThree];
		[self setButtonConfigure:self.buttonFour];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setButtonConfigure:(UIButton*)button {

	CGFloat margin = [JPTool is_iPhoneXN] ? 14 : 28;
	[button setEdgeInsetsWithType:(SSEdgeInsetsTypeTitle) marginType:(SSMarginTypeRight) margin:margin];//设置文字偏移

	self.tagNum++;
	button.tag = self.tagNum;
//	NSLog(@"%ld,%ld",button.tag,self.tagNum);
	[button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//	button.layer.cornerRadius = 5;
//	button.layer.masksToBounds = YES;
}

- (void)buttonClick:(UIButton*)sender {

	if ([self.delegate respondsToSelector:@selector(bookCityCollectionReusableViewDidSelectButton:)]) {
		[self.delegate bookCityCollectionReusableViewDidSelectButton:sender];
	}
}
@end
