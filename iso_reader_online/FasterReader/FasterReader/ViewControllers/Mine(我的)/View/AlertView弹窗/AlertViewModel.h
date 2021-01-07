//
//  AlertViewModel.h
//  NightReader
//
//  Created by 张俊平 on 2019/3/2.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertViewModel : NSObject

@property (nonatomic, strong) NSDictionary *titleDict;

@property (nonatomic, assign) BOOL is_select;

@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
