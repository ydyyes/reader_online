//
//  BookCityFooterInSectionView.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityFooterInSectionView.h"

#import "BookCityFooterCollectionViewCell.h"


@interface BookCityFooterInSectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

/** 注释 */
@property (nonatomic, readwrite , strong) UICollectionView *collectionView;

@end


@implementation BookCityFooterInSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initCollectionView];
	}
	return self;
}

#pragma mark - - 初始化 collectionView
- (void)initCollectionView {

	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.minimumLineSpacing = 15;
	flowLayout.minimumInteritemSpacing = 15;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth],150) collectionViewLayout:flowLayout];
	self.collectionView.alwaysBounceHorizontal = NO;
	self.collectionView.backgroundColor = [UIColor whiteColor];
	[self addSubview:self.collectionView];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;

	[self.collectionView registerClass:[BookCityFooterCollectionViewCell class] forCellWithReuseIdentifier:@"BookCityFooterCollectionViewCell"];

}

#pragma mark -  -collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 4;//self.bookArray.count;//增加添加书籍的一个item
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	BookCityFooterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCityFooterCollectionViewCell" forIndexPath:indexPath];
	if (self.bookArray.count > 0) {

	}else{
//		cell.bookImg.image = [UIImage imageNamed:@""];
//		cell.bookImg.image = [UIImage imageNamed:@"add"];
//		cell.bookNameLb.text = @"";
		NSLog(@"index:%ld",(long)indexPath.row);
	}

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
		/// cell 的大小 每行显示3个 行间距为 0
	return [self fixSizeBydisplayWidth:[JPTool screenWidth] col:4 space:15 sizeForItemAtIndexPath:indexPath];
}


- (CGSize)fixSizeBydisplayWidth:(float)displayWidth col:(int)col space:(int)space sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

	float pxWidth = displayWidth * [UIScreen mainScreen].scale;
	pxWidth = pxWidth - space * (col + 1);
	int mo = (int)pxWidth % col;
	if (mo != 0) {
			// 屏幕宽度不可以平均分配
		float fixPxWidth = pxWidth - mo;

		float itemWidth  = fixPxWidth / col;
		if ([JPTool screenWidth] < 375) {
			itemWidth = fixPxWidth / col - 5;
		}

			// 高度取最高的，所以要加1
		float itemHeight = (itemWidth)*96/72 + 1.0;// 高度
		if (indexPath.row % col < mo) {
				// 模再分配给左边的cell，直到分配完为止
			itemWidth = itemWidth + 1.0;
		}
			// 图片的高和宽的比值

		NSNumber *numW = @(itemWidth / [UIScreen mainScreen].scale);
		NSNumber *numH = @(itemHeight / [UIScreen mainScreen].scale);
		return CGSizeMake(numW.floatValue, numH.floatValue+50);

	}else {
			// 屏幕可以平均分配
		float itemWidth = (pxWidth / col)/ [UIScreen mainScreen].scale;
		float itemHeight = (itemWidth)*96/72+50;
		return CGSizeMake(itemWidth, itemHeight);
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
