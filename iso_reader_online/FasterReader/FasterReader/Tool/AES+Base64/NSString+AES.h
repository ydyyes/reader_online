//
//  NSString+AES.h
//  
//
//  Created by Bear on 16/11/26.
//  Copyright © 2016年 Bear. All rights reserved.
//
/*
 使用注意事项:
 1. 在build phases中的GTMBase64.m需要设置 -fno-objc-arc
 2. 在#import "NSString+Base64.m”文件中导入   #import <Foundation/Foundation.h>
 3.在#import "GTMBase64.m”文件中添加          #import <CommonCrypto/CommonCrypto.h>
 */
#import <Foundation/Foundation.h>

@interface NSString (AES)

/**< 加密方法 */
- (NSString*)zjp_encryptWithAES;

/**< 解密方法 */
- (NSString*)zjp_decryptWithAES;

@end
