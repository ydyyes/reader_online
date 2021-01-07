//
//  JMSYChapterCache.m
//  NightReader
//
//  Created by Restver on 2019/3/16.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "MSYChapterCache.h"
#import "MSYBookCache.h"

@interface MSYChapterCache()

@end

@implementation MSYChapterCache

+ (instancetype)share{

	static MSYChapterCache *cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!cache) {
			cache = [[self alloc] init];
		}
	});
	return cache;
}
- (instancetype)init{

	self = [super init];
	if (self) {

		self.cache = [YYCache cacheWithName: FasterReaderChaptersCache];
	}
	return self;
}


#pragma mark -删除所有缓存的小说(包括章节列表和章节内容)
+ (void)removeAllBookCachedChapters{
    [[MSYChapterCache share].cache removeAllObjects];
}

#pragma mark -根据bookid缓存该小说的所有章节列表model
+(void)cachedBookAllChapters:(NSArray<ADChapterModel *> *)array withBookid:(NSString *)bookid{
    [[MSYChapterCache share].cache setObject:array forKey:bookid];
}
#pragma mark -根据bookid获取该小说的缓存的章节列表model
+ (NSArray <ADChapterModel *>*)getBookAllChaptersWithBookid:(NSString*)bookid {
    if ([[MSYChapterCache share].cache containsObjectForKey:bookid]) {
        return (NSArray*)[[MSYChapterCache share].cache objectForKey:bookid];
    }else{
        return [NSArray array];
    }
}

#pragma mark -缓存某本小说的某章节的内容
- (void)cachedBookChapterContent:(ADChapterContentModel *)model {
    if (!model) {
        NSLog(@"cachedBookChapterContent: model为nil!!!!!!!");
        return;
    }
    
    NSString *chapterNum = [NSString stringWithFormat:@"%lu",model.chapterNum];
    NSString *key = [NSString stringWithFormat:@"%@+%@",model.bookId,FasterReaderChaptersContentCacheKey];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([[MSYChapterCache share].cache containsObjectForKey:key]) {
        dic = (NSMutableDictionary*)[[MSYChapterCache share].cache objectForKey:key];
        [dic setObject:model.body forKey:chapterNum];
    }else{
        [dic setObject:model.body forKey:chapterNum];
    }
    [[MSYChapterCache share].cache setObject:dic forKey:key];
}

#pragma mark -获取某本小说的某个章节的内容
- (ADChapterContentModel*)getBookChapterContentWithChapterNum:(NSString*)chapterNum bookid:(NSString*)bookid {
    NSString *key = [NSString stringWithFormat:@"%@+%@",bookid, FasterReaderChaptersContentCacheKey];
    ADChapterContentModel *model = [[ADChapterContentModel alloc]init];
    NSDictionary *dic = (NSDictionary *)[[MSYChapterCache share].cache objectForKey:key];
    if ([dic containsObjectForKey:chapterNum]) {
        NSString *str =  dic[chapterNum];
        model.body = str ? str : @"暂无数据";
        model.content = model.body;
        return model;
    }
    return model;
}

#pragma mark -删除某本小说缓存的所有章节内容
-(void)removeBookAllInfoWithBookId:(NSString *)bookid{
    //先删除章节内容
    NSString *key = [NSString stringWithFormat:@"%@+%@",bookid, FasterReaderChaptersContentCacheKey];
    [self.cache removeObjectForKey:key];
    //再删除章节列表
    [self.cache removeObjectForKey:bookid];
    //再删除key的模型(不再删除了,即使今天已经下载了,然后把它删除了,今天依然可以下载这本书)
    [[MSYBookCache share] removeBookCacheWithBookId: bookid];
    //设置为未下载状态
    [MSYBookCache setDownloadState: MSYBookNotDownload bookid: bookid];
}

#pragma mark -获取已经缓存过某本小说哪些章节内容的 章节数量
+ (NSArray*)getBookDownloadChapterCount:(NSString*)bookid {
    NSString *key = [NSString stringWithFormat:@"%@+%@",bookid, FasterReaderChaptersContentCacheKey];
    NSMutableDictionary *dict = (NSMutableDictionary*)[[MSYChapterCache share].cache objectForKey:key];
    NSArray *array = [NSArray arrayWithArray: dict.allKeys];
    return array;
}

@end
