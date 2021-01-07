//
//  NavgationController.swift
//  TTT
//
//  Created by apple on 2018/9/13.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

class JLXXNavgationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
        
    }

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		
		if children.count > 0 {
			// 隐藏底部导航栏
			viewController.hidesBottomBarWhenPushed = true
			// 自定义返回按钮
			let backBtn = UIButton(type: .custom)
			backBtn.setImage(UIImage.init(named: "fanhui_icon"), for: .normal)
			backBtn.addTarget(self, action: #selector(popBack), for: .touchUpInside)
			backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -22, bottom: 0, right: 0)
			viewController.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: backBtn)
			// 如果自定义返回按钮后, 滑动返回可能失效, 需要添加下面的代码
			let recognizerDelegate = viewController as? UIGestureRecognizerDelegate
			interactivePopGestureRecognizer?.delegate = recognizerDelegate
		}
		super.pushViewController(viewController, animated: animated)
	}
	
	@objc private func popBack() {
		popViewController(animated: true)
	}
}
