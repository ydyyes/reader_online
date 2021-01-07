//
//  FileMgr.m
//  MobileWeiBo
//
//  Created by xydd12345 on 11-9-23.
//  Copyright 2011 Easescent. All rights reserved.
//

#import "FileMgr.h"
#import "Utils.h"
#define DEFAULT_FILEPATH @"imagecache"

@implementation FileMgr

//从url中得到图片名称
+(NSString *)picNameWithUrl:(NSString *)aUrl
{
	//判断是否为图片格式
	//if (([aUrl hasSuffix:@".jpg"] || [aUrl hasSuffix:@".png"]) == NO) {
//		
//		return nil;
//	}
	if (!aUrl) {
		return nil;
	}
	NSArray *arr = [aUrl componentsSeparatedByString:@"/"];
	NSInteger inCount = [arr count] - 1;
	NSString * picName = [[NSString alloc] initWithString:([arr objectAtIndex:inCount])];
	
	return picName ;
#if 0    
    //对于错误信息
    NSError *error;
    // 创建文件管理器
//    NSFileManager *fileMgr = [NSFileManagerdefaultManager];
  //  NSFileManager* fileMgr = [NS

    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory() 
                                   stringByAppendingPathComponent:@"Documents"];
    
    NSFileManager* fileMgr;
    //在filePath2中判断是否删除这个文件
    if ([fileMgr removeItemAtPath:@"" error:&error] != YES)
//        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    //显示文件目录的内容
//    NSLog(@"Documentsdirectory: %@",
          [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
//    一旦文件被删除了，正如你所预料的那样，文件目录就会被自动清空：
#endif
}

//调整图片大小
+(UIImage *)scaleToSize:(UIImage *)img width:(float)aWidth{
    float i = img.size.width/aWidth;
    CGSize aSize = CGSizeMake(aWidth, img.size.height/i);
    UIGraphicsBeginImageContext(aSize);
    [img drawInRect:CGRectMake(0,0,aWidth,img.size.height/i)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(BOOL)deleteImageWithName:(NSString*)imageName
{
    BOOL rtval = YES;
    //如果小图存在删除小图
    if ([FileMgr fileExists:GET_IMAGE_PATH(imageName,IMG_SOURCE_SMALL)]) {
        if (![FileMgr deleteFile:GET_IMAGE_PATH(imageName,IMG_SOURCE_SMALL)]) {
            rtval = NO;
        }
    }
    //如果中图存在删除中图
    if ([FileMgr fileExists:GET_IMAGE_PATH(imageName,IMG_SOURCE_MIDDLE)]) {
        if (![FileMgr deleteFile:GET_IMAGE_PATH(imageName,IMG_SOURCE_MIDDLE)]) {
            rtval = NO;
        }
    }
    //如果大图存在删除大图
    if ([FileMgr fileExists:GET_IMAGE_PATH(imageName,IMG_SOURCE_BIG)]) {
        if (![FileMgr deleteFile:GET_IMAGE_PATH(imageName,IMG_SOURCE_BIG)]) {
            rtval = NO;
        }
    }
    NSDictionary* aDict = [NSDictionary dictionaryWithObject:imageName forKey:@"imgName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDeletedImg" object:self userInfo:aDict];
    return rtval;
}
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
//    NSLog(@"newSize.width===%f",newSize.width);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
//将图片分成大、中、小三张图保存到中Documents的三个目录下面  文件名:fileName 文件数据:aData
+(BOOL)saveImageWithName:(NSString*)imageName image:(UIImage*)anImage
{
    BOOL rtval = YES;
    BOOL isDirectory = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    NSString* imageDir;
    imageDir = [documentsDir stringByAppendingString:@"/IMG_SMALL"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:imageDir error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
	NSString *filePath  = [FileMgr getImagePathWithName:imageName type:IMG_SOURCE_SMALL];
    UIImage* smallImage =  [FileMgr scaleToSize:anImage width:150];
    NSData* aData = UIImageJPEGRepresentation(smallImage, 0.3);
    rtval = [aData writeToFile:filePath atomically:NO];
    if (!rtval)
        return rtval;
    
    isDirectory = NO;
    imageDir = [documentsDir stringByAppendingString:@"/IMG_MIDDLE"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:imageDir error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
	filePath   = [FileMgr getImagePathWithName:imageName type:IMG_SOURCE_MIDDLE];
    smallImage =  [FileMgr scaleToSize:anImage width:295];
    aData = UIImageJPEGRepresentation(smallImage, 0.4);
    rtval = [aData writeToFile:filePath atomically:NO];
    if (!rtval)
        return rtval;
    
    isDirectory = NO;
    imageDir = [documentsDir stringByAppendingString:@"/IMG_BIG"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:imageDir error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
	filePath = [FileMgr getImagePathWithName:imageName type:IMG_SOURCE_BIG];
    int factor = anImage.size.width/1000;
    if (factor == 0) {
        factor = 1;
    }
    float width = anImage.size.width/factor;
    smallImage  =  [FileMgr scaleToSize:anImage width:width];
    aData = UIImageJPEGRepresentation(smallImage, 0.5);
    rtval = [aData writeToFile:filePath atomically:NO];
    if (!rtval)
        return rtval;
    
    return rtval;
}

+(NSString*)getImagePathWithName:(NSString*)imageName type:(int)aType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    switch (aType) {
        case IMG_SOURCE_SMALL:
            documentsDir = [documentsDir stringByAppendingString:@"/IMG_SMALL"];
            break;
        case IMG_SOURCE_MIDDLE:
            documentsDir = [documentsDir stringByAppendingString:@"/IMG_MIDDLE"];
            break;
        case IMG_SOURCE_BIG:
            documentsDir = [documentsDir stringByAppendingString:@"/IMG_BIG"];
            break;
        case IMG_SOURCE_CARD_IMG:
            documentsDir = [documentsDir stringByAppendingString:@"/CARD_IMG"];
            break;
        default:
            break;
    }
    NSString *imagePath = [documentsDir stringByAppendingPathComponent:imageName];

    return imagePath;
}

//将文件保存到中Documents  文件名:fileName 文件数据:aData
+(void)saveFileWithName:(NSString *)fileName data:(NSData *)aData
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
	[aData writeToFile:filePath atomically:NO];
	
}

//将文件保存为临时文件tmp
+(void)saveFileToTmpWithName:(NSString *)fileName data:(NSData *)aData
{
	NSString *tempDir  = NSTemporaryDirectory();
	NSString *filePath = [tempDir stringByAppendingPathComponent:fileName];
	[aData writeToFile:filePath atomically:NO];
	
}

//临时文件tmp取出保存的文件
+(UIImage*)loadImageToTmpWithName:(NSString *)fileName
{
	NSString *tempDir  = NSTemporaryDirectory();
	NSString *filePath = [tempDir stringByAppendingPathComponent:fileName];
    UIImage* anImage   = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
//	[aData writeToFile:filePath atomically:NO];
    return anImage;
	
}

//fileName是否存在在文件Document中
+(BOOL)isExistsWithFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
	NSFileManager *fm  = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:filePath];
	
	if (!exists) {
		
		return NO;
	}
	else {
		return YES;
	}
	
}

//fileName是否存在在临时文件tmp中
+(BOOL)isExistsInTmpWithFile:(NSString *)fileName
{
	NSString *tempDir  = NSTemporaryDirectory();
	NSString *filePath = [tempDir stringByAppendingPathComponent:fileName];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:filePath];
	
	if (!exists) {
		
		return NO;
	}
	else {
		return YES;
	}
	
}

