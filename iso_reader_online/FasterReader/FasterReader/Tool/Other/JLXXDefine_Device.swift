//
//  JLXXDefine_Device.swift
//  Wallet
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

/** 应用程序的主window */
let JL_APP_KEYWINDOW = UIApplication.shared.keyWindow
/** 屏幕的bounds */
let JL_APP_BOUNDS   = UIScreen.main.bounds
/** 主屏幕的高度 */
let JL_SCREEN_H = UIScreen.main.bounds.size.height
/** 主屏幕的宽度 */
let JL_SCREEN_W = UIScreen.main.bounds.size.width
/** 屏幕的分辨率 当结果为1时，显示的是普通屏幕，结果为2时，显示的是Retian屏幕 */
let JL_M_SCREEN_SCALE = UIScreen.main.scale

/** 主屏幕的高度比例 */
func JL_SCREEN_H_SCALE() -> CGFloat{
	return JL_SCREEN_H / 667.0
}
/** 主屏幕的宽度比例 */
func JL_SCREEN_W_SCALE() -> CGFloat{
	return JL_SCREEN_W / 375.0
}

/** 系统控件的默认高度 */
//状态栏
let JL_STATUS_BAR_H = UIApplication.shared.statusBarFrame.size.height
//导航条
func JL_NAV_BAR_H(_ controller: UIViewController) -> CGFloat{
	if let navigationController = controller.navigationController {
		return navigationController.navigationBar.bounds.height
	}
	return 0.0 
}
//状态栏和导航条
func JL_STATUS_NAV_BAR_H(_ controller: UIViewController) -> CGFloat{
	return JL_STATUS_BAR_H + JL_NAV_BAR_H(controller)
}
//tabbar的高度
func JL_TAB_BAR_H(_ controller: UIViewController) -> CGFloat{
	if let tabBarController = controller.tabBarController, !controller.hidesBottomBarWhenPushed {
		return tabBarController.tabBar.bounds.size.height
	}
	return 0.0
}

func JL_View_H_WithOut_Nav(_ controller: UIViewController) -> CGFloat{
	return JL_SCREEN_H - JL_NAV_BAR_H(controller)
}
func JL_View_H_WithOut_Status() -> CGFloat{
	return JL_SCREEN_H - JL_STATUS_BAR_H
}

func JL_View_H_WithOut_Status_Nav(_ controller: UIViewController) -> CGFloat{
	return JL_SCREEN_H - JL_STATUS_NAV_BAR_H(controller)
}

func JL_View_H_WithOut_Tab(_ controller: UIViewController) -> CGFloat{
	return JL_SCREEN_H - JL_TAB_BAR_H(controller)
}

func JL_View_H_WithOut_All_Bar(_ controller: UIViewController) -> CGFloat{
	return JL_SCREEN_H - JL_STATUS_NAV_BAR_H(controller) - JL_TAB_BAR_H(controller)
}


/** 系统的版本号 */
let JL_SYSTEM_VERSION = Double(UIDevice.current.systemVersion)
/** ios 9.0 及以后 */
let JL_IS_IOS9_LATER = Double(UIDevice.current.systemVersion)! >= 9.0 ? true : false
/** ios 10.0 及以后 */
let JL_IS_IOS10_LATER = Double(UIDevice.current.systemVersion)! >= 10.0 ? true : false
/** ios 11.0 及以后 */
let JL_IS_IOS11_LATER = Double(UIDevice.current.systemVersion)! >= 11.0 ? true : false

/** APP版本号 */
func JL_APP_VERSION() -> String {
	let infoDictionary = JL_APP_InfoDictionary()
	return infoDictionary["CFBundleShortVersionString"] as! String
}

/** APP BUILD 版本号 */
func JL_APP_BUILD_VERSION() -> String {
	let infoDictionary = JL_APP_InfoDictionary()
	return infoDictionary["CFBundleVersion"] as! String
}

/** APP名字 */
func JL_APP_DISPLAY_NAME() -> String {
	let infoDictionary = JL_APP_InfoDictionary()
	return infoDictionary["CFBundleDisplayName"] as! String
}

func JL_APP_InfoDictionary() -> [String:Any] {
	let infoDictionary = Bundle.main.infoDictionary
	return infoDictionary!
}

func JL_SafeAreaInset(view: UIView) -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return view.safeAreaInsets;
    }
    return .zero;
}

/** 设备判断 */
//let JL_IS_IPHONE = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiomPhone
//let JL_IS_PAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

/** iPhone的型号 */
//let JL_IS_IPHONE5 = UIScreen.main.bounds.size.height == 568
//let JL_IS_IPHONE6 = UIScreen.main.bounds.size.height == 667
//let JL_IS_IPHONE6_PLUS = UIScreen.main.bounds.size.height == 736

