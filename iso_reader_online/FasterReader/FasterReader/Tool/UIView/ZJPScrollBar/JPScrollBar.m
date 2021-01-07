	//
	//  JPScrollBar.m
	//  NightReader
	//
	//  Created by 张俊平 on 2019/6/3.
	//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
	//

#import "JPScrollBar.h"

@interface JPScrollBar ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIImageView *scrollBar;
@property (weak, nonatomic) NSTimer *hideAnimationTimer;

@end

static const CGFloat kJPScrollBarAnimationHideDelay = 1.5;

@implementation JPScrollBar

- (instancetype)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
			//初始化设置
		[self initInfo];

			//创建控件
		[self creatControl];

			//添加手势
		[self addSwipeGesture];
	}

	return self;
}

- (void)initInfo {

	_barMoveDuration = 0.25f;
		//    _foreColor = [UIColor colorWithHexString:@"#2f9cd4"];
	_backColor = [UIColor colorWithHexString:@"#e6e6e6"];
	
		//    self.layer.cornerRadius = self.bounds.size.width * 0.5;
		//    self.layer.masksToBounds = YES;
	self.backgroundColor = _backColor;
}

- (void)creatControl {
		//背景视图
	UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:backView];
	_backView = backView;

		//滚动条
	UIImageView *scrollBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
	scrollBar.image = [UIImage imageNamed:@"icon_slider"];
	scrollBar.backgroundColor = _foreColor;
	scrollBar.userInteractionEnabled = YES;
		//    scrollBar.layer.cornerRadius = self.bounds.size.width * 0.5;
		//    scrollBar.layer.masksToBounds = YES;
	[self addSubview:scrollBar];
	_scrollBar = scrollBar;

	self.hidden = YES;
	_scrollBar.alpha = 0;
}

- (void)addSwipeGesture {
		//添加点击手势
		//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		//    [_backView addGestureRecognizer:tap];

		//添加滚动条滑动手势
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[_scrollBar addGestureRecognizer:pan];
}

- (void)setForeColor:(UIColor *)foreColor
{
	_foreColor = foreColor;
	_scrollBar.backgroundColor = _foreColor;
}

- (void)setBackColor:(UIColor *)backColor
{
	_backColor = backColor;
	self.backgroundColor = backColor;
}

- (void)setBarHeight:(CGFloat)barHeight {
	_barHeight = barHeight > _minBarHeight ? barHeight : _minBarHeight;

	CGRect temFrame = _scrollBar.frame;
	temFrame.size.height = _barHeight;
	_scrollBar.frame = temFrame;
}

- (void)setYPosition:(CGFloat)yPosition {
	_yPosition = yPosition;

	CGRect temFrame = _scrollBar.frame;
	temFrame.origin.y = yPosition;
	_scrollBar.frame = temFrame;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {

	if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {//|| sender.state == UIGestureRecognizerStateCancelled
		[self hidden];
	}else{
		self.hidden = NO;
		self.scrollBar.alpha = 1;
		[self cancelHideWithDelay];
	}

		//获取偏移量
	CGFloat moveY = [sender translationInView:self].y;

		//重置偏移量，避免下次获取到的是原基础的增量
	[sender setTranslation:CGPointMake(0, 0) inView:self];

		//在顶部上滑或底部下滑直接返回
	if ((_yPosition <= 0 && moveY <= 0) || (_yPosition >= self.bounds.size.height - _barHeight && moveY >= 0)) return;

		//赋值
	self.yPosition += moveY;

		//防止瞬间大偏移量滑动影响显示效果
	if (_yPosition < 0) self.yPosition = 0;
	if (_yPosition > self.bounds.size.height - _barHeight && moveY >= 0) self.yPosition = self.bounds.size.height - _barHeight;

		//代理
	if (_delegate && [_delegate respondsToSelector:@selector(jpScrollBarDidScroll:)]) {
		[_delegate jpScrollBarDidScroll:self];
	}
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
		//点击滚动条返回
	if (sender.view == _scrollBar) return;

		//获取点击的位置
	CGFloat positionY = [sender locationInView:self].y;

		//赋值
	[UIView animateWithDuration:_barMoveDuration animations:^{
		self.yPosition = positionY > _yPosition ? positionY - _barHeight : positionY;
	}];

		//代理
	if (_delegate && [_delegate respondsToSelector:@selector(jpScrollBarTouchAction:)]) {
		[_delegate jpScrollBarTouchAction:self];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (self.hideAnimationTimer) {
		[self.hideAnimationTimer invalidate];
	}
}
- (void)hidden {
	if (self.hideAnimationTimer != nil) {
		[self.hideAnimationTimer invalidate];
	}
	self.hideAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:kJPScrollBarAnimationHideDelay target:self selector:@selector(hideWithAnimationOnTimer) userInfo:nil repeats:NO];


}
- (void)hideWithAnimationOnTimer {
	[UIView animateWithDuration:0.25 animations:^{
		self.scrollBar.alpha = 0;

	}completion:^(BOOL finished) {
		self.hidden = YES;

	}];
}

- (void)cancelHideWithDelay {
	if (self.hideAnimationTimer != nil) {
		[self.hideAnimationTimer invalidate];
	}
}

- (void)show {

	self.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^{
		self.scrollBar.alpha = 1;

	}completion:^(BOOL finished) {

	}];

}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
