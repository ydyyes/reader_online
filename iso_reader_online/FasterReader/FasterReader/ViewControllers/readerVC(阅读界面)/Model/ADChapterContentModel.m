//
//  ADChapterContentModel.m
//  reader
//
//  Created by beequick on 2017/8/7.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADChapterContentModel.h"
#import "MSYReaderSetting.h"
#import <CoreText/CoreText.h>

/// 状态栏高度
#define KStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define KNavBarHeight (KStatusBarHeight>20?88:64)

#define KNavBarHeightWhenStatusBarHidden (64.0f)

@implementation ADChapterContentModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _index = 0;
        _chapterNum = 0;
    }
    return self;
}


//- (void)encodeWithCoder:(NSCoder *)coder {
//    //告诉系统归档的属性是哪些
//    unsigned int count = 0;//表示对象的属性个数
//    Ivar *ivars = class_copyIvarList([ADChapterContentModel class], &count);
//    for (int i = 0; i < count; i++) {
//        //拿到Ivar
//        Ivar ivar = ivars[i];
//        const char *name = ivar_getName(ivar);//获取到属性的C字符串名称
//        NSString *key = [NSString stringWithUTF8String:name];//转成对应的OC名称
//        //归档 -- 利用KVC
//        [coder encodeObject:[self valueForKey:key] forKey:key];
//    }
//    free(ivars);
//    //在OC中使用了Copy、Creat、New类型的函数，需要释放指针！！（注：ARC管不了C函数）
//}
//
//- (instancetype)initWithCoder:(NSCoder *)coder {
//    self = [super init];
//    if (self) {
//        //解档
//        unsigned int count = 0;
//        Ivar *ivars = class_copyIvarList([ADChapterContentModel class], &count);
//        for (int i = 0; i<count; i++) {
//            //拿到Ivar
//            Ivar ivar = ivars[i];
//            const char *name = ivar_getName(ivar);
//            NSString *key = [NSString stringWithUTF8String:name];
//            //解档
//            id value = [coder decodeObjectForKey:key];
//            // 利用KVC赋值
//            [self setValue:value forKey:key];
//        }
//        free(ivars);
//    }
//    return self;
//}

- (void)setBody:(NSString *)body{
    _body = [body copy];
//    [self updateContentPaging];
}

- (void)updateContentPaging {

    //为什么使用KNavBarHeightWhenStatusBarHidden?
    //因为当第一次进入阅读界面时,状态栏还没有隐藏,iPhone X状态栏高度KNavBarHeight就是88
    //当滑动,进入下一页时,状态栏隐藏,高度变为0,所以KNavBarHeight就变成64
    //造成文章的最后一行消失不见的bug
    [self pagingWithBounds:CGRectMake(0, 0, [JPTool screenWidth] - kYReaderLeftSpace - kYReaderRightSpace, [JPTool screenHeight] - kReaderBannerAdHeight - KNavBarHeightWhenStatusBarHidden)];

}
- (void)pagingWithBounds:(CGRect)rect{
//	NSLog(@"pagingWithBounds:%f",rect.origin.y);
    NSMutableArray *rangArr = @[].mutableCopy;
    MSYReaderSetting *setting = [MSYReaderSetting shareInstance];
    NSString *content = [self.body copy];//小说内容
//	content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\n    "];
//	if (content containsString:@"\n") {
//		 content
//	}
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content attributes:setting.readerAttributes];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)att);
    CFRange range = CFRangeMake(0, 0);
    NSUInteger rangeOffset = 0;
    do {
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(rangeOffset, 0), path, NULL);
        range = CTFrameGetVisibleStringRange(frame);
        [rangArr addObject:[NSValue valueWithRange:NSMakeRange(rangeOffset, range.length)]];
        rangeOffset = rangeOffset + range.length;
        if (frame) {
            CFRelease(frame);
        }
    } while (range.length+range.location<att.length);
    
    
    if (path) {
        CFRelease(path);
    }
    
    if (framesetter) {
        CFRelease(framesetter);
    }
    _pageArray = rangArr;
    _pageCount = rangArr.count;
}

- (NSString *)getStringWith:(NSUInteger)page{

    NSRange range = [self getRangeWithPage:page];
    if (range.length > 0) {
        return [_body substringWithRange:range];
    }
    return @"";
}

- (NSRange)getRangeWithPage:(NSUInteger)page{
    if (page < _pageArray.count) {
        return [_pageArray[page] rangeValue];
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)content{
    if (!_body) {
        return @"";
    }
    return [self getStringWith:_index];
}


#pragma mark - 计算显示文字高度
+ (CGFloat)getTextHeight:(NSString*)text displyViewSize:(CGSize)displyViewSize {
    
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [MSYReaderSetting shareInstance].setting.lineSpace;//行间距
    UIFont *font = [UIFont fontWithName:[MSYReaderSetting shareInstance].setting.fontName size:[MSYReaderSetting shareInstance].setting.fontSize];
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSFontAttributeName:font,
                                                            NSParagraphStyleAttributeName:paragraphStyle
                                                            };
    CGSize size = [text boundingRectWithSize: displyViewSize options: options attributes: attributes context:nil].size;
    return size.height;
}

@end
