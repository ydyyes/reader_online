	//
	//  SearchCollectionFlowLayout.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/20.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "SearchCollectionFlowLayout.h"

@interface SearchCollectionFlowLayout ()

@end

@implementation SearchCollectionFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

	NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
	if (attributes.count == 0) {
		return attributes;
	}
	UICollectionViewLayoutAttributes *firstLayoutAttributes = attributes[0];
	firstLayoutAttributes.frame = CGRectMake(self.sectionInset.left, firstLayoutAttributes.frame.origin.y, firstLayoutAttributes.frame.size.width, firstLayoutAttributes.frame.size.height);

	for(int i = 1; i < [attributes count]; i++) {

			//当前attributes
		UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
			//上一个attributes
		UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];

			//我们想设置的最大间距，可根据需要改
		NSInteger maximumSpacing = _maxInteritemSpacing;
			//前一个cell的最右边
		NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
			//如果当前一个cell的最右边加上我们想要的间距加上当前cell的宽度依然在contentSize中，我们改变当前cell的原点位置
			//不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的x值都被加到第一行最后一个元素的后面了
		if(origin + maximumSpacing*2 + currentLayoutAttributes.frame.size.width <= self.collectionViewContentSize.width) {
			CGRect frame = currentLayoutAttributes.frame;
			frame.origin.x = origin + maximumSpacing;
			currentLayoutAttributes.frame = frame;
		} else {
			CGRect frame = currentLayoutAttributes.frame;
			frame.origin.x = self.sectionInset.left;
			currentLayoutAttributes.frame = frame;
		}
		
		if (i == [self.collectionView numberOfItemsInSection:0]) {
			CGRect frame = currentLayoutAttributes.frame;
			frame.origin.x = self.sectionInset.left;
			currentLayoutAttributes.frame = frame;
		}

	}

	return attributes;

}
@end
