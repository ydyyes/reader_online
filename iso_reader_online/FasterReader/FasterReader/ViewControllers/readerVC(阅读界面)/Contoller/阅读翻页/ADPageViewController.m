	//
	//  ADPageViewController.m
	//  reader
	//
	//  Created by beequick on 2017/8/4.
	//  Copyright © 2017年 beequick. All rights reserved.
	//

#import "ADPageViewController.h"
#import "ADContentViewController.h"

#import "FasterReader-Swift.h"

#import "ADChapterContentModel.h"
#import "MSYReaderSetting.h"
#import "YYModel.h"

#import "ADSherfCache.h"
#import "MSYChapterCache.h"
#import "MSYBrowseHistoryCache.h"

#import "ADPageMenu.h"
#import "ADMenuLeftView.h"
#import "UIView+ZJP.h"
#import "BookMarkViewController.h" // 书签
#import "BannerAdView.h"

typedef void(^getChapter)(ADChapterContentModel *model);


typedef NS_ENUM(NSUInteger, MSYPageLoadFailType) {
    MSYPageLoadChaptersFail, // 加载章节列表失败
    MSYPageLoadChapterContentFail, // 加载章节内容失败
};



@interface ADPageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource,
ADPageMenuDelegate,ADBottomMenuDelegate,ADContentViewControllerDelegate,
UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPageViewController *readViewController;
@property (nonatomic, strong) ADContentViewController *currentPageController;
@property (nonatomic, strong) ADMenuLeftView *leftView;
@property (nonatomic, strong) MSYRewardedVideoAdModel *rewardedVideo;
@property (nonatomic, weak) ADPageMenu *pageMenu;
// 章节数量
@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) ADChapterContentModel *contentmodel;

/// 章节列表右边灰色蒙版，点击返回阅读页码
@property (nonatomic, strong) UIButton *listTapBackView;
@property (nonatomic, assign) BOOL isStatusBarHidden;

/** 章节标题 */
@property (nonatomic, copy) NSString *chapterTitle;

/** 没有数据 */
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIButton *maskViewBottom;
/// 加载失败
@property (nonatomic, weak) UIView *loadFailView;
@property (nonatomic, assign) MSYPageLoadFailType loadFailType;

@property (nonatomic, weak) BannerAdView *bannerAdView;

/// 只是统计总共有多少页,找到背面,初始值为1,是背面
@property (nonatomic, assign) NSUInteger tempNumber;

@end


@implementation ADPageViewController {
	NSInteger _pageType;// 翻页效果
	NSInteger _timeNow;// 记录时间
	NSUInteger _nextChapterIndex;//预加载
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: YES animated:NO];
   
    //隐藏状态栏
	self.isStatusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    //30分钟免广告
    if ([JPTool isThirtyMinuteMianAd]) {
        //当免三十分钟广告,存在了bannerAdView,就要移除它的所有子view
        [self.bannerAdView closeBannerAdView];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden: NO animated:YES];
}

//MARK:隐藏状态栏
- (BOOL)prefersStatusBarHidden{
	return self.isStatusBarHidden;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.tempNumber = 1;

	[self addChildViewController: self.readViewController];
	[self.view addSubview: self.readViewController.view];
	[self.view addSubview: self.leftView];
    
    //更新阅读时间
    BookCityBookModel *bookCityModel = [[BookCityBookModel alloc] init];
    bookCityModel.bookId = self.bookId;
    bookCityModel.cover = self.cover;
    bookCityModel.title = self.bookName;
    bookCityModel.lastChapter = self.lastChapter;
    bookCityModel.author = self.author;
    bookCityModel.majorCate = self.majorCate;
    bookCityModel.updated = self.updated;

    
    //更新书籍阅读时间
    [bookCityModel updated];
    //更新缓存
    [ADSherfCache UpdateWithBookInfo:bookCityModel];
    
    
    //添加到阅读记录
    MSYBrowseHistoryCacheModel *model = [[MSYBrowseHistoryCacheModel alloc] init];
    model.bookId = self.bookId;
    model.cover = self.cover;
    model.bookName = self.bookName;
    model.lastChapter = self.lastChapter;
    model.author = self.author;
    model.majorCate = self.majorCate;
    model.updated = self.updated;

    [[MSYBrowseHistoryCache share] addBookToBrowseHistory: model];
    // 添加
	[self.readViewController.view addSubview: self.listTapBackView];
    // 获取章节数据
    [self getBookAllChapters];
    //加载banner广告
    [self setUpBannerView];
    
    
    [MobClick event:@"book_read_activity" label:self.bookName];

}

