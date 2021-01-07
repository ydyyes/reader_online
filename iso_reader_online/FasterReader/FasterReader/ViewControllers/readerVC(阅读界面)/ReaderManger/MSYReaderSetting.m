//
//  ADReaderSetting.m
//  reader
//
//  Created by beequick on 2017/8/7.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "MSYReaderSetting.h"
#import "ADCache.h"

@interface MSYReaderSetting()

@end

@implementation MSYReaderSetting

+(MSYReaderSetting *)shareInstance {
    
    static MSYReaderSetting *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        if ([[ADCache share].cache containsObjectForKey: cacheReadSetting]) {
            sharedInstance.setting = (ADBookPageModel *)[[ADCache share].cache objectForKey:cacheReadSetting];
        }else{
            sharedInstance.setting = [[ADBookPageModel alloc] init];
            [[ADCache share].cache setObject:sharedInstance.setting forKey:cacheReadSetting];
        }
    });
    return sharedInstance;
}


-(UIColor *)getReaderTextColor{
    UIColor *textColor;
    if (self.setting.dayModel) {
        if ([_setting.backGroundColor isEqualToString: ADMenuSettingNightThem]) {
            //是白天模式,且是暗色背景,用whiteColor
            textColor = [UIColor whiteColor];
        }else{
            textColor = [UIColor colorWithHexString: ADMenuSettingTextColor];
        }
    }else{
        if (self.setting.isUseNightBackGroundColor) {
            textColor = [UIColor whiteColor];
        }else{
            textColor = [UIColor colorWithHexString: ADMenuSettingTextColor];
        }
    }
    return textColor;
}

-(UIColor *)getReaderBackgroundColor{
    UIColor *color;
    if (self.setting.dayModel) {
        NSString *backGroundColor = self.setting.backGroundColor;
        color = [UIColor colorWithHexString:backGroundColor];
    }else{
        if ([MSYReaderSetting shareInstance].setting.isUseNightBackGroundColor) {
            color = [MSYReaderSetting shareInstance].setting.nightModeBackGroundColor;
        }else{
            NSString *backGroundColor = [MSYReaderSetting shareInstance].setting.backGroundColor;
            color = [UIColor colorWithHexString:backGroundColor];
        }
    }
    return color;
}

- (NSDictionary *)readerAttributes{
    
    NSMutableDictionary *dic = @{}.mutableCopy;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _setting.lineSpace;
    //这种方式两个字符位置更加准确,但是每一页的开始也会空格,但是这不一定是段落的开始
    //    paragraphStyle.firstLineHeadIndent = [@"汉字" boundingRectWithSize:CGSizeMake(200, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:NULL].size.width;
    dic[NSForegroundColorAttributeName] = [self getReaderTextColor];
    dic[NSFontAttributeName] = _setting.font;
    dic[NSParagraphStyleAttributeName] = paragraphStyle;
    _readerAttributes = dic.copy;
    return _readerAttributes;
}

@end




@interface ADBookPageModel()

@end

@implementation ADBookPageModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _dayModel = YES;
        _lineSpace = 10;
        _fontSize = 16.0;
        _backGroundColor = ADMenuSettingFirstThem;
        _alphaValue = 0.85;
        _font = [UIFont systemFontOfSize: _fontSize];
        _unsimplified = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeFloat:self.dayModel forKey:@"dayModel"];
    [aCoder encodeFloat:self.fontSize forKey:@"fontSize"];
    [aCoder encodeFloat:self.lineSpace forKey:@"lineSpace"];
    [aCoder encodeObject:self.fontName forKey:@"fontName"];
    [aCoder encodeObject:self.backGroundColor forKey:@"msyBackGroundColor"];
    [aCoder encodeFloat:self.alphaValue forKey:@"alphaValue"];
    [aCoder encodeObject:self.font forKey:@"font"];
    [aCoder encodeBool:self.unsimplified forKey:@"unsimplified"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self.dayModel = [aDecoder decodeFloatForKey:@"dayModel"] ? [aDecoder decodeFloatForKey:@"dayModel"] : NO;
    self.fontSize  = [aDecoder decodeFloatForKey:@"fontSize"] ? [aDecoder decodeFloatForKey:@"fontSize"] : 16.0;
    self.lineSpace = [aDecoder decodeFloatForKey:@"lineSpace"]?[aDecoder decodeFloatForKey:@"lineSpace"] : 10;
    self.fontName  = [aDecoder decodeObjectForKey:@"fontName"];
    self.backGroundColor = [aDecoder decodeObjectForKey:@"msyBackGroundColor"] ? [aDecoder decodeObjectForKey:@"msyBackGroundColor"] : ADMenuSettingFirstThem;
    self.alphaValue = [aDecoder decodeFloatForKey:@"alphaValue"]?[aDecoder decodeFloatForKey:@"alphaValue"]:0.85;
    self.font = [aDecoder decodeObjectForKey:@"font"]?[aDecoder decodeObjectForKey:@"font"]:[UIFont systemFontOfSize:self.fontSize];
    self.unsimplified = [aDecoder decodeBoolForKey:@"unsimplified"]?[aDecoder decodeBoolForKey:@"unsimplified"]:NO;
    return self;
    
}


- (void)setDayModel:(BOOL)dayModel {
    
    if (dayModel) {
        self.isUseNightBackGroundColor = NO;
    }else{
        self.isUseNightBackGroundColor = YES;
    }
    _dayModel = dayModel;
    [[ADCache share].cache setObject:self forKey: cacheReadSetting];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: ADReaderSettingDidChangeDayMode object:nil];
    });
}

- (void)setBackGroundColor:(NSString *)backGroundColor{
    if ([backGroundColor isEqualToString:ADMenuSettingNightThem]) {
        self.isUseNightBackGroundColor = YES;
    }else{
        self.isUseNightBackGroundColor = NO;
    }
    
    _backGroundColor = backGroundColor;
    [[ADCache share].cache setObject:self forKey:cacheReadSetting];
}

- (void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    _font = [UIFont systemFontOfSize: fontSize];
    [[ADCache share].cache setObject:self forKey: cacheReadSetting];
}
- (void)setLineSpace:(CGFloat)lineSpace{
    _lineSpace = lineSpace;
    [[ADCache share].cache setObject:self forKey: cacheReadSetting];
}

- (void)setAlphaValue:(CGFloat)alphaValue{
    _alphaValue = alphaValue;
    [[ADCache share].cache setObject:self forKey:cacheReadSetting];
}
- (void)setUnsimplified:(BOOL)unsimplified{
    _unsimplified = unsimplified;
    [[ADCache share].cache setObject:self forKey:cacheReadSetting];
}

- (void)setFontName:(NSString *)fontName{
    _fontName = fontName;
    _font = [UIFont fontWithName:_fontName size:_fontSize];
    [[ADCache share].cache setObject:self forKey:cacheReadSetting];
}

-(UIColor *)nightModeBackGroundColor {
    return [UIColor colorWithHexString:ADMenuSettingNightThem];

}

@end


