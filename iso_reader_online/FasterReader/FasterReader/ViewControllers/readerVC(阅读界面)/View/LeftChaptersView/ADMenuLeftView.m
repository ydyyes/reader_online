//
//  ADMenuLeftView.m
//  reader
//
//  Created by beequick on 2017/9/20.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADMenuLeftView.h"
#import "MSYReaderSetting.h"
#import "ADTableViewDataSouce.h"
#import "ADMenuLeftCell.h"
#import "MSYBookDownloadManager.h"
#import "UIView+ZJP.h"
#import "JPScrollBar.h"
#import "FasterReader-Swift.h"

static NSString *const idcell = @"idcell";
static const CGFloat kJPscrollBarHeight = 30;

@interface ADMenuLeftView ()<ADTableViewDelegate,JPScrollBarDelegate, MSYBookDownloadManagerDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewTopSpace;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *bookNameL;
@property (weak, nonatomic) IBOutlet UILabel *chaptersLb;

@property (nonatomic, strong) ADTableViewDataSouce *dataSource;
/** 下载按钮 */
@property (strong, nonatomic) IBOutlet UIButton *downLoadBtn;
/** 下载按钮高度 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *downloadBtnHeight;

@property (nonatomic, weak) JPScrollBar *scrollBar;
@property (nonatomic, assign) CGFloat tabHeight;


/** 当前小说下载状态 下载中 暂停 已经完成 未下载 */
@property (nonatomic, assign) MSYBookDownloadStatus downState;

@end

@implementation ADMenuLeftView

+ (instancetype)leftView {

    return [[NSBundle mainBundle] loadNibNamed:@"ADMenuLeftView" owner:nil options:nil].lastObject;
}

// 下载完成3  下载中1 下载暂停2 没有下载0
- (void)awakeFromNib {
    [super awakeFromNib];

    
    [MSYBookDownloadManager share].delegate = self;
    
	self.topViewTopSpace.constant = StatusBarHeight-15;
	NSLog(@"%f",self.topViewTopSpace.constant);
	if ([JPTool is_iPhoneXN]) {
		self.downloadBtnHeight.constant = 55;
	}else{
		self.downloadBtnHeight.constant = 45;
	}

    [self configUI];

}


- (void)dealloc {
//    [self.downloader suspendedDownload];
//    [self.downloader cancleAllOperation];
}

- (void)setBookId:(NSString *)bookId {
    _bookId = [bookId copy];
    // 获取下载状态
    self.downState = [MSYBookCache getDownloadStateWithBookid: self.bookId];
}

- (void)setBookName:(NSString *)bookName {
    _bookName = [bookName copy];
    self.bookNameL.text = bookName;
}

-(void)setChapters:(NSArray *)chapters {
    _chapters = chapters;
    self.chaptersLb.text = [NSString stringWithFormat:@"共%ld章",(long)chapters.count];
    self.dataSource.items = chapters;
    [self.tableview reloadData];
    if (self.currentChapterIndex) {
        [self scrollToIndex: self.currentChapterIndex];
    }
}

