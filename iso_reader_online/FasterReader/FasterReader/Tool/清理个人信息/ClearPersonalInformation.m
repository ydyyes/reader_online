//
//  ClearPersonalInformation.m
//  PaoTui
//
//  Created by iOS开发 on 17/9/7.
//  Copyright © 2017年 SunBo. All rights reserved.
//

#import "ClearPersonalInformation.h"

@implementation ClearPersonalInformation

+ (void)clearInformation {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults removeObjectForKey:@"userid"];// 用户ID 手机号
    [userDefaults removeObjectForKey:@"u_type"]; // 用户类型 普通、会员
    [userDefaults removeObjectForKey:@"avatar"];// 存本地的头像
    [userDefaults removeObjectForKey:@"USER_AVATAR"];// 存本地的头像url
    [userDefaults removeObjectForKey:@"username"];
//    [userDefaults removeObjectForKey:@"xinyong"];
//    [userDefaults removeObjectForKey:@"authbook"];
//    [userDefaults removeObjectForKey:@"vtruename"];
//    [userDefaults removeObjectForKey:@"truename"];
//    [userDefaults removeObjectForKey:@"token"];
//    [userDefaults removeObjectForKey:@"working"];
//    [userDefaults removeObjectForKey:@"jidan_phone"];
//    [userDefaults removeObjectForKey:@"staff_state"];
//    [userDefaults removeObjectForKey:@"is_help"];

    
    [userDefaults synchronize];

}

@end
