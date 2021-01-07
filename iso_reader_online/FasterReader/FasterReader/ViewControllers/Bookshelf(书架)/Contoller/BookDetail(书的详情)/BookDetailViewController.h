//
//  BookDetailViewController.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 书籍详情 */
@interface BookDetailViewController : UIViewController

/** 书籍ID  */
@property (nonatomic, readwrite , copy) NSString *bookId;
/** 来自哪里  */
@property (nonatomic, readwrite , copy) NSString *isForm;


@end

NS_ASSUME_NONNULL_END
