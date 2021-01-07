//  程序公用信息处理
//  Utils.m
//  SK
//
//  Created by luke on 10-10-22.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "Utils.h"
#import "FasterReader-Swift.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define MAJOR_VERSION                           1
#define MINOR_VERSION                           0
#define THIRD_VERSION                             2
#define DATE_VALUE                              6017
#define IPHONE_IOS                              2
#define IPAD_IOS                                2

#define IMAGES_INFO_NAME                        (@"images.dat")

@implementation Utils

//把UIView 转换成图片
+(UIImage *)getImageFromView:(UIView *)aView{
    UIGraphicsBeginImageContext(aView.frame.size);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(NSString*)getNowTime{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];
    //    NSLog(@"%@",timeString);
    return timeString;
}

+ (BOOL)checkImageExist:(NSString*)imageName type:(int)aType
{
    NSString* filePath = GET_IMAGE_PATH(imageName, aType);
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+(BOOL)deleteImageName:(NSString*)fileName
{
    return [FileMgr deleteImageWithName:fileName];
}

+(BOOL)saveImageName:(NSString*)fileName image:(UIImage*)anImage
{
    return [FileMgr saveImageWithName:fileName image:anImage];
}

+(NSString*)getImagePathByName:(NSString*)fileName type:(int)aType
{
    return [FileMgr getImagePathWithName:fileName type:aType];
}
//
+(NSString*)getCardImagePathByName:(NSString*)fileName
{
    return [FileMgr getImagePathWithName:fileName type:IMG_SOURCE_CARD_IMG];
}
+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isRunningOniPad:(__unused NSString *)osVer {
    
    static BOOL hasCheckedDeviceType = NO;
    static BOOL isRunningOniPad = NO;
    
    if (!hasCheckedDeviceType) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                isRunningOniPad = YES;
                hasCheckedDeviceType = YES;
                return isRunningOniPad;
            }
        }
        
        hasCheckedDeviceType = YES;
    }
    
    return isRunningOniPad;
}

+ (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
    
}


