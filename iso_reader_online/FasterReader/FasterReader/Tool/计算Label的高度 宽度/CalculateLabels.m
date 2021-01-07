//
//  CalculateLabels.m
//  TestProject
//
//  Created by iOS开发T002 on 2017/9/20.
//  Copyright © 2017年 ZHANGJUNPING. All rights reserved.
//

#import "CalculateLabels.h"

@implementation CalculateLabels


+ (CGFloat)calculateLabelWidth:(NSString*)string height:(CGFloat)height fontOfSize:(CGFloat)fontSize {
    
    CGRect contentRect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return contentRect.size.width;
}


+ (CGFloat)calculateLabelHeight:(NSString*)string width:(CGFloat)width fontOfSize:(CGFloat)fontSize {
    
    CGRect contentRect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    return contentRect.size.height;
    
}


+ (CGFloat)calculateLabelHeight:(UILabel*)label width:(CGFloat)width lineSpace:(CGFloat)lineSpace string:(NSString*)string fontOfSize:(CGFloat)fontSize{
    
    CGFloat lineSpace1 = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace1; //行间距
    NSDictionary *attrs = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSParagraphStyleAttributeName : paragraphStyle
                            };
    // 这是一行文本的内容高度
    CGFloat oneHeight = [@"计算一行文本的高度" boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    //大于一行的高度
    CGFloat rowHeight = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    
    NSInteger lineNum = rowHeight / oneHeight;
    //oneHeight 也可以是字体大小加上 3.5 ->
    if (rowHeight > oneHeight) {
        lineSpace1 = lineSpace; // 大于一行调整行间距
    }else{
        lineSpace1 = 0; // 一行就不设置行间距
    }
    label.attributedText = [CalculateLabels getAttributedStringWithString:string lineSpace:lineSpace];
    [label sizeToFit];
    return rowHeight + lineSpace * (lineNum - 0);
}

//设置富文本属性 设置行间距
+(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {

	string = string ? string:@"";
	NSAssert(string, @"string must not be nil.");
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    return attributedString;
}

//获取行高 包括行间距
+ (CGSize)getStringSize:(NSString*)str fontOfSize:(CGFloat)fontOfSize lineSpacing:(CGFloat)lineSpacing width:(CGFloat)width height:(CGFloat)height{
//    height = MAXFLOAT;
    // 设置 文本段落属性，用于控制段落有关属性（行间距，文本缩进等等）
    NSMutableParagraphStyle  *paragraphStyle    = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;//行间距
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, height)
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontOfSize],NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
   
    return size;
}

+ (CGFloat)calculateLabelLinesWithWidth:(CGFloat)width String:(NSString*)string FontOfSize:(CGFloat)fontSize{
    
    CGFloat lineSpace1 = 1;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace1; //行间距
    NSDictionary *attrs = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                            NSParagraphStyleAttributeName : paragraphStyle
                          };
    /*
    // 这是一行文本的内容高度
    CGFloat oneHeight = [@"计算一行文本的高度" boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    
    //大于一行的高度
    CGFloat rowHeight = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
    */
    CGSize sizeOne = [@"一行文本。" boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attrs context:nil].size;
    
    CGSize sizeTwo = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attrs context:nil].size;
    CGFloat oneHeight = ceil(sizeOne.height);
    CGFloat rowHeight = ceil(sizeTwo.height);
    CGFloat lineNum = (rowHeight / oneHeight);
    CGFloat other = lineNum - floor(lineNum);
    return  other>0.5?lineNum+1.0:lineNum;
}


	// 计算labelsize
+ (CGSize)calculateLabelSizeWithText:(NSString *)text font:(NSInteger)font{
	CGSize labelSize = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]}];
	return labelSize;
}


@end


