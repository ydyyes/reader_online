//
//  MSYBookDownloadManager.m
//  FasterReader
//
//  Created by apple on 2019/7/5.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "MSYBookDownloadManager.h"
#import "FasterReader-Swift.h"

@interface MSYBookDownloadManager()<MSYBookDownloaderDelegate>

@property (nonatomic, strong) NSMutableDictionary *bookDownloaders;

@end

@implementation MSYBookDownloadManager

+ (instancetype)share{
    
    static MSYBookDownloadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.bookDownloaders = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)startDownloadBookWithModel:(MSYBookCacheModel *)model {
    /// 存下载模型到缓存
    [[MSYBookCache share] cachedBookWithCacheModel: model];
    //创建downloader
    MSYBookDownloader *downloader = self.bookDownloaders[model.bookId];
    if (!downloader) {
        downloader = [self getMSYBookDownloaderWithModel: model];
    }
    //开始下载
    [downloader downloadBookChapters];
}

-(void)suspendedDownloadWithModel:(MSYBookCacheModel *)model {
    //获取downloader
    MSYBookDownloader *downloader = self.bookDownloaders[model.bookId];
    if (!downloader) {
        //开始下载的时候失败或者从新启动app
        downloader = [self getMSYBookDownloaderWithModel: model];
    }
    [downloader suspendedDownload];
}

-(void)restartDownloadWithModel:(MSYBookCacheModel *)model {
    //获取downloader
    MSYBookDownloader *downloader = self.bookDownloaders[model.bookId];
    if (!downloader) {
        //开始下载的时候失败或者从新启动app
        downloader = [self getMSYBookDownloaderWithModel: model];
    }
    [downloader restartDownload];
}

-(void)cancelDownloadWithModel:(MSYBookCacheModel *)model {
    //获取downloader
    MSYBookDownloader *downloader = self.bookDownloaders[model.bookId];
    if (!downloader) {
        //开始下载的时候失败或者从新启动app
        downloader = [self getMSYBookDownloaderWithModel: model];
    }
    [downloader suspendedDownload];
    [downloader cancleAllOperation];
    //移除这个下载者
    [self.bookDownloaders removeObjectForKey: model.bookId];
}

#pragma mark -MSYBookDownloaderDelegate
-(void)msyBookDownloaderStartDownload:(MSYBookDownloader *)bookDownloader {
    //设置今日可下载的小说的bookid
    [[MSYBookCache share] setTodayCanDownloaBookWithBookid: bookDownloader.bookId];
    //设置到缓存中
    [MSYBookCache setDownloadState: MSYBookDownloaing bookid: bookDownloader.bookId];
    //通知代理做事情
    [self.delegate msyBookDownloadManager: self bookDownloaderStartDownload: bookDownloader];
}

-(void)msyBookDownloaderSuspendDownload:(MSYBookDownloader *)bookDownloader {
    //设置到缓存中
    [MSYBookCache setDownloadState: MSYBookSuspendDownload bookid: bookDownloader.bookId];
    //通知代理做事情
    [self.delegate msyBookDownloadManager: self bookDownloaderSuspendDownload: bookDownloader];
}

-(void)msyBookDownloaderSuccessDownload:(MSYBookDownloader *)bookDownloader {
    //设置到缓存中
    [MSYBookCache setDownloadState: MSYBookSuccessDownloaded bookid: bookDownloader.bookId];
    //通知代理做事情
    [self.delegate msyBookDownloadManager: self bookDownloaderSuccessDownload: bookDownloader];
    //移除这个下载者
    [self.bookDownloaders removeObjectForKey: bookDownloader.bookId];
}

-(void)msyBookDownloader:(MSYBookDownloader *)bookDownloader alreadyDownloadChapterCount:(NSInteger)alreadyDownloadCount totalChapterCount:(NSInteger)totalCount {
    //通知代理做事情
    [self.delegate msyBookDownloadManager: self bookDownloader: bookDownloader alreadyDownloadChapterCount: alreadyDownloadCount totalChapterCount: totalCount];
}

-(MSYBookDownloader *)getMSYBookDownloaderWithModel:(MSYBookCacheModel *) model{
    MSYBookDownloader *downloader = [[MSYBookDownloader alloc] init];
    downloader.delegate = self;
    downloader.bookId = model.bookId;
    downloader.bookName = model.bookName;
    downloader.cover = model.cover;
    self.bookDownloaders[model.bookId] = downloader;
    return downloader;
}

@end
