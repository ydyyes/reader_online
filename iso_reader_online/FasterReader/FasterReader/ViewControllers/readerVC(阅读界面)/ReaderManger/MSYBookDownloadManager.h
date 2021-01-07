//
//  MSYBookDownloadManager.h
//  FasterReader
//
//  Created by apple on 2019/7/5.
//  Copyright © 2019 Restver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSYBookCache.h"
#import "MSYBookDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@class MSYBookDownloadManager,MSYBookCacheModel;

@protocol MSYBookDownloadManagerDelegate <NSObject>

@required
-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloaderStartDownload:(MSYBookDownloader *)bookDownloader ;

-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloaderSuspendDownload:(MSYBookDownloader *)bookDownloader;

-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloaderSuccessDownload:(MSYBookDownloader *)bookDownloader ;

-(void)msyBookDownloadManager:(MSYBookDownloadManager *)manager bookDownloader:(MSYBookDownloader *)bookDownloader alreadyDownloadChapterCount:(NSInteger)alreadyDownloadCount totalChapterCount: (NSInteger)totalCount;

@end

@interface MSYBookDownloadManager : NSObject

+ (instancetype)share;

@property (nonatomic, weak) id<MSYBookDownloadManagerDelegate> delegate;

- (void)startDownloadBookWithModel:(MSYBookCacheModel *)model;

- (void)suspendedDownloadWithModel:(MSYBookCacheModel *)model;

- (void)restartDownloadWithModel:(MSYBookCacheModel *)model;

- (void)cancelDownloadWithModel:(MSYBookCacheModel *)model;

//- (void)cancleAllOperation;

@end

NS_ASSUME_NONNULL_END
