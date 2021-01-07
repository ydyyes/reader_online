//
//  MSYBookDownloader.m
//  FasterReader
//
//  Created by apple on 2019/7/6.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "MSYBookDownloader.h"

@interface MSYBookDownloader()

@property (nonatomic, strong) NSArray <ADChapterModel *> *chapters;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation MSYBookDownloader

- (void)setBookId:(NSString *)bookId {
    _bookId = [bookId copy];
    self.chapters = [MSYChapterCache getBookAllChaptersWithBookid: bookId];
}

//MARK:下载
- (void)downloadBookChapters{
    
    //如果已经有下载的直接返回
    if (self.queue.operationCount > 0)
    {
        return;
    }

    [self.delegate msyBookDownloaderStartDownload: self];
    
    self.queue.maxConcurrentOperationCount = 3;
    
    WeakSelf
    for (int i = 0; i < self.chapters.count ; i++) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            StrongSelf
            [strongSelf.queue addOperationWithBlock:^{
                StrongSelf
//                NSLog(@"当前需要下载%d章节,当前线程:%@",i,[NSThread currentThread]);
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                [strongSelf downLoadContentModelWithchapterIndex:i sema:sema];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//                NSLog(@"当前需要下载%d章节,当前这一个任务执行完毕了,当前线程:%@",i,[NSThread currentThread]);
            }];
        });
    }
}

//MARK:暂停下载
- (void)suspendedDownload {
    NSLog(@"暂停下载");
    //判断队列中是否有操作
    if (self.queue.operationCount == 0) {
        //operationCount为0,而且状态还是下载中?,上次下载的时候app退出,或别的异常情况
        //或者下载过程中有的章节下载失败跳过了,导致operation为0时,进度并不是100%等异常情况,
        //从而导致状态在上次queue结束后没有更改.
#warning 所以还需要在下载那个方法里(或者用kvo),监听当操作数为0时,是否已经全部下载成功了,这里临时做个处理!!!!! TODO
        NSMutableArray *bookCachedChapters = (NSMutableArray*)[MSYChapterCache getBookDownloadChapterCount: self.bookId];
        //queue中没有操作,说明不是从暂停下载过来的,所以是从重启app,或别的异常情况
        if (self.chapters.count == bookCachedChapters.count)
        {
            //判断已经下载完了
            [self.delegate msyBookDownloaderSuccessDownload: self];
        }
        else
        {
            [self.delegate msyBookDownloaderSuspendDownload: self];
            NSLog(@"queue中没有操作,说明不是从暂停下载过来的,所以是从重启app,或别的异常情况,且上一次的状态是:MSYBookDownloaing");
        }
        return;
    }
    
    //如果没有被挂起，才需要暂停设置yes
    if(!self.queue.isSuspended){
        [self.queue setSuspended:YES];
    }
    [self.delegate msyBookDownloaderSuspendDownload: self];
}

//MARK:重新又开始下载
- (void)restartDownload {
    NSLog(@"暂停后又重新开始下载");
    //查看已经缓存(一章一章观看或者已经下载)的章节
    NSMutableArray *bookCachedChapters = (NSMutableArray*)[MSYChapterCache getBookDownloadChapterCount: self.bookId];
    
    //判断队列中是否有操作
    if (self.queue.operationCount == 0)
    {
        //queue中没有操作,不是从暂停下载过来的,所以是从重启app或者别的异常情况
        if (self.chapters.count == bookCachedChapters.count)
        {
            //判断是否已经下载完了
            [self.delegate msyBookDownloaderSuccessDownload: self];
        }
        else
        {
            //没有下载完,所以要从头开始过滤没有i下载的章节进行下载
            [self downloadBookChapters];
            NSLog(@"queue中没有操作,不是从暂停下载过来的,所以是从重启app或者别的异常情况" );
        }
        return;
    }
    
    //如果挂起,设置暂停NO
    if (self.queue.isSuspended)
    {
        if (self.chapters.count == bookCachedChapters.count)
        {
            [self.delegate msyBookDownloaderSuccessDownload: self];
            //下载完成了
            [self.queue cancelAllOperations];
        }
        else
        {
            [self.delegate msyBookDownloaderStartDownload: self];
            
            [self.queue setSuspended:NO];
        }
    }
}