#pragma mark -禁止滑动返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{

    return NO;
}

#pragma mark - 加载失败显示视图
- (void)showLoadFailViewWithFaileType: (MSYPageLoadFailType)type {

    [self removeLoadFailView];
    
    self.loadFailType = type;

	UIView *loadFailView = [[UIView alloc]initWithFrame:CGRectMake(0, StatusBarHeight+20, [JPTool screenWidth], [JPTool screenHeight])];
	loadFailView.backgroundColor = [UIColor colorWithHexString:[MSYReaderSetting shareInstance].setting.backGroundColor];
	[self.readViewController.view addSubview:loadFailView];
    self.loadFailView = loadFailView;
    
	UIView *failView = [[UIView alloc]initWithFrame:CGRectMake(0, 220*[JPTool HeightScale], [JPTool screenWidth], 300)];
	loadFailView.backgroundColor = [UIColor clearColor];
	[loadFailView addSubview:failView];

	UILabel *titleLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,  [JPTool screenWidth], 30)];
	titleLb.text = @"数据加载异常，请稍后重试";
	titleLb.textAlignment = NSTextAlignmentCenter;
	titleLb.textColor = [UIColor lightGary_999999];
	[failView addSubview:titleLb];

	_reloadButton = [[UIButton alloc]initWithFrame:CGRectMake(([JPTool screenWidth]-85)/2.0, titleLb.bottom+25, 100, 30)];
	[_reloadButton setTitle:@" 点击重试 " forState:UIControlStateNormal];
	[_reloadButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
	[_reloadButton setBackgroundColor:[UIColor mainBlue_2F94F9]];
	[_reloadButton addTarget:self action:@selector(retryLoad:) forControlEvents:UIControlEventTouchUpInside];
	[failView addSubview:_reloadButton];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
	[loadFailView addGestureRecognizer:tap];
}

- (void)retryLoad:(UIButton*)sender {
    NSLog(@"重试被点击");
    switch (self.loadFailType) {
        case MSYPageLoadChaptersFail:
            [self getBookAllChapters];
            break;
        case MSYPageLoadChapterContentFail:
        {
            NSUInteger chapterIndex = self.currentPageController.chapterIndex;
            [self getChapterData: chapterIndex];
        }
            break;
    }
}

- (void)removeLoadFailView {
    [self.loadFailView removeAllSubviews];
    [self.loadFailView removeFromSuperview];
}

