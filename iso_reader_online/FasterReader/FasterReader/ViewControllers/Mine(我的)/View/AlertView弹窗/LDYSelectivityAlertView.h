//
//  LDYSelectivityAlertView.h
//  LDYSelectivityAlertView
//
//  Created by 李东阳 on 2018/8/15.
//

#import <UIKit/UIKit.h>

@protocol LDYSelectivityAlertViewDelegate;/** 定义一个协议*/


/*
 可选择性的AlertView(支持单选、多选)
 */

@interface LDYSelectivityAlertView : UIView<UITableViewDelegate,UITableViewDataSource>



/*!
 * @abstract 创建可选择性弹窗
 *
 * @param title 下拉框标题
 * @param datas 下拉框显示的数据源数组
 * @param ifSupportMultiple 是否支持多选功能
 *
 */
-(instancetype)initWithTitle:(NSString *)title
                       datas:(NSArray *)datas
           ifSupportMultiple:(BOOL)ifSupportMultiple;


/*!
 * @abstract 展示
 */
-(void)show;


/*!
 * @abstract 设置代理
 */
@property (nonatomic,assign) id<LDYSelectivityAlertViewDelegate>delegate;


@property (nonatomic,assign) NSInteger selectIndex;


@end


/*!
 * @abstract 代理协议
 */
@protocol LDYSelectivityAlertViewDelegate <NSObject>



/*
 *(单选)返回数据
 */
- (void)singleChoiceBlockData:(NSDictionary *)data;



/*
 *(多选)返回数据
 */
- (void)multipleChoiceBlockDatas:(NSArray *)datas;



@end
