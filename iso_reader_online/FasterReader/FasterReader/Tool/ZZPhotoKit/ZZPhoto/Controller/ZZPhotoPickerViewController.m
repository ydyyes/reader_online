//
//  ZZPhotoPickerViewController.m
//  ZZFramework
//
//  Created by Yuan on 15/7/7.
//  Copyright (c) 2015年 zzl. All rights reserved.
//



#import "ZZPhotoPickerViewController.h"
#import "ZZPhotoDatas.h"
#import "ZZPhotoPickerCell.h"
#import "ZZPhotoBrowerViewController.h"
#import "ZZPhotoHud.h"
#import "ZZPhotoAlert.h"
#import "ZZAlumAnimation.h"
#import "ZZPhoto.h"
#import "ZZPhotoPickerFooterView.h"
#import "UIImage+Tools.h"

@interface ZZPhotoPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,   copy) NSArray                     *photoArray;//展示图片
@property (nonatomic, strong) NSMutableArray              *selectArray;//选中图片



@property (nonatomic, strong) UICollectionView            *picsCollection;
@property (nonatomic, strong) UIBarButtonItem             *backBtn;
@property (nonatomic, strong) UIBarButtonItem             *cancelBtn;
@property (nonatomic, strong) UIButton                    *doneBtn;//完成按钮
@property (nonatomic, strong) UIButton                    *previewBtn;//预览按钮
@property (nonatomic, strong) UILabel                     *totalRound;//小红点
@property (nonatomic, strong) UILabel                     *numSelectLabel;

@property (nonatomic, strong) ZZPhotoDatas                *datas;
@property (nonatomic, strong) ZZPhotoBrowerViewController *browserController;//图片预览

@end

@implementation ZZPhotoPickerViewController

#pragma  mark lazyload 选中图片数组
- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}



#pragma mark lazyload 图片数据
- (ZZPhotoDatas *)datas{
    if (!_datas) {
        _datas = [[ZZPhotoDatas alloc]init];
        
    }
    return _datas;
}

#pragma mark init
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark lazyload - 返回按钮
- (UIBarButtonItem *)backBtn{
    if (!_backBtn) {
        UIButton *back_btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 44)];
        [back_btn setImage:Back_Btn_Pic forState:UIControlStateNormal];
        [back_btn setImage:[UIImage imageNamed:@"back_button_high.png"] forState:UIControlStateHighlighted];
        back_btn.frame = CGRectMake(0, 0, 45, 44);
        [back_btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = [[UIBarButtonItem alloc] initWithCustomView:back_btn];
    }
    return _backBtn;
}

#pragma mark lazyload - 取消按钮
- (UIBarButtonItem *)cancelBtn{
    if (!_cancelBtn) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
        [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _cancelBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    }
    return _cancelBtn;
}


#pragma mark lazyload - 完成按钮
- (UIButton *)doneBtn{
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(ZZ_VW - 60, 1, 50, 49)];
        [_doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"12b7f5"] forState:UIControlStateNormal];
    }
    return _doneBtn;
}

#pragma mark lazyload - 预览按钮
- (UIButton *)previewBtn{
    if (!_previewBtn) {
        _previewBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 1, 50, 49)];
        [_previewBtn addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor colorWithHexString:@"12b7f5"] forState:UIControlStateNormal];
    }
    return _previewBtn;
}


#pragma  mark lazyload 红点
- (UILabel *)totalRound{
    if (!_totalRound) {
        _totalRound = [[UILabel alloc]initWithFrame:CGRectMake(ZZ_VW - 90, 16, 20, 20)];
        if (self.roundColor == nil) {
            _totalRound.backgroundColor = [UIColor redColor];
        }else{
            _totalRound.backgroundColor = self.roundColor;
        }
        _totalRound.layer.masksToBounds = YES;
        _totalRound.textAlignment = NSTextAlignmentCenter;
        _totalRound.textColor = [UIColor whiteColor];
        _totalRound.text = @"0";
        [_totalRound.layer setCornerRadius:CGRectGetHeight([_totalRound bounds]) / 2];
    }
    return _totalRound;
}


