//
//  ADSherfCache.m
//  reader
//
//  Created by beequick on 2017/8/17.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADSherfCache.h"

#import "MSYChapterCache.h"

@interface ADSherfCache ()

@property (nonatomic, strong) NSMutableArray *booksIdArr;
@property (nonatomic, strong) NSMutableArray *bookNamesArr;

@end

@implementation ADSherfCache

+ (instancetype)share {

    static ADSherfCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[ADSherfCache alloc] init];
    });
    return cache;
}


#pragma mark - 添加小说到书架
+ (void)addBook:(BookCityBookModel *)bookinfo {
    [[ADSherfCache share] addBook:bookinfo];
}
- (void)addBook:(BookCityBookModel *)bookinfo{
    if (!bookinfo) {
        NSLog(@"addBook:(BookCityBookModel *)bookinfo: bookinfo为nil!!!!!!!");
        return;
    }
    if (![self queryWithBookId:bookinfo.bookId]) {
        bookinfo.chapter   = 0;
        bookinfo.pageIndex = 0;
        [self.booksIdArr addObject:bookinfo.bookId];
        [[ADCache share].cache setObject:self.booksIdArr forKey: FasterReaderBookBookIdCacheKey];
        [[ADCache share].cache setObject:bookinfo forKey:bookinfo.bookId];
    }
}

#pragma mark -移除所有书架小说
+ (void)removeAllBooks {
    NSMutableArray *bookidArray = [ADSherfCache query];
    for (int i = 0; i < bookidArray.count; i++ ) {
        [[ADSherfCache share] removeBookShelfWithBookModel:bookidArray[i]];
    }
}

#pragma mark -根据小说id查询它是否已经添加到书架
+ (BOOL)queryWithBookId:(NSString *)bookid{
    return [[ADSherfCache share] queryWithBookId:bookid];
}
- (BOOL)queryWithBookId:(NSString *)bookId {
    __block BOOL isexit = NO;
    [self.booksIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *_id = obj;
        if ([bookId isEqualToString:_id]) {
            isexit = YES;
        }
    }];
    return isexit;
}
#pragma mark -根据小说模型从书架移除指定书籍

+ (void)removeBookShelfWithBookModel:(BookCityBookModel *)bookinfo{
    [[ADSherfCache share] removeBookShelfWithBookModel:bookinfo];
}
- (void)removeBookShelfWithBookModel:(BookCityBookModel *)bookinfo {
    if ([self queryWithBookId:bookinfo.bookId]) {
        [self.booksIdArr removeObject:bookinfo.bookId];
        [[ADCache share].cache setObject:self.booksIdArr forKey: FasterReaderBookBookIdCacheKey];
        [[ADCache share].cache removeObjectForKey:bookinfo.bookId];
    }
}
#pragma mark -根据小说id从书架移除指定书籍
+ (void)removeBookShelfWithBookId:(NSString *)bookId {
    if (!bookId) {
        return;
    }
    [[ADSherfCache share] removeBookShelfWithBookId:bookId];
}

- (void)removeBookShelfWithBookId:(NSString *)bookid {
    if ([self queryWithBookId:bookid]) {
        [self.booksIdArr removeObject:bookid];
        [[ADCache share].cache setObject:self.booksIdArr forKey: FasterReaderBookBookIdCacheKey];
        [[ADCache share].cache removeObjectForKey:bookid];
    }
}

+ (BookCityBookModel *)ADObjectForId:(NSString *)bookid{
    return (BookCityBookModel *)[[ADCache share].cache objectForKey:bookid];
}

#pragma mark -更新小说信息
+ (void)UpdateWithBookInfo:(BookCityBookModel *)bookinfo{
    [[ADSherfCache share] updateWithBookInfo:bookinfo];
}
- (void)updateWithBookInfo:(BookCityBookModel *)bookinfo{
    [[ADCache share].cache removeObjectForKey: bookinfo.bookId];
    if ([self queryWithBookId:bookinfo.bookId]) {
        [[ADCache share].cache setObject:bookinfo forKey:bookinfo.bookId];
    }
}

#pragma mark -拿到(添加到书架的)小说模型数组
+ (NSArray *)query{
    return [[ADSherfCache share] query];
}
- (NSArray *)query{
    __block NSMutableArray *datas = [NSMutableArray array];
    [self.booksIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id newobj = [[ADCache share].cache objectForKey:obj];// 根据bookid拿到小说
        if (newobj) {
            [datas addObject:newobj];
        }
    }];
    return datas;
}

