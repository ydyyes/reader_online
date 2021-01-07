//
//  BookMarkViewController.h
//  NightReader
//
//  Created by 张俊平 on 2019/6/11.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/** 阅读-书签 */
@interface BookMarkViewController : UIViewController

/** 小说ID */
@property (nonatomic, readwrite , strong) NSString *bookId;


@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *delectBtn;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;

@end

NS_ASSUME_NONNULL_END