+ (NSString*)URLencode:(NSString *)originalString
        stringEncoding:(NSStringEncoding)stringEncoding {
    //!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
    //%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,    @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    
    NSInteger len = [escapeChars count];
    
    NSMutableString *temp = [[originalString
                              stringByAddingPercentEscapesUsingEncoding:stringEncoding]
                             mutableCopy];
    
    int i;
    for (i = 0; i < len; i++) {
        
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    NSString *outStr = [NSString stringWithString: temp];
    
    return outStr;
}


//把服务器拿到的时间转换为字符串
+ (NSString *)calcCreateTime:(NSString *)cTime
{
    NSString *resultTime = @"";
    NSDate *now = [NSDate date];
    NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:[cTime floatValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit
    | NSMonthCalendarUnit
    | NSDayCalendarUnit
    | NSHourCalendarUnit
    | NSMinuteCalendarUnit
    | NSSecondCalendarUnit
    | NSWeekdayCalendarUnit;
    
    //计算时间差
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:lastTime toDate:now options:0];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    
    NSDateComponents *lastComps = [gregorian components:unitFlags fromDate:lastTime];
    NSInteger cYear = [lastComps year];
    NSInteger cMonth = [lastComps month];
    NSInteger cDay = [lastComps day];
    NSInteger cHour = [lastComps hour];
    NSInteger cMinute = [lastComps minute];
    
    NSDateComponents *todayComps = [gregorian components:unitFlags fromDate:now];
    NSInteger todayDay = [todayComps day];
    
    //特殊判断并处理
    BOOL isYesterday = NO;
    if ((day == 0 && todayDay - cDay !=0)|(day == 1 && todayDay - cDay == 1)) {
        isYesterday = YES;
    }else if (cMonth == 2){
        if (day == 1 && cDay -todayDay == 27) {
            isYesterday = YES;
        }
    }else if(cMonth == 1 |cMonth == 3 |cMonth == 5 |cMonth == 7| cMonth == 8|cMonth == 10|cMonth == 12){
        if (day == 1 && cDay -todayDay == 30) {
            isYesterday = YES;
        }
    }else{
        if (day == 1 && cDay -todayDay == 29) {
            isYesterday = YES;
        }
    }
    
    if (!year && !month && !day && !hour && minute <= 0 && second < 60) {
        // < 1min
        resultTime = @"刚刚";
    } else if (!year && !month && !day && hour <= 0 &&  minute  < 60 ) {
        // <1hour
        resultTime = [NSString stringWithFormat:@"%zi分钟前",minute];
    } else if (!year && !month && day == 0 && !isYesterday) {
        // <1day
        resultTime = [NSString stringWithFormat:@"今天 %02zi:%02zi",cHour, cMinute];
    } else if (!year && !month && isYesterday) {
        // 1day< <2days
        resultTime = [NSString stringWithFormat:@"昨天 %02zi:%02zi",cHour, cMinute];
    } else if (!year && !month && day >= 1 && !isYesterday) {
        // >= 2days
        resultTime = [NSString stringWithFormat:@"%zi-%zi %02zi:%02zi", cMonth, cDay, cHour, cMinute];
    } else {
        resultTime = [NSString stringWithFormat:@"%zi-%zi-%zi",cYear, cMonth, cDay];
    }
    return resultTime;
}
//计算剩余时间
+ (NSString *)calcOverTime:(NSString *)overTime
{
    NSString *resultTime = @"";
    NSDate *now = [NSDate date];
    NSString *nowTime = [NSString stringWithFormat:@"%zd",(long)[now timeIntervalSince1970]];
    float subTime = [overTime floatValue] - [nowTime floatValue];
    
    int time = subTime/60/60/24;
    if (time > 0) {
        resultTime = [NSString stringWithFormat:@"%d天",time];
    }else{
        time = subTime/60/60;
        if (time > 0) {
            resultTime = [NSString stringWithFormat:@"%d小时",time];
        }else{
            time = subTime/60;
            if (time > 0) {
                resultTime = [NSString stringWithFormat:@"%d分",time];
            }else{
                resultTime = @"-1";
            }
        }
    }
    return resultTime;
}
////计算剩余时间
//+ (NSString *)calcOverTime:(NSString *)overTime
//{
//	NSString *resultTime = [NSString string];
//	NSDate *now = [NSDate date];
//    NSDate *over = [NSDate dateWithTimeIntervalSince1970:[overTime floatValue]];
//	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//	unsigned unitFlags = NSYearCalendarUnit
//	| NSMonthCalendarUnit
//	| NSDayCalendarUnit
//	| NSHourCalendarUnit
//	| NSMinuteCalendarUnit
//	| NSSecondCalendarUnit
//	| NSWeekdayCalendarUnit;
//	NSDateComponents *comps = [gregorian components:unitFlags fromDate:now toDate:over options:0];
//	NSInteger year = [comps year];
//	NSInteger month = [comps month];
//	NSInteger day = [comps day];
//	NSInteger hour = [comps hour];
//	NSInteger minute = [comps minute];
//    
//	if (!year && !month && !day && !hour && minute < 60) {
//		// < 1hour
//        resultTime = [NSString stringWithFormat:@"%d分",minute];
//	}
//    else if (!year && !month && !day && hour < 24 ) {
//		// < 1day
//		resultTime = [NSString stringWithFormat:@"%d小时",hour];
//	}
//    else if (year*365 + month*30 + day > 0) {
//		// >= 1day
//		resultTime = [NSString stringWithFormat:@"%d天",year*365 + month*30 + day];
//	}else{
//        //过期
//        resultTime = @"-1";
//    }
//	return resultTime;
//}

+ (void)downLoadImageWithUrl:(NSString *)aUrl
                        path:(NSString *)aPath
                      target:(id)aDelegate
              FinishedAction:(SEL)aCBSuccess
                FailedAction:(SEL)aCBFailed
{
    if ([aUrl length] <= 0)
        return ;
    
    
}

//+(CGSize)getScreenCGRectSize{
//    CGSize size;
//    if (([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)) {
//        size.width = [JPTool screenWidth];
//        size.height = 568;
//    }else{
//        size.width = [JPTool screenWidth];
//        size.height = 480;
//    }
//    return size;
//}
+(UIImage*)croppingImageWithSize:(UIImage*)image targetSize:(CGSize)size{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, size) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        //        NSLog(@"could not scale image");
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
    return newImage;
}
+(BOOL)isbreakformapp
{
    NSInteger bIn = YES;
    NSString *output = [NSString string];
    FILE *pipe = popen([@"ls" cStringUsingEncoding: NSASCIIStringEncoding], "r");
    if (!pipe) return YES;
    char buf[1024];
    while(fgets(buf, 1024, pipe))
    {
        bIn = NO;
        output = [output stringByAppendingFormat: @"%s", buf];
    }
    
    pclose(pipe);
    return bIn;
}

+ (NSString *)cutString:(NSString *)string utilFitWidth:(float)width{
    
    string = [string substringToIndex:[string length] - 1];
    NSString *tempString = [NSString stringWithFormat:@"%@..",string];
    CGSize size = [tempString sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(2000, 17)];
    if (size.width > width) {
        string = [Utils cutString:string utilFitWidth:width];
    }
    return string;
}
+ (BOOL)parseUserName:(NSString *)string{
    NSString *regStr = @"(^-?[1-9]\\d*$)|(^[\\-_])";
    //使用系统类库实现正则
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regStr options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray *array = [reg matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    if ([array count]) {
        return NO;
    }
    return YES;
}

+(NSString*)resultClientId{
    
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

#pragma mark - 获取ip

+(NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}
+ (NSString *)localIPAddress
{
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    break;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    
    return [addresses count] ? addresses : nil;
}
//md5
NSString* md5Digest(NSString* str)
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}
/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */

+ (BOOL)hasEmoji:(NSString*)string
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}
/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

/**
 判断是不是九宫格
 @param string  输入的字符
 @return YES(是九宫格拼音键盘)
 */
+ (BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}
//-----过滤字符串中的emoji
+ (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
//去除导航栏底部的线
+ (UIImageView*)findHairlineImageViewUnder:(UIView*)view {
    
    if([view isKindOfClass:UIImageView.class] && view.bounds.size.height<=1.0){
        return(UIImageView*)view;
    } for(UIView* subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if(imageView) {
            return imageView;
        }
    }
    return nil;
}
+ (void)cutImage:(UIImageView *)aImage
{
    aImage.contentMode      =  UIViewContentModeCenter;
    [aImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    aImage.contentMode      =  UIViewContentModeScaleAspectFill;
    aImage.clipsToBounds    = YES;
    aImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}
@end