#pragma  mark 返回按钮点击
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma  mark 取消按钮点击
- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 完成按钮点击
- (void)done{

    if ([self.selectArray count] == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [ZZPhotoHud showActiveHud];
        __block NSMutableArray<ZZPhoto *> *photos = [NSMutableArray array];
        __weak __typeof(self) weakSelf = self;
        for (int i = 0; i < self.selectArray.count; i++) {
            ZZPhoto *photo = [self.selectArray objectAtIndex:i];
            [self.datas fetchImageObject:photo.asset complection:^(UIImage *image,NSURL *imageUrl) {
                
                if (image){
                    ZZPhoto *model = [[ZZPhoto alloc]init];
                    model.asset = photo.asset;
                    model.originImage = image;
                    model.imageUrl = imageUrl;
                    model.createDate = photo.asset.creationDate;
                    [photos addObject:model];
                }
                if (photos.count < weakSelf.selectArray.count){
                    return;
                }
                if (weakSelf.PhotoResult) {
                    weakSelf.PhotoResult([NSArray arrayWithArray:photos]);
                }
                
                [ZZPhotoHud hideActiveHud];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}

#pragma  mark 预览按钮点击
- (void)preview{
    
    if (self.selectArray.count == 0) {
        [self showPhotoPickerAlertView:@"提醒" message:@"您还没有选中图片，不需要预览"];
    }else{
//        self.browserController = [[ZZPhotoBrowerViewController alloc]init];
//        self.browserController.photoData = self.selectArray;
//        [self.browserController showIn:self];
        
        ZZPhotoBrowerViewController *brower = [[ZZPhotoBrowerViewController alloc]init];
        brower.enterFromPreview = @"1";
        [brower.photoData addObjectsFromArray:self.selectArray];//所有照片
        [brower.selectedPhotoArray removeAllObjects];
        [brower.selectedPhotoArray addObjectsFromArray:self.selectArray];//已经选中的照片
        WS(ws);
        brower.maxSelectNumber = self.selectNum;//最大选择数量
        brower.scrollIndex = 0;
        brower.passSelectPhotoArrayBlock = ^(NSMutableArray *array) {
            
            [ws.selectArray removeAllObjects];
            [ws.selectArray addObjectsFromArray:array];
            
            ws.totalRound.text = [NSString stringWithFormat:@"%ld",ws.selectArray.count];
            [ws.picsCollection reloadData];
        };
        [brower showIn:self];
    }

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"top_navigation_bg_6p"] imageByScrollAlpha:1.0f] forBarMetrics:UIBarMetricsDefault];
    if (_shouldRefreshData) {
        [self loadPhotoData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _shouldRefreshData = NO;
}
#pragma  mark 禁止滑动返回
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    // 禁用返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    // 开启返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //设置导航栏
    [self initInterUI];
    //设置图片展示
    [self makeCollectionViewUI];
    //创建底部工具栏
    [self makeTabbarUI];
    //预览控制器
    self.browserController = [[ZZPhotoBrowerViewController alloc]init];
}

#pragma  mark 初始化导航栏
- (void)initInterUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor                 = [UIColor whiteColor];
		// MARK:返回按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:Back_Btn_Pic];
    self.navigationItem.rightBarButtonItem    = self.cancelBtn;
}
#pragma  mark 初始化工具栏
- (void)makeTabbarUI {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = ZZ_RGB(245, 245, 245);
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.doneBtn];
    [view addSubview:self.previewBtn];
    [view addSubview:self.totalRound];
    [self.view addSubview:view];
    NSLayoutConstraint *tab_left = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0.0f];
    
    NSLayoutConstraint *tab_right = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0.0f];
    
    NSLayoutConstraint *tab_bottom = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0.0f];
    
    NSLayoutConstraint *tab_height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:TabBarHeight];
    
    [self.view addConstraints:@[tab_left,tab_right,tab_bottom,tab_height]];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ZZ_VW, 1)];
    viewLine.backgroundColor = ZZ_RGB(230, 230, 230);
    viewLine.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:viewLine];
}

