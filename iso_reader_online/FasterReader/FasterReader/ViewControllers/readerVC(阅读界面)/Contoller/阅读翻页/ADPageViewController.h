//
//  ADPageViewController.h
//  reader
//
//  Created by beequick on 2017/8/4.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCityBookModel.h"

@interface ADPageViewController : UIViewController

/** 书的ID  */
@property (nonatomic, copy) NSString *bookId;
/** 书名 */
@property (nonatomic, copy) NSString *bookName;
/** 封面 */
@property (nonatomic, copy) NSString *cover;
/** 最新章节 */
@property (nonatomic, copy) NSString *lastChapter;

@property(nonatomic,strong) NSString *author;

@property(nonatomic,strong) NSString *majorCate;

/** 章节 */
@property (nonatomic, copy) NSString *bookLabel;

/** 书籍更新时间 */
@property (nonatomic , copy) NSString *updated;

/** 小说信息字典  */
@property (nonatomic, strong) NSDictionary *bookDetailDict;

@end