//MARK:网络 请求章节内容
/// 获取章节数量
- (void)getBookAllChapters {

	self.chapters = [MSYChapterCache getBookAllChaptersWithBookid: self.bookId];
    
    //MARK:获取阅读记录
    MSYBrowseHistoryCacheModel *cacheBookModel = [[MSYBrowseHistoryCache share] queryReadHistoryWithBookId:self.bookId];
    NSUInteger chapterIndex = cacheBookModel.chapterIndex;
    NSUInteger pageIndex = cacheBookModel.pageIndex;
    
	if (self.chapters.count > 0) {
		self.leftView.chapters = self.chapters;
		[self loadContentPageVc:self.currentPageController AtChapter: chapterIndex AtPageIndex: pageIndex];
	}else{
		NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":[JPTool USER_TOKEN],@"id":self.bookId}];
		if (![ZJPNetWork netWorkAvailable]) {
            
            [self showLoadFailViewWithFaileType: MSYPageLoadChaptersFail];
            
			[ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
			return;
		}
        
        [[ZJPAlert shareAlert] showLoding];
		@WeakObj(self);
		[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBookChapterLtPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {

            [[ZJPAlert shareAlert] hiddenHUD];

			NSArray *chapters = [NSArray yy_modelArrayWithClass:[ADChapterModel class] json:responseObject[@"data"]];
			if (chapters.count == 0) {
				[self.navigationController popViewControllerAnimated:YES];
				[ZJPAlert showAlertWithMessage:@"章节不存在或小说已下架" time:2.5];
			}else{
                //添加到缓存
                [MSYChapterCache cachedBookAllChapters:chapters withBookid: selfWeak.bookId];
				selfWeak.chapters = [chapters copy];
				selfWeak.leftView.chapters = selfWeak.chapters;
				selfWeak.leftView.currentChapterIndex = chapterIndex;
				[selfWeak loadContentPageVc:selfWeak.currentPageController AtChapter: chapterIndex AtPageIndex: pageIndex];
			}

		} WithFailurBlock:^(NSError *error) {
            [self showLoadFailViewWithFaileType: MSYPageLoadChaptersFail];
			[[ZJPAlert shareAlert] hiddenHUD];
		}];

	}
}

// 加载章节内容
- (void)loadContentPageVc:(ADContentViewController *)pageViewController AtChapter:(NSUInteger)chapterIndex AtPageIndex:(NSUInteger)pageIndex{

    WeakSelf
	[self loadChapter: chapterIndex complete:^(ADChapterContentModel *model) {
        StrongSelf
		pageViewController.model = strongSelf.contentmodel;
		pageViewController.pageIndex = pageIndex;
        pageViewController.chapterIndex = chapterIndex;
		[pageViewController reloadData];
		strongSelf.currentPageController = pageViewController;
        
        [strongSelf removeLoadFailView];
        
		if (chapterIndex != strongSelf.chapters.count - 1) {
			[strongSelf getContentModel: chapterIndex + 1];
		}
	}];

}

// 加载内容
- (void)loadChapter:(NSUInteger)chapterIndex complete:(getChapter)complete {
    
    self.leftView.currentChapterIndex = chapterIndex;
    ADChapterModel *chapter = self.chapters[chapterIndex];
    self.chapterTitle = chapter.title;
    [self.pageMenu setChapterTitle: chapter.title];
    self.pageMenu.bottomMenu.userInteractionEnabled = NO;
    
    NSString *chapterNum = [NSString stringWithFormat:@"%lu",(unsigned long)chapterIndex];
    // 缓存的章节内容
    ADChapterContentModel *contentModel = [[MSYChapterCache share] getBookChapterContentWithChapterNum:chapterNum bookid:self.bookId];
    if (contentModel.body.length > 4 ) {
        ADChapterContentModel *model = [self getChapterChapterIndex: chapterIndex content: contentModel.body];
        complete(model);
    }else{
        if (![ZJPNetWork netWorkAvailable]) {
            //无网络
            [[ZJPAlert shareAlert] hiddenHUD];
            [ZJPAlert showAlertWithMessage: [JPTool NoNetWorkAlert] time:1.5];
            self.pageMenu.bottomMenu.userInteractionEnabled = YES;
            [self showLoadFailViewWithFaileType: MSYPageLoadChapterContentFail];
            ADChapterContentModel *model = [self getChapterChapterIndex: chapterIndex content: @"暂无数据"];
            complete(model);
            return;
        }
        
        [[ZJPAlert shareAlert] showLoding];
        // 不存在就请求
        NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"label":chapter.label,@"id":self.bookId}];
        WeakSelf
        [[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBookChapterInPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
            StrongSelf
            
            NSString *url = responseObject[@"data"][@"url"];
            if (url && ![url isEqualToString:@""]) {
                [[JPNetWork sharedManager] requestGetContentWithPathUrl:url Success:^(NSString *responseObject) {
                    StrongSelf

                    [[ZJPAlert shareAlert] hiddenHUD];

                    ADChapterContentModel *model = [strongSelf getChapterChapterIndex: chapterIndex content: responseObject];
                    [[MSYChapterCache share] cachedBookChapterContent: model];
                    complete(model);
                    
                } failure:^(NSError *error) {
                    StrongSelf
                    
                    [[ZJPAlert shareAlert] hiddenHUD];

                    strongSelf.pageMenu.bottomMenu.userInteractionEnabled = YES;
                    [strongSelf showLoadFailViewWithFaileType: MSYPageLoadChapterContentFail];
                    ADChapterContentModel *model = [strongSelf getChapterChapterIndex: chapterIndex content: @"暂无数据"];
                    complete(model);
                }];
            }else{
                [[ZJPAlert shareAlert] hiddenHUD];
                ADChapterContentModel *model = [strongSelf getChapterChapterIndex: chapterIndex content: @"暂无数据"];
                complete(model);
            }
        } WithFailurBlock:^(NSError *error) {
            StrongSelf
            [[ZJPAlert shareAlert] hiddenHUD];

            strongSelf.pageMenu.bottomMenu.userInteractionEnabled = YES;
            [strongSelf showLoadFailViewWithFaileType: MSYPageLoadChapterContentFail];
            ADChapterContentModel *model = [strongSelf getChapterChapterIndex: chapterIndex content: @"暂无数据"];
            complete(model);
        }];
    }
    
}

