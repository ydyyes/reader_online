//
//  BookshelfBannerModel.m
//  NightReader
//
//  Created by 张俊平 on 2019/3/4.
//  Copyright © 2019 ZHANGJUNPING. All rights reserved.
//

#import "BookshelfBannerModel.h"

@implementation BookshelfBannerModel

+ (NSDictionary *)modelCustomPropertyMapper {
		// 将personId映射到key为id的数据字段
	return @{@"bannerId":@"id"};
		// 映射可以设定多个映射字段
		//  return @{@"personId":@[@"id",@"uid",@"ID"]};
}

@end
