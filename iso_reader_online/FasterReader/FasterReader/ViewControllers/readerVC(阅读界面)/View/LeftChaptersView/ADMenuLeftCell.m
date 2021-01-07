//
//  ADMenuLeftCell.m
//  reader
//
//  Created by beequick on 2017/9/20.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADMenuLeftCell.h"
#import "MSYReaderSetting.h"


@interface ADMenuLeftCell ()

@end

@implementation ADMenuLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    UIColor *selectColor = [UIColor colorWithHexString: ADMenuSettingTextColor2];
    self.chapterNameL.textColor = selectColor;
}

- (void)setModel:(ADChapterModel *)model{
    _model = model;
    self.chapterNameL.text = model.title;
    
    if ([MSYReaderSetting shareInstance].setting.dayModel) {
        self.backgroundColor = [UIColor whiteColor];
        if (_selectIndex == _index) {
            self.backgroundColor = [UIColor colorWithHexString: ADMenuSettingSelectedThem2];
        }
    }else{
        self.backgroundColor = [UIColor colorWithHexString: ADMenuSettingNightThem];
        if (_selectIndex == _index) {
            self.backgroundColor = [UIColor colorWithHexString: ADMenuSettingSelectedThem];
        }
    }
    
}

- (void)setIndex:(NSUInteger)index{

    _index = index;
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