/// 把小说内容封装成model
- (ADChapterContentModel*)getChapterChapterIndex:(NSUInteger)chapterIndex content:(NSString*)content {

    self.pageMenu.bottomMenu.userInteractionEnabled = YES;

    //首行缩进
    NSMutableString *result = content.mutableCopy;
    if (![result hasPrefix:@" "]) {
        [result insertString: @"      " atIndex:0];
    }
    NSString *resurlString = [result stringByReplacingOccurrencesOfString:@"\n" withString:@"\n      "];
    
	ADChapterContentModel *model = [[ADChapterContentModel alloc]init];
    // 小说内容
	model.body = resurlString;
	model.chapterNum = chapterIndex;
    model.cover = self.cover;
    model.bookName = self.bookName;
	model.title = self.chapterTitle;
    model.bookId = self.bookId;
    

    //赋值
    self.contentmodel = model;

	return model;
}

#pragma mark - 预加载章节内容
/** 预加载章节内容 */
- (void)getContentModel:(NSUInteger)chapterIndex {

	ADChapterModel *chapter = self.chapters[chapterIndex];
	NSString *chapterTitle = chapter.title;
	NSString *chapterNum = [NSString stringWithFormat:@"%lu",(unsigned long)chapterIndex];// 缓存
    ADChapterContentModel *contentModel = [[MSYChapterCache share] getBookChapterContentWithChapterNum:chapterNum bookid:self.bookId];
	if (contentModel.body.length > 4 ) {
		return;
	}else{
		if (![ZJPNetWork netWorkAvailable]) {
			return;
		}else{
			NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc]initWithDictionary:@{@"label":chapter.label,@"id":self.bookId}];
            WeakSelf
			[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBookChapterInPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
                StrongSelf
				NSString *url = responseObject[@"data"][@"url"];
				if (url && ![url isEqualToString:@""]) {
					[[JPNetWork sharedManager] requestGetContentWithPathUrl:url Success:^(id responseObject) {
						responseObject = [responseObject stringByReplacingOccurrencesOfString:@"\n" withString:@"\n      "];//首行缩进
						ADChapterContentModel *model = [[ADChapterContentModel alloc] init];//[self getChapterContent:responseObject];
						model.body = responseObject;
						model.title = chapterTitle;
						model.chapterNum = chapterIndex;
						model.bookId = strongSelf.bookId;
                        [[MSYChapterCache share] cachedBookChapterContent: model];
                        //NSLog(@"预加载成功:%@",model.body);
					} failure:^(NSError *error) {
					}];
				}else{
						//	ADChapterContentModel *model = [self getChapterContent:@"暂无数据"];
				}

			} WithFailurBlock:^(NSError *error) {
			}];
		}
	}

}

