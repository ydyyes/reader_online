//
//  ADMenuLeftView.h
//  reader
//
//  Created by beequick on 2017/9/20.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADSherfCache.h"
#import "ADChapterModel.h"

typedef void (^ADChapterListSelect)(NSUInteger chapterIndex,ADChapterModel *model);

typedef void (^MSYChapterListViewClickDownLoad)(void);

@interface ADMenuLeftView : UIView

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *bookName;
@property (nonatomic, copy) NSString *bookId;
/** 最新章节 */
@property (nonatomic, copy) NSString *lastChapter;

@property(nonatomic,copy) NSString *author;

@property(nonatomic,copy) NSString *majorCate;

@property(nonatomic,copy) NSString *updated;



@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, assign) NSInteger currentChapterIndex;
@property (nonatomic, copy) ADChapterListSelect listSelect;

@property (nonatomic, copy) MSYChapterListViewClickDownLoad clickDownloadBook;

+ (instancetype)leftView;

- (void)show;

@end