//获取本地图片文件的图片指针 fileNamePath:文件名路径
+(UIImage *)imageWithFileNamePath:(NSString *)fileNamePath
{
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:fileNamePath];
	
	if (!exists) {
		
		return nil;
	}
	
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:fileNamePath]];
	
	return image;
	
}

//获取本地图片文件的图片指针 fileName:文件名 aPath：不包括Document根目录的文件路径
+(UIImage *)imageWithFile:(NSString *)fileName path:(NSString*)aPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	
	NSString* strPath  = ([aPath length] > 0) ? ADD_FILEPACH(aPath, fileName) : ADD_FILEPACH(DEFAULT_FILEPATH, fileName);
	NSString* filePath = [documentsDir stringByAppendingPathComponent:strPath];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:filePath];
	
	if (!exists) {
		
		return nil;
	}
	
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
	
	return image ;
	
}

//获取本地文件Document中的头像指针
+(UIImage *)imageWithFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:filePath];
	if (!exists) {
		
		return nil;
	}
	
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
	
    return image;
}

//获取本地临时文件tmp中的头像指针
+(UIImage *)imageInTmpWithFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:filePath];
	
	if (!exists) {
		
		return nil;
	}
	
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
	
    return image;
}


//获取本地文件Document中的文件路径
+(NSString *)fullpathWithFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
    return [[NSString alloc] initWithString:filePath];
}

//获取本地临时文件tmp中的文件路径
+(NSString *)fullpathInTmpWithFile:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
    return [[NSString alloc] initWithString:filePath];
}

+ (BOOL)deleteFile:(NSString*)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        return NO;
    }
    return YES;
}
+(BOOL)fileExists:(NSString*)filePath{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end
