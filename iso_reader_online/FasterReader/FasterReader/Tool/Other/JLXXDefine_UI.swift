//
//  JLXXDefine_UI.swift
//  Wallet
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

let ChangeLanguangeKey = "jl_app_language"
let CnLanguange = "zh-Hans"
let EnLanguange = "en"

/** 颜色(RGB) */
func JLRGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
	return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
}

/** 字体大小 */
func JLPingFangSCFont(style: String = "Regular", size: CGFloat) -> UIFont {
	if let font = UIFont(name: "PingFangSC-" + style, size: size) {
		return font
	}
	return UIFont.systemFont(ofSize: size)
}

let SelectedColor = JLRGB(251, 68, 55) //#FB4437
let NormalColor = JLRGB(117,117,117) //#757575

let COLOR_333333 = UIColor.init(hexString: "#333333")
let COLOR_F0F0F0 = UIColor.init(hexString: "#F0F0F0")
let COLOR_666666 = UIColor.init(hexString: "#666666")

let COLOR_999999 = UIColor.init(hexString: "#999999")
let COLOR_FB4437 = UIColor.init(hexString: "#FB4437")
let COLOR_E5E5E5 = UIColor.init(hexString: "#E5E5E5")
let COLOR_F43F36 = UIColor.init(hexString: "#F43F36")
let COLOR_F6F6F6 = UIColor.init(hexString: "#F6F6F6")
let COLOR_BDBDBD = UIColor.init(hexString: "#BDBDBD")
let COLOR_FFF1CE = UIColor.init(hexString: "#FFF1CE")


/** 当前语言 */
/*
若当前系统为英文，则返回en_US
*/

/*
若当前系统为中文
iOS8是
zh-Hans: 简体
zh-Hant: 繁体
zh-HK: 香港繁体（增加）

iOS9是
zh-Hans-CN: 简体（改变）
zh-Hant-CN: 繁体（改变）
zh-HK: 香港繁体

zh-TW:  台湾繁体（增加）

iOS9时，中英文都在后面加了地区，如：zh-Hans-CN  zh-Hans-US  en-CN  en-US
*/
func CurrentLanguage() -> String {
	let defs = UserDefaults.standard
	//系统语言的集合
	guard let languages = defs.object(forKey: "AppleLanguages") as? Array<Any>,
		//集合元素为大于0
		languages.count > 0,
		//集合第一个元素为当前语言
		let currentLanguage = languages[0] as? String else { return "zh-Hans" }
	
	if currentLanguage.hasPrefix("zh") {
		return "zh_cn"
	}
	return "en_us"
}

func CurrencySymbol() -> String{
	let currentLanguage = CurrentLanguage()
	if currentLanguage.hasPrefix("zh") {
		return "¥"
	}
	return "$"
}

func CoinSymbolNamed(_ coin_symbol: String?) -> String{
	guard let symbol = coin_symbol else { return "" }
	
	if symbol.lowercased().contains("bt")  {
		return "icon_btc_market"
	}else {
		return "icon_eth_market"
	}
}

func LocalizedString(_ key: String) -> String {
	var laguageKey: String
	if let theKey = UserDefaults.standard.string(forKey: ChangeLanguangeKey) {
		laguageKey = theKey
	}else {
		laguageKey = CurrentLanguage().hasPrefix("zh") ? CnLanguange : EnLanguange
	}
	guard let path = Bundle.main.path(forResource: laguageKey, ofType: "lproj") else { return "" }
	guard let bundle =  Bundle(path: path) else { return "" }
	
	return bundle.localizedString(forKey: key, value: "", table: nil)
}
//#define JLXXLocalizedString(key, comment)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:so ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]



/** 当前国家 */
//let JL_LOCAL_COUNTRYNSLocale currentLocale objectForKey:NSLocaleCountrJLode


