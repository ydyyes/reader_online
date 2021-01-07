	//
	//  ShareViewController.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/2/20.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "ShareViewController.h"
#import <YYText/YYText.h>
#import "UILabel+copy.h"

@interface ShareViewController ()

@property(nonatomic,retain) NSDate *backDate;//进入后台时的时间
@property(nonatomic,retain) NSDate *frontDate;//重新打开应用时的时间
/** 任务ID */
@property (nonatomic, readwrite , copy) NSString *taskId;
/** 任务名称 */
@property (nonatomic, readwrite , copy) NSString *taskName;

@end

@implementation ShareViewController {
	BOOL _showClick;
}

static NSString *const titleSring    = @"海量小说阅读，尽在 美阅小说";
static NSString *const shareUrlSring = @"https://itunes.apple.com/cn/app/id1457293407";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFrontTask) name: UIApplicationWillEnterForegroundNotification object:nil];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

	/// 进入后台
-(void)setBackgroundTask{
//	self.backDate = [NSDate date];
}
	/// 进入前台
-(void)setFrontTask{

	if (_showClick) {

		if (self.backDate) {

			self.frontDate = [NSDate date];
            //这里面就是判断进出应用两次之间的时间差
			NSTimeInterval backDate  = [self.backDate timeIntervalSinceReferenceDate];
			NSTimeInterval frontDate = [self.frontDate timeIntervalSinceReferenceDate];
			int interval = frontDate - backDate;
			NSLog(@"interval:%d",interval);

			if (interval > 7.5 && interval < 18) {
				[self getTaskReport];
			}else{
				[ZJPAlert showAlertWithMessage:@"分享失败" time:2.0];
			}
			_showClick = NO;
		}else{
			NSLog(@"没有时间");
		}
	}

}
- (void)viewDidLoad {
	[super viewDidLoad];

	[self initBasicSetting];
	[self getTaskList];
	_showClick = NO;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    _showClick = NO;
}

#pragma mark - 基本的设置
- (void)initBasicSetting {
    
    self.navigationItem.title = @"邀请好友免费看小说";
    self.buttonSpace.constant = self.buttonSpace.constant * [JPTool WidthScale];
    self.qrImgViewWidth.constant = self.qrImgViewWidth.constant * [JPTool WidthScale];
    self.buttonWidth.constant = self.buttonWidth.constant * [JPTool WidthScale];

//    if ([JPTool is_iPhoneXN]) {
//        self.topSpace.constant = 120;
//    }else{
//        self.topSpace.constant = 85;
//    }
    // MARK:保存按钮设置
	self.saveButton.layer.cornerRadius = 8;
	self.saveButton.layer.masksToBounds = YES;
	self.shareButton.layer.cornerRadius = 8;
	self.shareButton.layer.masksToBounds = YES;

    // 设置背景图片
	UIImage *submitBtnNorImg  = [UIImage imageWithColor:[UIColor buttonNor] size:CGSizeMake(120, 44)] ;
	UIImage *submitBtnHighImg = [UIImage imageWithColor:[UIColor buttonHigh] size:CGSizeMake(120, 44)] ;

	[self.saveButton setBackgroundImage:submitBtnNorImg forState:UIControlStateNormal];
	[self.saveButton setBackgroundImage:submitBtnHighImg forState:UIControlStateHighlighted];

	[self.shareButton setBackgroundImage:submitBtnNorImg forState:UIControlStateNormal];
	[self.shareButton setBackgroundImage:submitBtnHighImg forState:UIControlStateHighlighted];

	self.websiteLb.isCopyable = YES;
    
    //推荐码
    NSString *code = [JPTool UserInvitationCode];
    self.invitationCodeLabel.text = [NSString stringWithFormat:@"推荐码: %@",code];
}