#pragma mark - delegate && datasource
	//MARK:上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{

    //在手势开始时的viewcontroller(也就是在屏幕上显示的那个controller)的index
    NSUInteger pageIndex;
    NSUInteger chapterIndex;
    if ([viewController isKindOfClass: [ADContentViewController class]]) {
        ADContentViewController *c = (ADContentViewController *)viewController;
        pageIndex = c.pageIndex;
        chapterIndex = c.chapterIndex;
    }else {
        MSYReadContentBGController *c = (MSYReadContentBGController *)viewController;
        pageIndex = c.pageIndex;
        chapterIndex = c.chapterIndex;
    }
    
    //如果是第一页,并且 chapterIndex = 0(第一章)的话,直接返回
    if (pageIndex == 0 && chapterIndex == 0) {
        [ZJPAlert showAlertWithMessage:@"当前已是第一页" time:1.0];
        return nil;
    }
    
    // 翻页累计
    self.tempNumber -= 1;
    if (self.tempNumber % 2 == 0) { // 背面
        //如果是背面的话,背面的页码就等于当前显示的页码,这样下一页正文的页码就+1就行,简化处理
        MSYReadContentBGController *c = [[MSYReadContentBGController alloc] init];
        c.pageIndex = pageIndex;
        c.chapterIndex = chapterIndex;
        
        NSString *backGroundColor = [MSYReaderSetting shareInstance].setting.backGroundColor;
        c.view.backgroundColor = [[UIColor colorWithHexString: backGroundColor] colorWithAlphaComponent: 0.95];
        return c;
    }
    
    if (pageIndex == 0) {
        //已经是第一页了,切换到上一章
        chapterIndex -= 1;
        _nextChapterIndex = chapterIndex > 0 ? chapterIndex - 1 : chapterIndex;
        ADContentViewController *page = [self viewControllerAtChapter:chapterIndex page:pageIndex];
        
        dispatch_semaphore_t signal = dispatch_semaphore_create(1);
        [self loadChapter: chapterIndex complete:^(ADChapterContentModel *model) {
            page.pageIndex = model.pageCount - 1;
            page.chapterIndex = chapterIndex;
            page.model = model;
            self.currentPageController = page;
            [page reloadData];

            [self removeLoadFailView];
            
            [[ZJPAlert shareAlert] hiddenHUD];
            [self getContentModel:self->_nextChapterIndex];
            dispatch_semaphore_signal(signal);
        }];
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        return page;
    }
    
    //当前章节的其他页
    pageIndex -= 1;
    ADContentViewController *page = [self viewControllerAtChapter:chapterIndex page:pageIndex];
    self.currentPageController = page;
    return page;

}
	//MARK:下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{

    if (self.chapters.count == 0)
    {
        //章节数为0
        if (![ZJPNetWork netWorkAvailable])
        {
            //没有数据
            [ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
            return nil;
        }
        return nil;
    }
    
    //上一个viewcontroller的index
    NSUInteger pageIndex;
    NSUInteger chapterIndex;
    BOOL isHaveEnoughSpaceToShowAd = NO;
    
    if ([viewController isKindOfClass: [ADContentViewController class]])
    {
        ADContentViewController *contentController = (ADContentViewController *)viewController;
        pageIndex = contentController.pageIndex;
        chapterIndex = contentController.chapterIndex;
        isHaveEnoughSpaceToShowAd = contentController.isHaveEnoughSpaceToShowAd;
    }
    else if ([viewController isKindOfClass: [MSYReadContentBGController class]])
    {
        MSYReadContentBGController *bgController = (MSYReadContentBGController *)viewController;
        pageIndex = bgController.pageIndex;
        chapterIndex = bgController.chapterIndex;
        isHaveEnoughSpaceToShowAd = bgController.isHaveEnoughSpaceToShowAd;
    }
    else
    {
        MSYReadPageADController *pageAD = (MSYReadPageADController *)viewController;
        pageIndex = pageAD.pageIndex;
        chapterIndex = pageAD.chapterIndex;
    }

    /** 如何判断页码是不是章节的最后一页? */
    //第一种: 只要是30分钟免广告,就一定不需要广告页, self.contentmodel.pageCount - 1 为本章的最后一页
    //第二种: 当不需要有广告页的话(即每章节最后一页的空间足够展示章节末尾广告) self.contentmodel.pageCount - 1 为本章的最后一页
    //第三种: 当需要有广告页的话(即每章节最后一页的空间不够展示章节末尾广告) self.contentmodel.pageCount 为本章的最后一页
    //(因为每一章结束,当最后一页空间不够展示章节末尾广告的话,都会插入一页广告页,就相当于每章多增加了一页)
    BOOL isMianGuangGao = [JPTool isThirtyMinuteMianAd];
    NSUInteger lastPageIndex = isMianGuangGao ? self.contentmodel.pageCount - 1 : self.contentmodel.pageCount;
    
    if (isMianGuangGao || isHaveEnoughSpaceToShowAd) {
        //当免广告或者每章节最后一页的空间足够展示章节末尾广告
        lastPageIndex = self.contentmodel.pageCount - 1;
    }else {
        //每章节最后一页的空间不够展示章节末尾广告
        lastPageIndex = self.contentmodel.pageCount;
    }
    
    //如果是最后一页,且是最后一章,小说已经看完了,就返回nil,tempNumber不在+1,
    if ( (pageIndex == lastPageIndex) && (chapterIndex >= self.chapters.count - 1) )
    {
        [ZJPAlert showAlertWithMessage:@"当前已是最后一章" time:1.0];
        return nil;
    }
    
    // 翻页累计
    self.tempNumber += 1;
    
    //如果是背面的话,背面的页码就等于上一页的页码,这样下一页正文的页码就+1就行,简化处理
    if (self.tempNumber % 2 == 0) {
        MSYReadContentBGController *bgController = [[MSYReadContentBGController alloc] init];
        bgController.pageIndex = pageIndex;
        bgController.chapterIndex = chapterIndex;
        bgController.isHaveEnoughSpaceToShowAd = isHaveEnoughSpaceToShowAd;
        return bgController;
    }
    
    //准备要看下一页,所以此处页码要+1
    pageIndex += 1;
    
    if (pageIndex == lastPageIndex && !isMianGuangGao && !isHaveEnoughSpaceToShowAd) {
        //要看的页码,等于当前章节的总页码,并且没有免广告的话,并且章节末尾没有空间去展示章节末尾广告了,需要插入广告页)
        MSYReadPageADController *pageAd = [[MSYReadPageADController alloc] init];
        pageAd.pageIndex = pageIndex;
        pageAd.chapterIndex = chapterIndex;
        pageAd.chapterTitle = self.contentmodel.title;

        return pageAd;
    }
    else if (pageIndex > lastPageIndex)
    {
        //看下一章
        //要看的页码,大于当前章节的总页码(为什么没有等于,因为多了一个广告页,所以必须大于)
        //已经看到最后加的一页广告页面过来,所以要看下一章
        chapterIndex += 1;
        pageIndex = 0;
        
        _nextChapterIndex = chapterIndex < self.chapters.count - 1 ? chapterIndex + 1 : chapterIndex;

        ADContentViewController *page = [self viewControllerAtChapter: chapterIndex page: pageIndex];

        dispatch_semaphore_t signal = dispatch_semaphore_create(1);
        [self loadChapter: chapterIndex complete:^(ADChapterContentModel *model) {
            
            [[ZJPAlert shareAlert] hiddenHUD];
            [self removeLoadFailView];
            
            page.model = model;
            [page reloadData];
            self.currentPageController = page;

            [self getContentModel:self->_nextChapterIndex];
            
            dispatch_semaphore_signal(signal);
        }];
        
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        
        return page;
    }
    else
    {
        ADContentViewController *page = [self viewControllerAtChapter: chapterIndex page: pageIndex];
        self.currentPageController = page;
        return page;
    }
}
#pragma mark - 翻页完成代理方法
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{

	if(completed) {
        //展示广告
        [self loadAdAndShow];
    }else {
        // 翻页没有完成会消失，得再添加一遍
        [self.readViewController.view addSubview: self.listTapBackView];
    }
}

