//
//  JPLoadingView.h
//  NightReader
//
//  Created by 张俊平 on 2019/2/21.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPLoadingView : UIButton

{
	UIImageView *_activeView;
		//    UIImageView *_loadingView;
	UIImageView *_click_loadView;
}
@property (nonatomic,assign) BOOL isRevokApply;
@property (nonatomic,strong) UILabel *label_title;
@property (nonatomic,strong) UILabel *label_content;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,assign) BOOL loadFailStatus;

@property (nonatomic,assign) BOOL loadFail;

@end

NS_ASSUME_NONNULL_END