- (void)makeCollectionViewUI
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    CGFloat photoSize = ([UIScreen mainScreen].bounds.size.width - 3) / 4;
    flowLayout.minimumInteritemSpacing = 1.0;//item 之间的行的距离
    flowLayout.minimumLineSpacing = 1.0;//item 之间竖的距离
    flowLayout.itemSize = (CGSize){photoSize,photoSize};
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _picsCollection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_picsCollection registerClass:[ZZPhotoPickerCell class] forCellWithReuseIdentifier:@"PhotoPickerCell"];
    [_picsCollection registerClass:[ZZPhotoPickerFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    flowLayout.footerReferenceSize = CGSizeMake(ZZ_VW, 70);
    _picsCollection.delegate = self;
    _picsCollection.dataSource = self;
    _picsCollection.backgroundColor = [UIColor whiteColor];
    [_picsCollection setUserInteractionEnabled:YES];
    _picsCollection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_picsCollection];
    [_picsCollection reloadData];
    
    
    NSLayoutConstraint *pic_top = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_picsCollection attribute:NSLayoutAttributeTop multiplier:1 constant:0.0f];
    
    NSLayoutConstraint *pic_bottom = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_picsCollection attribute:NSLayoutAttributeBottom multiplier:1 constant:44.0f];
    
    NSLayoutConstraint *pic_left = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_picsCollection attribute:NSLayoutAttributeLeft multiplier:1 constant:0.0f];
    
    NSLayoutConstraint *pic_right = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_picsCollection attribute:NSLayoutAttributeRight multiplier:1 constant:0.0f];
    
    [self.view addConstraints:@[pic_top,pic_bottom,pic_left,pic_right]];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //滚动到底部
    if (self.photoArray.count != 0) {
        [_picsCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.photoArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

#pragma  mark 加载图片数据
- (void)loadPhotoData {
    if (_isAlubSeclect == YES) {
        [self.datas fetchPhotoAssets:self.alumbModel.fetchResult completion:^(NSArray *data) {
            self.photoArray = data;
            [_picsCollection reloadData];
        }];
    }else{
        self.navigationItem.title = @"相机胶卷";
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [self.datas fetchPhotoAssets:[self.datas fetchCameraRollFetchResult] completion:^(NSArray *data) {
            self.photoArray = data;
            [_picsCollection reloadData];
        }];
    }
}

#pragma mark 选中数组操作
- (void)selectPhotoAtIndex:(NSInteger)index {
    ZZPhoto *photo = [self.photoArray objectAtIndex:index];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (photo != nil) {
        if (photo.isSelect == NO) {
            
            //最多选择提示
            if (self.selectArray.count + 1 > _selectNum) {
                [self showSelectPhotoAlertView:_selectNum];
            }else{
                //红点动画
                [[ZZAlumAnimation sharedAnimation] roundAnimation:self.totalRound];
                //iCloud 文件提示
                if ([self.datas CheckIsiCloudAsset:photo.asset] == YES) {
                    [[ZZPhotoAlert sharedAlert] showPhotoAlert];
                }else{
                    photo.isSelect = YES;
                    [self changeSelectButtonStateAtIndex:index withPhoto:photo];
                    [self.selectArray insertObject:[self.photoArray objectAtIndex:index] atIndex:self.selectArray.count];
                    self.totalRound.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectArray.count];
                }
            }
        }else{
            
            //取消选中
            photo.isSelect = NO;
            [self changeSelectButtonStateAtIndex:index withPhoto:photo];
            [self.selectArray removeObject:[self.photoArray objectAtIndex:index]];
            [[ZZAlumAnimation sharedAnimation] roundAnimation:self.totalRound];
            self.totalRound.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.selectArray.count];
        }
    }
    
}

#pragma  mark 改变选中状态
- (void)changeSelectButtonStateAtIndex:(NSInteger)index withPhoto:(ZZPhoto *)photo {
    ZZPhotoPickerCell *cell = (ZZPhotoPickerCell *)[_picsCollection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.isSelect = photo.isSelect;
}

#pragma  mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ZZPhotoPickerCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPickerCell" forIndexPath:indexPath];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    photoCell.selectBlock = ^(){
        
        [weakSelf selectPhotoAtIndex:indexPath.row];
        
    };
    
    [photoCell loadPhotoData:[self.photoArray objectAtIndex:indexPath.row]];
    
    return photoCell;
}
#pragma UICollectionView --- Delegate
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZZPhotoPickerFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    
    footerView.total_photo_num = _photoArray.count;
    
    return footerView;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WS(ws);
    self.browserController.enterFromPreview = @"1";
    [self.browserController.photoData addObjectsFromArray:self.photoArray];//所有照片
    [self.browserController.selectedPhotoArray removeAllObjects];
    [self.browserController.selectedPhotoArray addObjectsFromArray:self.selectArray];//已经选中的照片
    self.browserController.maxSelectNumber = self.selectNum;//最大选择数量
    self.browserController.scrollIndex = indexPath.row;
    
    self.browserController.passSelectPhotoArrayBlock = ^(NSMutableArray *array) {
        [ws.selectArray removeAllObjects];
        [ws.selectArray addObjectsFromArray:array];
        ws.totalRound.text = [NSString stringWithFormat:@"%ld",ws.selectArray.count];
        [ws.picsCollection reloadData];
    };
    [self.browserController showIn:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 60);
}

#pragma mark ZZBrowserPickerDelegate
- (NSInteger)zzbrowserPickerPhotoNum:(ZZPhotoBrowerViewController *)controller {
    return self.selectArray.count;
}

- (NSArray *)zzbrowserPickerPhotoContent:(ZZPhotoBrowerViewController *)controller {
    return self.selectArray;
}

#pragma  mark 选择数目提醒
- (void)showSelectPhotoAlertView:(NSInteger)photoNumOfMax {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:[NSString stringWithFormat:Alert_Max_Selected,(long)photoNumOfMax]preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma  mark 无图预览提醒
- (void)showPhotoPickerAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
