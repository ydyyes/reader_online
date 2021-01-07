//
//  MSYBookDownloader.h
//  FasterReader
//
//  Created by apple on 2019/7/6.
//  Copyright © 2019 Restver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSYChapterCache.h"

NS_ASSUME_NONNULL_BEGIN

@class MSYBookDownloader;
@protocol MSYBookDownloaderDelegate <NSObject>

@required
-(void)msyBookDownloaderStartDownload:(MSYBookDownloader *)bookDownloader ;

-(void)msyBookDownloaderSuspendDownload:(MSYBookDownloader *)bookDownloader ;

-(void)msyBookDownloaderSuccessDownload:(MSYBookDownloader *)bookDownloader ;

-(void)msyBookDownloader:(MSYBookDownloader *)bookDownloader alreadyDownloadChapterCount:(NSInteger)alreadyDownloadCount totalChapterCount: (NSInteger)totalCount;

@end

@interface MSYBookDownloader : NSObject

@property (nonatomic, weak) id<MSYBookDownloaderDelegate> delegate;

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *bookName;
@property (nonatomic, copy) NSString *bookId;

- (void)downloadBookChapters;

- (void)suspendedDownload;

- (void)restartDownload;

- (void)cancleAllOperation;

@end

NS_ASSUME_NONNULL_END
