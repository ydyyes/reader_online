//
//  MSYBookCache.m
//  FasterReader
//
//  Created by apple on 2019/7/7.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "MSYBookCache.h"
#import "FasterReader-Swift.h"

#define MSYBookCacheMaxCount 3

@interface MSYBookCache()

@property (nonatomic, strong) YYCache *cache;

@property (nonatomic, strong) NSMutableArray <MSYBookCacheModel *> *bookCachedArray;

@property (nonatomic, strong) NSMutableArray *todayCanDownloadBookIdArray;

@end

@implementation MSYBookCache

+ (instancetype)share{
    
    static MSYBookCache *bookCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!bookCache) {
            bookCache = [[self alloc] init];
        }
    });
    return bookCache;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.cache = [YYCache cacheWithName: FasterReaderBookDownload];
    }
    return self;
}

- (void)cachedBookWithCacheModel:(MSYBookCacheModel *)model {
    if (!model) {
        NSLog(@"cachedBookChapterContent: model为nil!!!!!!!");
        return;
    }
    
    if (![self queryBookIsInBookCacheWithBookId: model.bookId]) {
        [self.bookCachedArray addObject: model];
        [self.cache setObject:self.bookCachedArray forKey: FasterReaderBookDownloadBookIdKey];
    }

}

+ (NSArray <MSYBookCacheModel *>*)getAllBookCacheArray {
    return [MSYBookCache share].bookCachedArray;
}

- (void)removeBookCacheWithBookId:(NSString *)bookid{
    MSYBookCacheModel *model = [self getBookCacheModelWithBookId: bookid];
    if (model) {
        [self.bookCachedArray removeObject: model];
        [self.cache setObject:self.bookCachedArray forKey: FasterReaderBookDownloadBookIdKey];
    }
}

- (MSYBookCacheModel *)getBookCacheModelWithBookId:(NSString *)bookId {
    __block MSYBookCacheModel *model;
    [self.bookCachedArray enumerateObjectsUsingBlock:^(MSYBookCacheModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.bookId isEqualToString:bookId]) {
            model = obj;
            *stop = YES;
        }
    }];
    return model;
}

#pragma mark -根据小说id查询它是否已经添加到缓存记录中
- (BOOL)queryBookIsInBookCacheWithBookId:(NSString *)bookId {
    __block BOOL isexit = NO;
    [self.bookCachedArray enumerateObjectsUsingBlock:^(MSYBookCacheModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *_id = obj.bookId;
        if ([bookId isEqualToString:_id]) {
            isexit = YES;
            *stop = YES;
        }
    }];
    return isexit;
}


-(NSMutableArray<MSYBookCacheModel *> *)bookCachedArray {
    if (!_bookCachedArray) {
        _bookCachedArray = [NSMutableArray array];
        NSArray *obj = (NSArray *)[self.cache objectForKey: FasterReaderBookDownloadBookIdKey];
        if (obj) {
            [_bookCachedArray addObjectsFromArray:obj];
        }
    }
    return _bookCachedArray;
}


- (BOOL)isCanDownloadBookWithBookid:(NSString *)bookid {
    if (!bookid) {
        NSLog(@"isCanDownloadBookWithBookid bookid为nil");
        return NO;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDayDate = [userDefaults objectForKey: @"lastDownLoadDate"];
    NSDate *todayDate = [NSDate date];
    
    //说明没有存,是第一次下载,所以可以下载
    if (!lastDayDate) {
        [userDefaults setObject: todayDate forKey: @"lastDownLoadDate"];
        [userDefaults synchronize];
        return YES;
    }
    
    NSInteger todayMonth =  [self convertDateToMonth: todayDate];
    NSInteger lastMonth =  [self convertDateToMonth: lastDayDate];
    NSInteger today =  [self convertDateToDay: todayDate];
    NSInteger lastDay =  [self convertDateToDay: lastDayDate];
    
    //是新的一月,那必然是新的一天
    if (todayMonth > lastMonth) {
        //今天也是新的元气满满的一天呢,所以又可以开始重新计算可下载次数了
        [self resetDownloadInfo: todayDate];
        return YES;
    }
    
    //啊,我们是同一月的,今天大于昨天........
    if (today > lastDay)
    {
        //今天也是新的元气满满的一天呢,所以又可以开始重新计算可下载次数了
        [self resetDownloadInfo: todayDate];
        return YES;
    }
    
    //啊,我们是同一月的,如果昨天也是今天,这里要判断今天还有没有可下载的次数
    if (lastDay == today)
    {
        //没有超过最大下载次数
        if (self.todayCanDownloadBookIdArray.count < MSYBookCacheMaxCount)
        {
            //没有超过最大下载限制,可以下载
            return YES;
        }
        else
        {
            //已经超过最大下载次数了
            //就要看看这个id是不是今天下载过的,是的话,就放行,可以下载
            if ([self.todayCanDownloadBookIdArray containsObject: bookid]) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}

-(void)resetDownloadInfo:(NSDate *)todayDate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //重新计算可下载次数
    [self.todayCanDownloadBookIdArray removeAllObjects];
    [[MSYBookCache share].cache setObject: self.todayCanDownloadBookIdArray forKey: FasterReaderBookTodayCanDownloadIdKey];
    //重新设置时间
    [userDefaults setObject: todayDate forKey: @"lastDownLoadDate"];
    [userDefaults synchronize];
}

/** 设置今日可下载小说的ID */
-(void)setTodayCanDownloaBookWithBookid:(NSString*)bookid {
    if (!bookid) {
        NSLog(@"setDownloadingBookid bookid为nil");
        return;
    }
    
    if ([self.todayCanDownloadBookIdArray containsObject:bookid]) {
        return;
    }
    [self.todayCanDownloadBookIdArray addObject: bookid];
    [self.cache setObject: self.todayCanDownloadBookIdArray forKey: FasterReaderBookTodayCanDownloadIdKey];
}


/**  设置小说的下载状态 下载完成3  下载中1 下载暂停2 没有下载0 */
+ (void)setDownloadState:(MSYBookDownloadStatus)state bookid:(NSString*)bookid {
    NSString *stateStr = [NSString stringWithFormat:@"%d",(int)state];
    [[MSYBookCache share].cache setObject:stateStr forKey:bookid];
}
/** 获取小说的下载状态 */
+ (MSYBookDownloadStatus)getDownloadStateWithBookid:(NSString*)bookid {
    NSString* stateStr = (NSString*)[[MSYBookCache share].cache objectForKey: bookid];
    MSYBookDownloadStatus status = MSYBookNotDownload;
    if (stateStr) {
        switch ([stateStr integerValue]) {
            case 0:
                status = MSYBookNotDownload;
                break;
            case 1:
                status = MSYBookDownloaing;
                break;
            case 2:
                status = MSYBookSuspendDownload;
                break;
            case 3:
                status = MSYBookSuccessDownloaded;
                break;
            default:
                break;
        }
    }
    return status;
}


- (NSMutableArray *)todayCanDownloadBookIdArray {
    if (!_todayCanDownloadBookIdArray) {
        _todayCanDownloadBookIdArray = [NSMutableArray array];
        NSArray *obj = (NSArray *)[self.cache objectForKey: FasterReaderBookTodayCanDownloadIdKey];
        if (obj) {
            [_todayCanDownloadBookIdArray addObjectsFromArray:obj];
        }
    }
    return _todayCanDownloadBookIdArray;
}
    
    
//根据date获取月
- (NSInteger)convertDateToMonth:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth) fromDate:date];
    return [components month];
}

//根据date获取日
- (NSInteger)convertDateToDay:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate: date];
    return [components day];
}

@end
