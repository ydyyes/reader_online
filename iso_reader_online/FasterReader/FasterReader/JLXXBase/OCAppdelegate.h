//
//  OCAppdelegate.h
//  FasterReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 Restver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootTabBarController.h"
#import "IntroduceViewController.h"

#import "GDTSplashAd.h"

#import <BUAdSDK/BUAdSDKManager.h>
#import "BUAdSDK/BUSplashAdView.h"


@interface OCAppdelegate : NSObject<GDTSplashAdDelegate,BUSplashAdDelegate>

+ (instancetype)shared;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions ;

- (void)applicationDidEnterBackground:(UIApplication *)application ;

- (void)applicationWillEnterForeground:(UIApplication *)application ;

@property (strong, nonatomic) UIWindow *window;


@end
