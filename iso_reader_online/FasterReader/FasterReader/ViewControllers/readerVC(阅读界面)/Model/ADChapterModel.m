//
//  ADChapterModel.m
//  reader
//
//  Created by beequick on 2017/8/17.
//  Copyright © 2017年 beequick. All rights reserved.
//

#import "ADChapterModel.h"

@implementation ADChapterModel

+ (NSDictionary *)modelCustomPropertyMapper {
		// 将label映射到key为_label的数据字段
	return @{@"label":@"_label"};
		// 映射可以设定多个映射字段
		//  return @{@"personId":@[@"id",@"uid",@"ID"]};
}
	// 直接添加以下代码即可自动完成
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[self yy_modelEncodeWithCoder:aCoder];

}
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init]; return [self yy_modelInitWithCoder:aDecoder];

}
- (id)copyWithZone:(NSZone *)zone {
	return [self yy_modelCopy];

}
- (NSUInteger)hash {
	return [self yy_modelHash];
}
- (BOOL)isEqual:(id)object {
	return [self yy_modelIsEqual:object];

}
- (NSString *)description {
	return [self yy_modelDescription];
	
}
@end