#pragma mark - 获取任务列表(分享)
- (void)getTaskList {

	if (![ZJPNetWork netWorkAvailable]) {
//		[ZJPAlert showAlertWithMessage:@"分享失败" time:2.5];
		return;
	}
	NSMutableDictionary *para = [[NSMutableDictionary alloc]init];
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool MyMineTaskListPath] WithParamsDict:para WithSuccessBlock:^(id responseObject) {

		NSArray *array = responseObject[@"data"];
		if (array.count != 0 && [responseObject[@"errorno"] integerValue] <=200 ) {

			for (int i = 0 ; i < array.count; i++ ) {
				NSDictionary *dataDict = array[i];
				self.taskId = dataDict[@"id"];
				self.taskName = dataDict[@"name"];
			}

		}


	} WithFailurBlock:^(NSError *error) {
		NSLog(@"error：%@",error);
	}];
}

#pragma mark - 任务上报(分享)
- (void)getTaskReport {

	NSMutableDictionary *para = [[NSMutableDictionary alloc]initWithDictionary:@{@"id":self.taskId,@"token":[JPTool USER_TOKEN]}];
	[[JPNetWork sharedManager] requestPostMethodWithPathUrl:[JPTool MyMineTaskReportPath] WithParamsDict:para WithSuccessBlock:^(id responseObject) {

		NSDictionary *dataDict = responseObject[@"data"];
//		NSLog(@"%@",responseObject);
		if (dataDict && [responseObject[@"errorno"] integerValue] <=200 ) {
			[ZJPAlert showAlertWithMessage:@"分享成功" time:3.0];
//			NSLog(@"分享成功");
		}else if ([responseObject[@"errorno"] integerValue] == 400113){
//			[ZJPAlert showAlertWithMessage:@"分享次数已达上限" time:3.0];
		}

	} WithFailurBlock:^(NSError *error) {
		NSLog(@"error：%@",error);
	}];
}
#pragma mark - 保存相册
- (IBAction)saveImgClick:(UIButton *)sender {

	[self saveImage:sender];
}

#pragma mark - 分享
- (IBAction)shareButtonClick:(UIButton *)sender {

	NSString *shareText = @"美阅小说";
	UIImage *shareImage = [UIImage imageNamed:@"QRcode"];
	NSURL *shareUrl = [NSURL URLWithString:shareUrlSring];
	NSArray *activityItemsArray = @[shareText,shareImage,shareUrl];

	UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItemsArray applicationActivities:nil];
	activityVC.modalInPopover = YES;

    // ios8.0 之后用此方法回调
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"activityType == %@",activityType);//com.tencent.xin.sharetimeline 微信 com.sina.weibo.ShareExtension 微博
        if (completed == YES) {

            if ([activityType isEqualToString:@"com.tencent.mqq.ShareExtension"]) {
                NSLog(@"qqqqqqqqqqqqqq");
                    //MARK:记录分享的时间
                self->_showClick = YES;
                self.backDate = [NSDate date];
            }else{
                [self getTaskReport];
            }
            NSLog(@"completed");
        }else{
            NSLog(@"cancel");//com.tencent.mqq.ShareExtension QQ
            [ZJPAlert showAlertWithMessage:@"分享失败" time:2.5];
        }
    };
    activityVC.completionWithItemsHandler = itemsBlock;

    
	[self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - 保存图片
- (void)saveImage:(UIButton*)button {
	UIImage *img  = [self snapshot];//_qrImgView.image
	if (img) {
		UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
	}else{
		[ZJPAlert showAlertWithMessage:@"图片保存失败!" time:1.5];
	}
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {

	if(error != NULL){
		if (error.code == -3310) {
			[ZJPAlert alertWithMessage:PhotoTips title:@"提示"];
		}
	}else{
		[ZJPAlert showAlertWithMessage:@"图片已保存到相册!" time:1.5];
	}

}


///截取当前屏幕大小的图片
- (UIImage *)snapshot {

	UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [[UIScreen mainScreen] scale]);;

	if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
		[self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
	} else {
		CGContextRef context = UIGraphicsGetCurrentContext();
		[self.view.layer renderInContext:context];
	}

	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return viewImage;
}


@end
