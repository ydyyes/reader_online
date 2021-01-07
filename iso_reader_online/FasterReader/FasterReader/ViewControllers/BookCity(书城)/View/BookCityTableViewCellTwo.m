//
//  BookCityTableViewCellTwo.m
//  NightReader
//
//  Created by 张俊平 on 2019/5/23.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookCityTableViewCellTwo.h"
#import "BookDetailViewController.h"

#import "BookCityFooterCollectionViewCell.h"

#define JianGe 15

#define GeShu 4

#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define Screenheight ([UIScreen mainScreen].bounds.size.height)

@interface BookCityTableViewCellTwo ()<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

/** 注释 */
@property (nonatomic, readwrite , strong) UICollectionView *collectionView;

@end

@implementation BookCityTableViewCellTwo

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:BookCityTableViewCellTwoId owner:self options:nil] lastObject];
		[self initCollectionView];
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

#pragma mark - - 初始化 collectionView
- (void)initCollectionView {

	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.minimumLineSpacing = 0;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	CGSize size = [JPTool getSizeWithOther:55];
	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [JPTool screenWidth],size.height) collectionViewLayout:flowLayout];
	self.collectionView.alwaysBounceHorizontal = NO;
	self.collectionView.bounces = NO;
	self.collectionView.scrollEnabled = NO;
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self addSubview:self.collectionView];

	[self.collectionView registerClass:[BookCityFooterCollectionViewCell class] forCellWithReuseIdentifier:@"BookCityFooterCollectionViewCell"];

}

#pragma mark -  -collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.bookArray.count;//增加添加书籍的一个item
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	BookCityFooterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCityFooterCollectionViewCell" forIndexPath:indexPath];
	if (self.bookArray.count > 0) {
		[cell setCellData:_bookArray AtIndexPath:indexPath];
	}else{
			//		cell.bookNameLb.text = @"";
		NSLog(@"index:%ld",(long)indexPath.row);
	}

	return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"index:%ld",(long)indexPath.row);

	BookCityBookModel *model = _bookArray[indexPath.row];
	BookDetailViewController *BookDetailVc = [[BookDetailViewController alloc] init];
	BookDetailVc.bookId = model.bookId;
	BookDetailVc.hidesBottomBarWhenPushed = YES;
	[[self parentController:self].navigationController pushViewController:BookDetailVc animated:YES];

}
#pragma mark -- 获取到当前视图所在控制器
- (UIViewController *)parentController:(UIView *)view
{
	UIResponder *responder = [view nextResponder];
	while (responder) {
		if ([responder isKindOfClass:[UIViewController class]]) {
			return (UIViewController *)responder;
		}
		responder = [responder nextResponder];
	}
	return nil;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//		/// cell 的大小 每行显示3个 行间距为 0
//	return [self fixSizeBydisplayWidth:[JPTool screenWidth] col:4 space:10 sizeForItemAtIndexPath:indexPath];
//}



	//定义每个UICollectionView 的大小
- ( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath {

	CGSize size = [JPTool getSizeWithOther:55];
	return size;//CGSizeMake((ScreenWidth - JianGe*(GeShu+1)) / GeShu, size.height);

}

- (CGSize)fixSizeBydisplayWidth:(float)displayWidth col:(int)col space:(int)space sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

	float pxWidth = displayWidth * [UIScreen mainScreen].scale;
	pxWidth = pxWidth - space * (col + 8);
	int mo = (int)pxWidth % col;
	if (mo != 0) {
			// 屏幕宽度不可以平均分配
		float fixPxWidth = pxWidth - mo;

		float itemWidth  = fixPxWidth / col;
		if ([JPTool screenWidth] < 375) {
			itemWidth = fixPxWidth / col;
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
		return CGSizeMake(numW.floatValue, numH.floatValue+55);

	}else {
			// 屏幕可以平均分配
		float itemWidth = (pxWidth / col)/ [UIScreen mainScreen].scale;
		float itemHeight = (itemWidth)*96/72+55;
		return CGSizeMake(itemWidth, itemHeight);
	}
}


-(void)setBookArray:(NSMutableArray *)bookArray {
	if (bookArray.count >1) {
		NSArray *array = [bookArray subarrayWithRange:NSMakeRange(1, bookArray.count-1)];
		NSMutableArray *bookArray1 = [NSMutableArray arrayWithArray:array];
		_bookArray = bookArray1;
		[self.collectionView reloadData];

	}
}
@end