#pragma mark -加载章节内容
- (void)downLoadContentModelWithchapterIndex:(NSInteger)chapterIndex sema:(dispatch_semaphore_t)sema{
    
    NSString *chapterNum = [NSString stringWithFormat:@"%ld",chapterIndex];
    // 看看有没有已经缓存的章节
    ADChapterContentModel *contentModel = [[MSYChapterCache share] getBookChapterContentWithChapterNum:chapterNum bookid:self.bookId];
    
    if (contentModel.body.length > 4 )
    {
//        NSLog(@"本地已经缓存有第%lu章节,直接返回,当前线程:%@,当前剩余操作数%lu",chapterIndex,[NSThread currentThread], self.queue.operationCount);
        //本地已经缓存有该章节,直接返回
        dispatch_semaphore_signal(sema);
        return;
    }
    else
    {
        if (![ZJPNetWork netWorkAvailable])
        {
            //没网,直接返回
            dispatch_async(dispatch_get_main_queue(), ^{
                //这里必须要在主线程操作
                [self.delegate msyBookDownloaderSuspendDownload: self];
                // 暂停任务
                [self.queue setSuspended:YES];
            });
            dispatch_semaphore_signal(sema);
        }
        else
        {
            // 请求网络下载章节
            ADChapterModel *chapter = self.chapters[chapterIndex];
            NSMutableDictionary *paramsDict = @{@"label":chapter.label,@"id":self.bookId}.mutableCopy;
            WeakSelf
            [[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool BookshelfBookChapterInPath] WithParamsDict:paramsDict WithSuccessBlock:^(id responseObject) {
                NSString *url = responseObject[@"data"][@"url"];
                StrongSelf
                if (url && ![url isEqualToString:@""])
                {
                    //成功获得下载链接
                    [strongSelf startDowLoadWithUrl:url chapterIndex:chapterIndex sema:sema];
                }
                else
                {
                    //没有获得下载链接,直接释放信号量
                    dispatch_semaphore_signal(sema);
                }
            } WithFailurBlock:^(NSError *error) {
                //请求失败,直接释放信号量
                dispatch_semaphore_signal(sema);
            }];
        }
    }
}

- (void)startDowLoadWithUrl:(NSString *)url chapterIndex:(NSInteger)chapterIndex sema:(dispatch_semaphore_t)sema{
    WeakSelf
    [[JPNetWork sharedManager] requestGetContentWithPathUrl:url Success:^(id responseObject) {
        StrongSelf
        [strongSelf dowLoadSuccessWithChapterIndex:chapterIndex content:responseObject sema: sema];
    } failure:^(NSError *error) {
        //请求失败,直接释放信号量
        dispatch_semaphore_signal(sema);
    }];
}

- (void)dowLoadSuccessWithChapterIndex:(NSInteger)chapterIndex content:(NSString *)content sema:(dispatch_semaphore_t)sema{
    
    ADChapterModel *chapter = self.chapters[chapterIndex];
    NSString *chapterTitle = chapter.title;
    
    //首行缩进
    NSMutableString *result = content.mutableCopy;
    if (![result hasPrefix:@" "]) {
        [result insertString: @"      " atIndex:0];
    }
    NSString *resurlString = [result stringByReplacingOccurrencesOfString:@"\n" withString:@"\n      "];
    
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongSelf
        ADChapterContentModel *model = [[ADChapterContentModel alloc]init];
        model.body  = resurlString;
        model.title = chapterTitle;
        model.chapterNum = chapterIndex;
        model.bookId = strongSelf.bookId;
        model.bookName = strongSelf.bookName;
        model.cover = strongSelf.cover;
        //缓存model到本地
        [[MSYChapterCache share] cachedBookChapterContent: model];
        //获取已经下载的章节数量
        NSMutableArray *bookCachedChapters = (NSMutableArray*)[MSYChapterCache getBookDownloadChapterCount: strongSelf.bookId];
        NSLog(@"成功的下载了第%lu章节,已经缓存的章节数量:%lu,总章节数量:%lu",chapterIndex,bookCachedChapters.count,strongSelf.chapters.count);
        
        if (bookCachedChapters.count == strongSelf.chapters.count)
        {
            // 下载完成
            [strongSelf.delegate msyBookDownloaderSuccessDownload: strongSelf];
        }
        else
        {
            ///?????
            //            if (chapterIndex == self.chapters.count - 1 && bookChapter.count != self.chapters.count)
            //            {
            //                /*** 下载暂停 有可能是退出了程序 又开始下载的 **/
            //                [self.downLoadBtn setTitle:@"  暂停中，点击继续下载" forState:UIControlStateNormal];
            //                [ADSherfCache setDownloadState:MSYBookSuspendDownload bookid:self.bookId];
            //                [self.queue setSuspended:YES];// 暂停
            //                dispatch_semaphore_signal(sema);
            //                return ;
            //            }
            [strongSelf.delegate msyBookDownloader: strongSelf alreadyDownloadChapterCount: bookCachedChapters.count totalChapterCount: strongSelf.chapters.count];
        }
        dispatch_semaphore_signal(sema);
    });
}