#pragma mark -拿到(添加到书架的,经过排序的)小说数组
+ (NSArray *)queryDesending {
    NSArray *query = [[ADSherfCache share] query];
    BookshelfSortType sortType = [JPTool BookshelfSortType];
    query = [query sortedArrayUsingComparator:^NSComparisonResult(BookCityBookModel*  _Nonnull obj1, BookCityBookModel *  _Nonnull obj2) {
        NSInteger int1;
        NSInteger int2;
        if (sortType == BookshelfSortReadTime) {
            // 按阅读时间排序
            int1 = [obj1.readDate integerValue];
            int2 = [obj2.readDate integerValue];
        }else{
            // 按更新时间排序
            int1 = [obj1.updated integerValue];
            int2 = [obj2.updated integerValue];
        }
        if ( int1 < int2) {//obj2.updateDate
            return NSOrderedDescending;//降序
        }else{
            return NSOrderedAscending;// 升序
        }
    }];
    return query;
}

- (NSMutableArray *)booksIdArr {
    if (!_booksIdArr) {
        _booksIdArr = [NSMutableArray array];
        NSArray *obj = (NSArray *)[[ADCache share].cache objectForKey: FasterReaderBookBookIdCacheKey];
        if (obj) {
            [_booksIdArr addObjectsFromArray:obj];
        }
    }
    return _booksIdArr;
}

#pragma mark - 删除缓存
- (void)cleanBookCache:(NSString*)Path {
    //文件路径
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:Path];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


@end

@implementation ADSherfModel

//- (void)encodeWithCoder:(NSCoder *)aCoder {
//
//    [aCoder encodeObject:self.bookid forKey:@"bookid"];
//    [aCoder encodeObject:self.author forKey:@"author"];
//    [aCoder encodeObject:self.referenceSource forKey:@"referenceSource"];
//    [aCoder encodeObject:self.updated forKey:@"updated"];
//    [aCoder encodeInteger:self.chaptersCount forKey:@"chaptersCount"];
//    [aCoder encodeObject:self.lastChapter forKey:@"lastChapter"];
//    [aCoder encodeObject:self.cover forKey:@"cover"];
//    [aCoder encodeObject:self.title forKey:@"title"];
//    [aCoder encodeInteger:self.chapter forKey:@"chapter"];
//    [aCoder encodeInteger:self.pageIndex forKey:@"pageIndex"];
//    [aCoder encodeObject:self.updateDate forKey:@"updateDate"];
//}
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//
//    self.bookid = [aDecoder decodeObjectForKey:@"bookid"];
//    self.author = [aDecoder decodeObjectForKey:@"author"];
//    self.referenceSource = [aDecoder decodeObjectForKey:@"referenceSource"];
//    self.updated = [aDecoder decodeObjectForKey:@"updated"];
//    self.chaptersCount = [aDecoder decodeIntegerForKey:@"chaptersCount"];
//    self.lastChapter = [aDecoder decodeObjectForKey:@"lastChapter"];
//    self.cover = [aDecoder decodeObjectForKey:@"cover"];
//    self.title = [aDecoder decodeObjectForKey:@"title"];
//    self.chapter = [aDecoder decodeIntegerForKey:@"chapter"];
//    self.pageIndex = [aDecoder decodeIntegerForKey:@"pageIndex"];
//    self.updateDate = [aDecoder decodeObjectForKey:@"updateDate"];
//    return self;
//
//
//}

- (void)encodeWithCoder:(NSCoder *)coder {
		//告诉系统归档的属性是哪些
	unsigned int count = 0;//表示对象的属性个数
	Ivar *ivars = class_copyIvarList([ADSherfModel class], &count);
	for (int i = 0; i < count; i++) {
			//拿到Ivar
		Ivar ivar = ivars[i];
		const char *name = ivar_getName(ivar);//获取到属性的C字符串名称
		NSString *key = [NSString stringWithUTF8String:name];//转成对应的OC名称
																			  //归档 -- 利用KVC
		[coder encodeObject:[self valueForKey:key] forKey:key];
	}
	free(ivars);
		//在OC中使用了Copy、Creat、New类型的函数，需要释放指针！！（注：ARC管不了C函数）
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
			//解档
		unsigned int count = 0;
		Ivar *ivars = class_copyIvarList([ADSherfModel class], &count);
		for (int i = 0; i<count; i++) {
				//拿到Ivar
			Ivar ivar = ivars[i];
			const char *name = ivar_getName(ivar);
			NSString *key = [NSString stringWithUTF8String:name];
				//解档
			id value = [coder decodeObjectForKey:key];
				// 利用KVC赋值
			[self setValue:value forKey:key];
		}
		free(ivars);
	}
	return self;
}
- (NSString *)updateDate{
    if (!_updateDate) {
        _updateDate = [NSString stringWithFormat:@"%ld",time(NULL)];
    }
    return _updateDate;
}
- (void)updateModelDate{
    _updateDate = [NSString stringWithFormat:@"%ld",time(NULL)];

}


@end