/// 下载状态
- (void)setDownState:(MSYBookDownloadStatus)downState{
    _downState = downState;
    switch (downState) {
        case MSYBookNotDownload:
            [self setButtonTitle:@"下载整本(每天可免费下载3次,需观看视频)"];
            break;
        case MSYBookDownloaing:
        {
            [self setButtonTitle:@"  下载中..."];
        }
            break;
        case MSYBookSuspendDownload:
            [self setButtonTitle:@"  暂停中，点击继续下载"];
            break;
        case MSYBookSuccessDownloaded:
        {
            [self setButtonTitle:@"  下载完成"];
            //下载按钮不能点了
            self.downLoadBtn.userInteractionEnabled = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - 下载按钮
- (IBAction)downButtonClick:(UIButton *)sender {
    
    BOOL isCanDownLoadTheBook = [[MSYBookCache share] isCanDownloadBookWithBookid: self.bookId];
    if (!isCanDownLoadTheBook) {
        //不能下载,提示下载次数超过最大次了
        [ZJPAlert showAlertWithMessage:@"每天只可以免费下载三次" time:1.5];
        return;
    }
    
    //如果没有超过下载次数,看看当前小说是不是已经下载完成
	if (self.downState == MSYBookSuccessDownloaded) {
        // 下载完成
        [ZJPAlert showAlertWithMessage:@"小说已经下载完成" time:1.5];
		return;
	}
    
    //没网就不在下载了
	if (![ZJPNetWork netWorkAvailable]) {
		[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
		return;
	}
    
    //下载
    [self selectDownLoadBtn];
}

//MARK:下载按钮点击处理
- (void)selectDownLoadBtn {
    switch (self.downState) {
        case MSYBookNotDownload:
        {
             // 下载
            MSYBookCacheModel *model = [self getMSYBookCacheModel];
            [[MSYBookDownloadManager share] startDownloadBookWithModel: model];
            //展示视频广告
            if (self.clickDownloadBook) {
                self.clickDownloadBook();
            }
        }
            break;
        case MSYBookDownloaing:
        {
            // 暂停下载
            MSYBookCacheModel *model = [self getMSYBookCacheModel];
            [[MSYBookDownloadManager share] suspendedDownloadWithModel: model];
        }
            break;
        case MSYBookSuspendDownload:
        {
            // 重新开始下载
            MSYBookCacheModel *model = [self getMSYBookCacheModel];
            [[MSYBookDownloadManager share] restartDownloadWithModel: model];
        }
            break;
        case MSYBookSuccessDownloaded:
            [self.downLoadBtn setTitle:@"  已下载完成" forState: UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - MSYBookDownloadManagerDelegate
-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloaderStartDownload:(MSYBookDownloader *)bookDownloader {
    if ([bookDownloader.bookId isEqualToString: self.bookId]) {
        self.downState = MSYBookDownloaing;
    }
}

-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloaderSuspendDownload:(MSYBookDownloader *)bookDownloader {
    if ([bookDownloader.bookId isEqualToString: self.bookId]) {
        self.downState = MSYBookSuspendDownload;
    }
}

- (void)msyBookDownloadManager:(nonnull MSYBookDownloadManager *)manager bookDownloaderSuccessDownload:(nonnull MSYBookDownloader *)bookDownloader {
    
    if ([bookDownloader.bookId isEqualToString: self.bookId]) {
        self.downState = MSYBookSuccessDownloaded;
    }
}
- (void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloader:(MSYBookDownloader *)bookDownloader alreadyDownloadChapterCount:(NSInteger)alreadyDownloadCount totalChapterCount:(NSInteger)totalCount {
    if (self.downState != MSYBookDownloaing)
    {
        //在下载章节时,点击了暂停下载按钮
        //由于网络是异步执行的 主线程点击暂停按钮了,网络还在下载,还会走这里,所以当发现状态是暂停时,不能再去设置标题了
        return;
    }
    
    NSString *buttonTitle = [NSString stringWithFormat:@"  正在下载(%ld/%ld)",alreadyDownloadCount,totalCount];
    [self.downLoadBtn setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setButtonTitle:(NSString*)title {
    dispatch_async(dispatch_get_main_queue(), ^{//这里必须要在主线程操作
        [self.downLoadBtn setTitle:title forState:UIControlStateNormal];
    });
}

-(MSYBookCacheModel *)getMSYBookCacheModel {
    MSYBookCacheModel *model = [[MSYBookCacheModel alloc] init];
    model.bookId = self.bookId;
    model.cover = self.cover;
    model.bookName = self.bookName;
    model.lastChapter = self.lastChapter;
    model.majorCate = self.majorCate;
    model.author = self.author;
    model.updated = self.updated;
    return model;
}

#pragma mark -UI
- (void)configUI{
    
    self.bookNameL.textColor = [UIColor colorWithHexString: ADMenuSettingTextColor2];
    
    WeakSelf
    self.dataSource = [[ADTableViewDataSouce alloc] initWithItems: self.chapters cellIdentifier: idcell ConfigureCellBlock:^(ADMenuLeftCell *cell, ADChapterModel *item, NSIndexPath *indexpath) {
        StrongSelf
        cell.selectIndex = strongSelf.currentChapterIndex;
        cell.index = indexpath.row;
        cell.model = item;
    }];
    self.dataSource.rowHeight = 44;
    self.dataSource.delegate = self;
    self.tableview.dataSource = self.dataSource;
    self.tableview.delegate = self.dataSource;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.showsVerticalScrollIndicator = NO;
    [self.tableview registerNib:[UINib nibWithNibName:@"ADMenuLeftCell" bundle:nil] forCellReuseIdentifier:idcell];
    //MARK:滚动条
    self.tabHeight = [JPTool screenHeight]-self.topViewTopSpace.constant - self.downloadBtnHeight.constant-60;
    JPScrollBar *scrollBar = [[JPScrollBar alloc] initWithFrame:CGRectMake([JPTool screenWidth]-72-kJPscrollBarHeight, 60+self.topViewTopSpace.constant, kJPscrollBarHeight, self.tabHeight)];
    scrollBar.delegate = self;
    scrollBar.minBarHeight = kJPscrollBarHeight;
    scrollBar.barHeight = kJPscrollBarHeight;
    scrollBar.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollBar];
    _scrollBar = scrollBar;
}


- (void)show {
    self.hidden = NO;
    
    if ([MSYReaderSetting shareInstance].setting.dayModel) {
        self.backgroundColor = [UIColor whiteColor];
    }else{
        self.backgroundColor = [UIColor colorWithHexString: ADMenuSettingNightThem];
    }
    [self.tableview reloadData];
}

- (void)adTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.listSelect(indexPath.row, self.chapters[indexPath.row]);
    
}
-(void)adScrollViewDidScroll:(UIScrollView *)scrollview {
    if (_tableview.contentSize.height > self.tabHeight && _tableview.contentOffset.y + self.tabHeight > _tableview.contentSize.height - _scrollBar.barHeight) {
        if (scrollview.contentOffset.y > (scrollview.contentSize.height - _scrollBar.bounds.size.height)) {
            _scrollBar.yPosition = self.tabHeight-kJPscrollBarHeight;
            return;
        }
        _scrollBar.yPosition = (_scrollBar.bounds.size.height - _scrollBar.barHeight) * (scrollview.contentOffset.y) / (scrollview.contentSize.height - _scrollBar.bounds.size.height);
    }else{
        
        //更新滚动条位置
        _scrollBar.yPosition = (_scrollBar.bounds.size.height - _scrollBar.barHeight) * scrollview.contentOffset.y / (scrollview.contentSize.height - _scrollBar.bounds.size.height);
        if (scrollview.contentOffset.y < 0) {
            _scrollBar.yPosition = 0;
        }
    }
}
- (void)adScrollViewWillBeginDragging:(UIScrollView *)scrollview {//开始拖动
    if (_scrollBar.isHidden) {
        [_scrollBar show];
    } else {
        [_scrollBar cancelHideWithDelay];
    }
}
- (void)adScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {// 结束拖拽
        if (_scrollBar.isHidden == NO) {
            [_scrollBar hidden];
        }
    }
}
- (void)adScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_scrollBar.isHidden == NO) {//停止减速
        [_scrollBar hidden];
    }
}
#pragma mark - JPScrollBarDelegate
- (void)jpScrollBarTouchAction:(JPScrollBar *)scrollBar {
    [UIView animateWithDuration:scrollBar.barMoveDuration animations:^{
        [self->_tableview setContentOffset:CGPointMake(0, (self->_tableview.contentSize.height - self->_scrollBar.bounds.size.height) * scrollBar.yPosition / (self->_scrollBar.bounds.size.height - self->_scrollBar.barHeight))];
    }];
}
- (void)jpScrollBarDidScroll:(JPScrollBar *)scrollBar {
    [_tableview setContentOffset:CGPointMake(0, (_tableview.contentSize.height - _scrollBar.bounds.size.height) * scrollBar.yPosition / (_scrollBar.bounds.size.height - _scrollBar.barHeight))];
}

/// 点击章节
- (void)setCurrentChapterIndex:(NSInteger)currentChapterIndex{
    _currentChapterIndex = currentChapterIndex;
    if (_chapters) {
        [self.tableview reloadData];
        [self scrollToIndex: _currentChapterIndex];
    }
}

/// 滚动
- (void)scrollToIndex:(NSUInteger)index
{
    [self scrollToIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atPosition:UITableViewScrollPositionMiddle];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath atPosition:(UITableViewScrollPosition)position
{
    [self.tableview scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:NO];//这里一定要设置为NO，动画可能会影响到scrollerView，导致增加数据源之后，tableView到处乱跳
}

@end
