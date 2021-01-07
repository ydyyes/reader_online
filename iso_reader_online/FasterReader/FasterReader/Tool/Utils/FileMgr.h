//
//  FileMgr.h
//  MobileWeiBo
//
//  Created by xydd12345 on 11-9-23.
//  Copyright 2011 Easescent. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface FileMgr : NSObject {

}


///从url中得到图片名称
+(NSString *)picNameWithUrl:(NSString *)aUrl;

///将文件保存到中Documents  aPath:文件名
+(void)saveFileWithName:(NSString *)fileName data:(NSData *)aData;
///将文件保存为临时文件tmp
+(void)saveFileToTmpWithName:(NSString *)fileName data:(NSData *)aData;

///fileName文件是否存在Document文件中
+(BOOL)isExistsWithFile:(NSString *)fileName;
///fileName文件是否存在在临时文件tmp中
+(BOOL)isExistsInTmpWithFile:(NSString *)fileName;

///获取本地图片文件的图片指针 fileNamePath:文件名路径
+(UIImage *)imageWithFileNamePath:(NSString *)fileNamePath;
///获取本地图片文件的图片指针 fileName:文件名 aPath：不包括Document根目录的文件路径
+(UIImage *)imageWithFile:(NSString *)fileName path:(NSString*)aPath;
///获取本地文件Document中的头像指针
+(UIImage *)imageWithFile:(NSString *)fileName;
///获取本地临时文件tmp中的头像指针
+(UIImage *)imageInTmpWithFile:(NSString *)fileName;

///获取本地文件Document中的文件路径
+(NSString *)fullpathWithFile:(NSString *)fileName;
///获取本地临时文件tmp中的文件路径
+(NSString *)fullpathInTmpWithFile:(NSString *)fileName;


///将图片分成大、中、小三张图保存到中Documents的三个目录下面  文件名:fileName 文件数据:aData
+(BOOL)saveImageWithName:(NSString*)imageName image:(UIImage*)anImage;
///获取大、中、小图片的绝对路径
+(NSString*)getImagePathWithName:(NSString*)imageName type:(int)aType;
///调整图片大小
+(UIImage *)scaleToSize:(UIImage *)img width:(float)aWidth;
///修改图片大小
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

///删除图片
+(BOOL)deleteImageWithName:(NSString*)imageName;

+ (BOOL)deleteFile:(NSString*)filePath;

+(BOOL)fileExists:(NSString*)filePath;

@end