- (void)setUpBannerView {
    BannerAdView *bannerAdView  = [[BannerAdView alloc] initWithFrame: CGRectMake(0, [JPTool screenHeight] - kReaderBannerAdHeight, [JPTool screenWidth], kReaderBannerAdHeight)];
    //_bannerAdView.backgroundColor = [UIColor redColor];
    [self.view addSubview: bannerAdView];
    self.bannerAdView = bannerAdView;
}
- (void)loadAdAndShow {
    //type = 0 不展示广告,返回
    NSString *type = [JPTool showBannerAD];
    if ([type isEqualToString:@"0"]) {
        return;
    }
    [self.bannerAdView showBannerAdViewWithType:type InController: self];
}

#pragma mark  - ***** 弹出菜单的代理 Delegate **************
	//MARK:返回按钮
- (void)goBack {
		//MARK: 小说是否存在
	if ([ADSherfCache queryWithBookId: self.bookId]) {
		[self.navigationController popViewControllerAnimated:YES];
	}else{
        WeakSelf
		[[SureCanceAlert shareAlert] setTitleText:@"是否加入到书架" withSureBtnTitle:@"确定" withMaxHeight:100 withAlertStyle:(AlertButtonTypeStyleDefault) withSureBtnClick:^(UIButton *sender) {

            BookCityBookModel *bookModel = [[BookCityBookModel alloc] init];
            bookModel.bookId = weakSelf.bookId;
            bookModel.title = weakSelf.bookName;
            bookModel.cover = weakSelf.cover;
            bookModel.lastChapter = weakSelf.lastChapter;
            bookModel.author = weakSelf.author;
            bookModel.majorCate = weakSelf.majorCate;
            bookModel.updated = weakSelf.updated;

            
			[ADSherfCache addBook: bookModel];
			[weakSelf.navigationController popViewControllerAnimated:YES];

		} withCancelBtnClick:^(UIButton *sender) {
			[weakSelf.navigationController popViewControllerAnimated:YES];
		}];
	}
}

- (long long)getDateTimeTOMilliSeconds:(NSDate *)datetime {
	NSTimeInterval interval = [datetime timeIntervalSince1970];
		//	NSLog(@"转换的时间戳=%f",interval);
	long long totalMilliseconds = interval*1000 ;
		//	NSLog(@"totalMilliseconds=%llu",totalMilliseconds);
	return totalMilliseconds;
}

#pragma mark - ADContentViewController创建
- (ADContentViewController *)viewControllerAtChapter:(NSUInteger)chapterIndex page:(NSInteger)pageIndex{
    ADContentViewController *page = [[ADContentViewController alloc] init];
    page.pageIndex = pageIndex;
    page.chapterIndex = chapterIndex;
    page.model = self.contentmodel;
    page.delegate = self;
    return page;
}

