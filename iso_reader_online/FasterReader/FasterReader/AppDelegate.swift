//
//  AppDelegate.swift
//  FasterReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        OCAppdelegate.shared()?.window = window
        
        NotificationCenter.default.addObserver(self, selector: #selector(addOrRemoveModeView), name: NSNotification.Name(ADReaderSettingDidChangeDayMode), object: nil)
        
        return OCAppdelegate.shared().application(application, didFinishLaunchingWithOptions: launchOptions ?? nil)
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        OCAppdelegate.shared()?.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        OCAppdelegate.shared()?.applicationWillEnterForeground(application)
    }
    
    @objc func addOrRemoveModeView() {
        if MSYReaderSetting.shareInstance()!.setting.dayModel {
            let view = UIApplication.shared.keyWindow?.viewWithTag(999)
            view?.removeFromSuperview()
        }else{
            //如果已经存在就返回
            if let _  = UIApplication.shared.keyWindow?.viewWithTag(999) {
                return
            }
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = .black
            view.tag = 999
            view.alpha = 0.3
            view.isUserInteractionEnabled = false
            UIApplication.shared.keyWindow?.addSubview(view)
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.4
            }
        }
    }
}

