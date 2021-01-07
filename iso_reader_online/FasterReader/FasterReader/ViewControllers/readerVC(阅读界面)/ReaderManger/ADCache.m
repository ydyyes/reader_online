	//
	//  ADCache.m
	//  ImageBrowser
	//
	//  Created by 杜林伟 on 16/9/28.
	//  Copyright © 2016年 adu. All rights reserved.
	//

#import "ADCache.h"

static NSString *const kbookId = @"kbookId";//bookId

@interface ADCache ()

@property (nonatomic, strong) NSMutableDictionary *CacheDict;//内存中储存 每个bookID对应的cache
@property (nonatomic, strong) NSMutableArray *CacheArray;//本地存储所有的 bookid

@end

@implementation ADCache

+ (instancetype)share{

	static ADCache *ADcache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!ADcache) {
			ADcache = [[ADCache alloc] init];
		}
	});
	return ADcache;
}
- (instancetype)init{

	self = [super init];
	if (self) {
		self.CacheDict  = [NSMutableDictionary dictionary];
		self.CacheArray = [NSMutableArray array];
		self.cache = [YYCache cacheWithPath:[self createCachePath: FasterReaderBookInfoCache]];

		if ([self.cache containsObjectForKey: FasterReaderBookInfoCache]) {

			self.CacheArray = (NSMutableArray *)[self.cache objectForKey: FasterReaderBookInfoCache];
			NSLog(@"缓存中的书籍 = %@!!!!!!!!!!!!!!", self.CacheArray);
			for (int i = 0; i < self.CacheArray.count; i++) {
				NSString *bookid = self.CacheArray[i];
				YYCache *cache = [YYCache cacheWithPath:[self createCachePath:bookid]];//缓存路径
				[self.CacheDict setObject:cache forKey:bookid];
			}
		}
	}
	return self;
}

// 缓存路径
- (NSString *)createCachePath:(NSString *)name {
	NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
	NSString *path = [cacheFolder stringByAppendingPathComponent:name];
	return path;
}
// 缓存路径是否存在
- (BOOL)isBookSaved:(NSString *)bookid {

	BOOL isexit = NO;
	id object = [self.CacheDict objectForKey:bookid];
	if (object) {
		isexit = YES;
	}else{
		isexit = NO;
	}
	return isexit;
}
/**
 * 储存值
 */
- (void)saveChapter:(id)chapter model:(AABookContentCacheModel *)model {
	NSString *key = model.bookContent;//[model.link md5String];
	if ([self isBookSaved:model.bookId]) {
		YYCache *cache = [self.CacheDict objectForKey:model.bookId];
		[cache setObject:chapter forKey:key withBlock:^{

		}];
	}else{
		YYCache *cache = [YYCache cacheWithPath:[self createCachePath:model.bookId]];
		[self.CacheDict setObject:cache forKey:model.bookId];
		[self.CacheArray addObject:model.bookId];
		[self.cache setObject:self.CacheArray forKey: FasterReaderBookInfoCache];
		[cache setObject:chapter forKey:key withBlock:^{

		}];

	}
}

#pragma mark - 获取值
/**
 *  是否存在
 */

- (BOOL)AA_containsObject:(AABookContentCacheModel *)model {


	BOOL isexit = NO;
	NSString *bookId = model.bookId;
	if ([self isBookSaved:bookId]) {
		YYCache *cache = [self.CacheDict objectForKey:bookId];
		return [cache containsObjectForKey:model.bookContent];
	}else{
		return NO;
	}
	return isexit;
}

- (id)getChapter:(AABookContentCacheModel *)model {

	YYCache *cache = [self.CacheDict objectForKey:model.bookId];
	return [cache objectForKey:model.bookContent];
}

@end

@implementation AABookContentCacheModel


@end
