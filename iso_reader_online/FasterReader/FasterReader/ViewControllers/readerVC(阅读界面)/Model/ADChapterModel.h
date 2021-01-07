//
//  ADChapterModel.h
//  reader
//
//  Created by beequick on 2017/8/17.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 章节数model */
@interface ADChapterModel : NSObject

@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign)NSInteger unreadble;
//@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *label;

@end