#pragma mark -ADContentViewControllerDelegate 显示底部工具栏
-(void)readContentControllerShouldMenuView:(ADContentViewController *)controller {
    [self showMenu];
}

#pragma mark - 底部工具栏-阅读设置view-ADPageMenuView
- (void)showMenu {
    ADPageMenu *pageMenuView = [ADPageMenu pageMenu];
    pageMenuView.delegate = self;
    pageMenuView.bottomMenu.bottomDelegate = self;
    pageMenuView.bottomMenu.maxValue = self.chapters.count;//最多章节数量
    pageMenuView.bottomMenu.currentValue = self.currentPageController.chapterIndex;
    WeakSelf
    [pageMenuView showMenuInView: self.view show:^{
        StrongSelf
        strongSelf.isStatusBarHidden = NO;
        [strongSelf setNeedsStatusBarAppearanceUpdate];
    } dismiss:^{
        StrongSelf
        strongSelf.isStatusBarHidden = YES;
        [strongSelf setNeedsStatusBarAppearanceUpdate];
    }];
    self.pageMenu = pageMenuView;
    [pageMenuView setChapterTitle: self.chapterTitle];
}

#pragma mark - ADBottomMenuDelegate
/// 上一章 下一章  按钮事件
- (void)bottomMenuViewChapterChanged:(ChapterActionType)actionType{
    NSUInteger chapterIndex = self.currentPageController.chapterIndex;
    //下一章
    if (actionType == ChapterActionTypeNext)
    {
        if (self.chapters.count > 0)
        {
            if (chapterIndex >= self.chapters.count - 1)
            {
                [ZJPAlert showAlertWithMessage:@"当前已是最后一章" time:1.0];
                return;
            }
            else
            {
                chapterIndex += 1;
                _nextChapterIndex = chapterIndex < self.chapters.count-1 ? chapterIndex + 1 : chapterIndex;
            }
        }
        else
        {
            if (![ZJPNetWork netWorkAvailable])
            {
                //没有数据
                [ZJPAlert showAlertWithMessage:[JPTool NoNetWorkAlert] time:1.5];
                return;
            }
        }
    }
    //上一章
    else if (actionType == ChapterActionTypePre)
    {
        if (chapterIndex > 0)
        {
            chapterIndex -= 1;
            _nextChapterIndex = chapterIndex > 1 ? chapterIndex - 1 : chapterIndex;
        }
        else
        {
            [ZJPAlert showAlertWithMessage:@"当前已是第一章" time:1.0];
            return;
        }
    }
    self.pageMenu.bottomMenu.currentValue = chapterIndex;
    // 获取章节内容
    [self getChapterData: chapterIndex];
}

/// bottomMenuView按钮点击
- (void)bottomMenuViewActionButtonClicked:(TapActionType)actionType {
    
    switch (actionType) {
        case TapActionTypeChapters:
            [self showChapterList];
            break;
        case TapActionTypeSetting:
            [self.pageMenu showSettingMenuView];
            break;
        case TapActionTypeDayOrNight:
        {
            [self.pageMenu dismissWithAnimate: NO];
        }
            break;
        default:
            break;
    }
}

/// 拖动章节进度条
- (void)bottomMenuViewSliderChanged:(NSUInteger)value{
    //为什么是value - 1? ?????
    [self getChapterData:value - 1];
}

#pragma mark - 获取章节内容
- (void)getChapterData:(NSUInteger)chapterIndex {
    WeakSelf
    [self loadChapter: chapterIndex complete:^(ADChapterContentModel *model) {
        StrongSelf
        strongSelf.currentPageController.pageIndex = 0;
        strongSelf.currentPageController.chapterIndex = chapterIndex;
        strongSelf.currentPageController.model = model;
        [strongSelf.currentPageController reloadData];
        /// 解决目录跳转 还是显示上一章的内容
        NSArray *array = [NSArray arrayWithObjects:strongSelf.currentPageController, nil];// 重新加载第一页
        [strongSelf.readViewController setViewControllers:array direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        }];
        
        if (model.body.length > 4)
        {
            [strongSelf removeLoadFailView];
            
            [strongSelf getContentModel: strongSelf->_nextChapterIndex];
        }
    }];
}

