//
//  SerachResultModel.m
//  NightReader
//
//  Created by 张俊平 on 2019/3/6.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "SerachResultModel.h"

@implementation SerachResultModel

+ (NSDictionary *)modelCustomPropertyMapper {
	return @{@"bookId":@"id"};
		// 映射可以设定多个映射字段
		//  return @{@"personId":@[@"id",@"uid",@"ID"]};
}

@end
