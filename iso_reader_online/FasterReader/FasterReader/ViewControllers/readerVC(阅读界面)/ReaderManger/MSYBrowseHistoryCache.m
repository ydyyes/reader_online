//
//  MSYBrowseHistoryCache.m
//  FasterReader
//
//  Created by apple on 2019/7/12.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "MSYBrowseHistoryCache.h"


@implementation MSYBrowseHistoryCacheModel

- (void)encodeWithCoder:(NSCoder *)coder {
    //告诉系统归档的属性是哪些
    unsigned int count = 0;//表示对象的属性个数
    Ivar *ivars = class_copyIvarList([MSYBrowseHistoryCacheModel class], &count);
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
        Ivar *ivars = class_copyIvarList([MSYBrowseHistoryCacheModel class], &count);
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

@end


@interface MSYBrowseHistoryCache ()

@property (nonatomic, strong) NSMutableArray *browseHistoryIdArray;

@property (nonatomic, strong) YYCache *cache;

@end

@implementation MSYBrowseHistoryCache

+ (instancetype)share {
    
    static MSYBrowseHistoryCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
    });
    return cache;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.cache = [YYCache cacheWithName: FasterReaderBookBrowseHistoryCache];
    }
    return self;
}

#pragma mark -根据小说id添加到浏览记录中
- (void)addBookToBrowseHistory:(MSYBrowseHistoryCacheModel *)bookModel {
    if (!bookModel) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        return;
    }
    if (![self queryWithHistoryBookId: bookModel.bookId]) {
        [self.browseHistoryIdArray addObject:bookModel.bookId];
        [self.cache setObject:self.browseHistoryIdArray forKey: FasterReaderBookBrowseHistoryCacheKey];
        NSString *theKey = [NSString stringWithFormat:@"%@+MSYBrowseHistory",bookModel.bookId];
        [self.cache setObject:bookModel forKey:theKey];
    }
}

#pragma mark -根据小说id查询它是否已经添加到浏览记录中
- (BOOL)queryWithHistoryBookId:(NSString *)bookId {
    __block BOOL isexit = NO;
    [self.browseHistoryIdArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *_id = obj;
        if ([bookId isEqualToString:_id]) {
            isexit = YES;
        }
    }];
    return isexit;
}

/// 获取所有的浏览记录
- (NSMutableArray <MSYBrowseHistoryCacheModel *>*)getBrowseHistory{
    NSArray *books = self.browseHistoryIdArray;
    NSMutableArray *browseHistoyModelArray = [NSMutableArray array];
    for (NSString *bookId in books) {
        NSString *theKey = [NSString stringWithFormat:@"%@+MSYBrowseHistory",bookId];
        id obj =  [self.cache objectForKey: theKey];
        if (obj) {
            [browseHistoyModelArray addObject:obj];
        }
    }
    return browseHistoyModelArray;
}

#pragma mark -更新某本小说的阅读记录
- (void)updateReadHistoryWithBookId:(NSString *)bookID chapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex{
    
    MSYBrowseHistoryCacheModel *model = [self queryReadHistoryWithBookId:bookID];
    model.chapterIndex = chapterIndex;
    model.pageIndex = pageIndex;
    NSString *key = [NSString stringWithFormat:@"%@+MSYReadHistory",bookID];
    [self.cache setObject:model forKey:key];
}

- (MSYBrowseHistoryCacheModel *)queryReadHistoryWithBookId:(NSString *)bookID {
    if (!bookID) {
        MSYBrowseHistoryCacheModel *model = [[MSYBrowseHistoryCacheModel alloc]init];
        model.chapterIndex = 0;
        model.pageIndex = 0;
        return model;
    }
    NSString *key = [NSString stringWithFormat:@"%@+MSYReadHistory",bookID];
    MSYBrowseHistoryCacheModel *model = (MSYBrowseHistoryCacheModel *)[self.cache objectForKey:key];
    if (!model) {
        model = [[MSYBrowseHistoryCacheModel alloc]init];
        model.chapterIndex = 0;
        model.pageIndex = 0;
        return model;
    }
    return model;
}

- (void)removeReadHistory {
    NSArray *cacheModelArray = self.browseHistoryIdArray;
    for(NSString *bookId in cacheModelArray) {
        NSString *key = [NSString stringWithFormat:@"%@+MSYReadHistory",bookId];
        [self.cache removeObjectForKey:key];
    }
}

-(void)removeBrowseHistory {
    //删除阅读到哪里的记录
    [self removeReadHistory];
    
    //删除书籍model
    for (NSString *historyBookId in self.browseHistoryIdArray) {
        NSString *theKey = [NSString stringWithFormat:@"%@+MSYBrowseHistory",historyBookId];
        [self.cache removeObjectForKey:theKey];
    }
    
    //再删除id
    [self.cache removeObjectForKey: FasterReaderBookBrowseHistoryCacheKey];
    //清空booksHistoryArr
    [self.browseHistoryIdArray removeAllObjects];
}


-(NSMutableArray *)browseHistoryIdArray {
    if (!_browseHistoryIdArray) {
        _browseHistoryIdArray = [NSMutableArray array];
        NSArray *obj = (NSArray *)[self.cache objectForKey: FasterReaderBookBrowseHistoryCacheKey];
        if (obj) {
            [_browseHistoryIdArray addObjectsFromArray:obj];
        }
    }
    return _browseHistoryIdArray;
}

@end

