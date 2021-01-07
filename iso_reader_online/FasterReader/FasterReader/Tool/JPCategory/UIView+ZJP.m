//
//  UIView+ZJP.m
//  NightReader
//
//  Created by 张俊平 on 2019/3/28.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "UIView+ZJP.h"

@implementation UIView (ZJP)

- (CGFloat)tx {
	return self.transform.tx;
}

- (void)setTx:(CGFloat)tx {
	CGAffineTransform transform = self.transform;
	transform.tx = tx;
	self.transform = transform;
}

- (CGFloat)ty {
	return self.transform.ty;
}

- (void)setTy:(CGFloat)ty {
	CGAffineTransform transform = self.transform;
	transform.ty = ty;
	self.transform = transform;
}

	//MARK:使得UIView可以弹窗
- (UIViewController *)presentViewController {

	for (UIView *next = [self superview]; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]&&![nextResponder isKindOfClass:[UINavigationController class]]) {
			UIViewController *vc = (UIViewController *)nextResponder;
			return vc;
		}

	}
	return nil;
}


@end
