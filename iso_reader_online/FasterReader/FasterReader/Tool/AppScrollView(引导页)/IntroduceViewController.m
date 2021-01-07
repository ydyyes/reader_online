//
//  ESIntroduceViewController.m
//  ESWineGrandCru
//
//  Created by Apple on 13-1-4.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import "IntroduceViewController.h"
#import "RootTabBarController.h"

#define isIphone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define isIphone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define isIPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

#define isIPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

@interface IntroduceViewController ()

@property (nonatomic,strong)UIScrollView *scrollView;

/** 选择男按钮 */
@property (strong, nonatomic) IBOutlet UIButton *manBtn;
/** 选择女按钮 */
@property (strong, nonatomic) IBOutlet UIButton *womenBtn;
/** 选择性别label 与底部距离 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topWithNavSpace;
/** 选择男女 与屏幕左边距离 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectSexLeftSpace;
/** 底部与屏幕距离 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomBtnSpace;
/** 底部label */
@property (strong, nonatomic) IBOutlet UILabel *bottomLb;

/** 标记男女 */
@property (copy, nonatomic) NSString *gender;

@end

@implementation IntroduceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.gender = @"";//
	if ([JPTool is_iPhoneXN]) {
		self.topWithNavSpace.constant = NavBarHeight+100*[JPTool HeightScale];
		self.selectSexLeftSpace.constant = ([JPTool screenWidth]-106*2 - 65)/2.0;
		self.bottomBtnSpace.constant = 70*[JPTool HeightScale];
	}else{
		self.topWithNavSpace.constant = NavBarHeight+80*[JPTool HeightScale];
		self.selectSexLeftSpace.constant = ([JPTool screenWidth]-106*2 - 50)/2.0;
		self.bottomBtnSpace.constant = 50*[JPTool HeightScale];
	}
	[self.manBtn setImagePositionWithType:(SSImagePositionTypeTop) spacing:(15)];
	[self.womenBtn setImagePositionWithType:(SSImagePositionTypeTop) spacing:(15)];
	self.womenBtn.selected = NO;
	self.manBtn.selected = NO;
}
- (IBAction)selectButtonClick:(UIButton *)sender {
    
	self.bottomLb.text = @"开始阅读";
	if (sender.tag == 101) {

		self.manBtn.selected = !self.manBtn.selected;
		if (self.manBtn.selected) {
			self.gender = @"1";// 男
			[self.manBtn setImage:[UIImage imageNamed:@"men_selected"] forState:UIControlStateNormal];
			[self.manBtn setTitleColor:RGB_COLOR(34, 34, 34) forState:UIControlStateNormal];


			[self.womenBtn setImage:[UIImage imageNamed:@"women_v"] forState:UIControlStateNormal];
			[self.womenBtn setTitleColor:RGB_COLOR(153, 153, 153) forState:UIControlStateNormal];
			self.womenBtn.selected = NO;
		}

	}else{
		self.womenBtn.selected = !self.womenBtn.selected;
		if (self.womenBtn.selected) {
			self.gender = @"2";// 女
			[self.womenBtn setImage:[UIImage imageNamed:@"women_selected"] forState:UIControlStateNormal];
			[self.womenBtn setTitleColor:RGB_COLOR(34, 34, 34) forState:UIControlStateNormal];
			[self.manBtn setImage:[UIImage imageNamed:@"men_v"] forState:UIControlStateNormal];
			[self.manBtn setTitleColor:RGB_COLOR(153, 153, 153) forState:UIControlStateNormal];
			self.manBtn.selected = NO;
		}else{
		}

	}
}

#pragma mark - 暂不选择 进入主页面
- (IBAction)noSelectButtonClick:(UIButton *)sender {
    
    NSString *gender = @"保密";
    if ([self.gender isEqualToString:@"1"]) {
        gender = @"男";
    }else if ([self.gender isEqualToString:@"2"]) {
        gender = @"女";
    }
    
    [MobClick event:@"gender_select" label:gender];

	[[NSUserDefaults standardUserDefaults] setValue:self.gender forKey:@"gender"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	window.rootViewController = [[RootTabBarController alloc] init];
}

-(void)btnDidClicked
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = [[RootTabBarController alloc] init];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // 记录scrollView 的当前位置，因为已经设置了分页效果，所以：位置/屏幕大小 = 第几页
    int current = scrollView.contentOffset.x/[JPTool screenWidth];
    _advertPageControl.currentPage = current;
    
}


@end
