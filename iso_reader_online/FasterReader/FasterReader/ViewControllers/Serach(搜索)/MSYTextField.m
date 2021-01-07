//
//  MSYTextField.m
//  FasterReader
//
//  Created by apple on 2019/7/11.
//  Copyright © 2019 Restver. All rights reserved.
//

#import "MSYTextField.h"

@implementation MSYTextField


//未编辑状态下的起始位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 0);
}
// 编辑状态下的起始位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 0);
}
//placeholder起始位置
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 0);
}

@end
