	//
	//  JPLabel.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/3/20.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "JPLabel.h"

	//@synthesize verticalAlignment = _verticalAlignment;

@implementation JPLabel

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.verticalAlignment = VerticalAlignmentMiddle;
	}
	return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
	_verticalAlignment = verticalAlignment;
	[self setNeedsLayout];
}


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	
	CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	switch (self.verticalAlignment) {
		case VerticalAlignmentTop:
			textRect.origin.y = bounds.origin.y;
			break;
		case VerticalAlignmentBottom:
			textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
			break;
		case VerticalAlignmentMiddle:
				// Fall through.
		default:
			textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
	}
	return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
	CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
	[super drawTextInRect:actualRect];
}
@end