#pragma mark -
//MARK:lazy
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

-(void)cancleAllOperation{
    [self.queue cancelAllOperations];
}

-(void)dealloc{
    NSLog(@"!!!!!!!!!!!!!!!");
}

#pragma mark -程序进入前后台处理,todo
//MARK: 进入前台
-(void)setFrontTask{
    //    MSYBookDownloadStatus downState = [ADSherfCache getDownloadStateWithBookid: self.bookId];
    //    if (downState == 3) {//下载完成
    //        return;
    //    }
    //    if (downState == 2) {//暂停下载
    //        return;
    //    }
    //    //判断队列中是否有操作
    //    if(self.queue.operationCount == 0){
    //        NSLog(@"没有操作" );
    //        [JPTool setIsHaveDownLoad:NO];
    //        return;
    //    }
    //如果没有被挂起，才需要暂停
    //    if(self.queue.isSuspended){
    //        NSLog(@"继续");
    //
    //        NSMutableArray *bookChapter = (NSMutableArray*)[ADSherfCache getBookDownloadChapterCount:self.bookId];
    //        NSLog(@"bookChapter.count:%ld",bookChapter.count);
    //        if (_smallArray.count == bookChapter.count) {
    //            [ADSherfCache setDownloadState: MSYBookSuccessDownloaded bookid:self.bookId];
    //            [self.downLoadBtn setTitle:@" 下载完成" forState:UIControlStateNormal];
    //            [JPTool setIsHaveDownLoad:NO];
    //            self.downLoadBtn.userInteractionEnabled = NO;
    //        }else{
    //            //            [self.downLoadBtn setTitle:@"  正在下载..." forState:UIControlStateNormal];
    //            [ADSherfCache setDownloadState:MSYBookDownloaing bookid:self.bookId];
    //            [JPTool setIsHaveDownLoad:YES];
    //            self.downLoadBtn.userInteractionEnabled = YES;
    //        }
    //        [self.queue setSuspended:NO];
    //
    //    }else{
    //        NSLog(@"正在执行");
    //        //            [ADSherfCache setDownloadState:@"1" bookid:self.bookId];
    //    }
}

//MARK: 进入后台
-(void)setBackgroundTask{
    //    if ([ADSherfCache getDownloadStateWithBookid:self.bookId] == MSYBookSuspendDownload) {
    //        //暂停下载
    //        return;
    //    }
    //    //判断队列中是否有操作
    //    if(self.queue.operationCount==0){
    //        NSLog(@"没有操作");
    //        return;
    //    }
    //    //如果没有被挂起，才需要暂停
    //    if(!self.queue.isSuspended){
    //        NSLog(@"暂停");
    //        [self.downLoadBtn setTitle:@"  暂停中，点击继续下载" forState:UIControlStateNormal];
    //        [ADSherfCache setDownloadState:MSYBookSuspendDownload bookid:self.bookId];
    //        [self.queue setSuspended:YES];
    //    }else{
    //        NSLog(@"已经暂停");
    //        [ADSherfCache setDownloadState: MSYBookSuspendDownload bookid:self.bookId];
    //    }
    //    [JPTool setIsHaveDownLoad:NO];
}


//MARK:程序将要被杀死
-(void)setWillTerminateNoti {
    
    //    if ([ADSherfCache getDownloadStateWithBookid:self.bookId] == 1 ) {
    //        /* 程序将要杀死，如果有下载的话就暂停下载(2)，下载任务为0 置为没有下载任务 */
    //        [self.downLoadBtn setTitle:@"  暂停中，点击继续下载" forState:UIControlStateNormal];
    //        [ADSherfCache setDownloadState:MSYBookSuspendDownload bookid:self.bookId];
    //        [self.queue setSuspended:YES];
    //        [JPTool setIsHaveDownLoad:NO];
    //    }
}

@end