#pragma mark - 侧边栏-书籍目录-显示隐藏
///  左侧目录列表视图
- (void)showChapterList {
    self.bannerAdView.hidden = YES;
    self.maskViewBottom.hidden = YES;
    self.listTapBackView.hidden = NO;
    [self.pageMenu dismissWithAnimate: NO];
    
    [self.leftView show];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.leftView.tx = leftViewWidth();
        self.readViewController.view.tx = leftViewWidth();
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetLeftView {
    [UIView animateWithDuration:0.2 animations:^{
        self.leftView.transform = CGAffineTransformIdentity;
        self.readViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.leftView.hidden = YES;
        self.listTapBackView.hidden = YES;
        
        self.maskViewBottom.hidden = NO;
        self.bannerAdView.hidden = NO;
    }];
}

- (UIButton *)listTapBackView {
	if (!_listTapBackView) {
        _listTapBackView = [UIButton buttonWithType: UIButtonTypeCustom];
        _listTapBackView.frame = CGRectMake(0, 0, [JPTool screenWidth], [JPTool screenHeight]);
		_listTapBackView.backgroundColor = [UIColor darkGrayColor];
		_listTapBackView.alpha = 0.6;
        [_listTapBackView addTarget:self action:@selector(resetLeftView) forControlEvents:UIControlEventTouchUpInside];
		_listTapBackView.hidden = YES;
	}
	return _listTapBackView;
}

- (ADMenuLeftView *)leftView{
	if (!_leftView) {
		_leftView = [ADMenuLeftView leftView];
		_leftView.frame = CGRectMake(-leftViewWidth(), 0, leftViewWidth(), [JPTool screenHeight]);
		_leftView.hidden = YES;
		_leftView.bookName = self.bookName;
        _leftView.cover = self.cover;
		_leftView.bookId = self.bookId;
        _leftView.lastChapter = self.lastChapter;
        _leftView.author = self.author;
        _leftView.majorCate = self.majorCate;
        _leftView.updated = self.updated;

		__weak typeof(self) weakSelf = self;
		_leftView.listSelect = ^(NSUInteger chapterIndex, ADChapterModel *model) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
			if (chapterIndex != strongSelf.currentPageController.chapterIndex) {
                //重设leftView
				[strongSelf resetLeftView];
                //获取这一章的数据
				[strongSelf getChapterData: chapterIndex];
			}else{
				NSLog(@"相同章节");
			}
		};
        
        _leftView.clickDownloadBook = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.rewardedVideo = [[MSYRewardedVideoAdModel alloc] initWithNavigationController:strongSelf.navigationController];
            [strongSelf.rewardedVideo loadRewardAd];
        };
	}
	return _leftView;
}

///  初始化pageController
- (UIPageViewController *)readViewController{
    
    if (!_readViewController) {
        // 设置翻页效果
        NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(0)};
        
        UIPageViewControllerTransitionStyle pageStyle = UIPageViewControllerTransitionStylePageCurl;
        NSDictionary *dict =  [[NSUserDefaults standardUserDefaults] objectForKey:@"readTypeDict"];//用户设置的翻页效果
        NSString *indexStrng = dict?dict[@"index"]:@"0";//默认为仿真
        _pageType = [indexStrng integerValue];
        if (_pageType == 0) {
            pageStyle = UIPageViewControllerTransitionStylePageCurl;// 仿真
            //            options   = @{UIPageViewControllerOptionSpineLocationKey:@0,UIPageViewControllerOptionInterPageSpacingKey:@0};
        }else{
            pageStyle = UIPageViewControllerTransitionStyleScroll;// 滑动
            //            options   = @{UIPageViewControllerOptionSpineLocationKey:@0,UIPageViewControllerOptionInterPageSpacingKey : @(0)};
        }
        _readViewController = [[UIPageViewController alloc] initWithTransitionStyle:pageStyle navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal options:options];
        _readViewController.doubleSided = YES;
        _readViewController.dataSource = self;
        _readViewController.delegate = self;
        
        ADContentViewController *page_fir = [self viewControllerAtChapter: 0 page: 0];
        self.currentPageController = page_fir;
        @WeakObj(self);
        NSArray *array = [NSArray arrayWithObjects: self.currentPageController, nil];
        [_readViewController setViewControllers: array direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
            if(finished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfWeak.readViewController setViewControllers:array direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];// bug fix for uipageview controller
                });
            }
            
        }];
        _readViewController.view.frame = self.view.bounds;
    }
    return _readViewController;
}


static inline CGFloat leftViewWidth() {
	return [JPTool screenWidth]-72;
}

@end
