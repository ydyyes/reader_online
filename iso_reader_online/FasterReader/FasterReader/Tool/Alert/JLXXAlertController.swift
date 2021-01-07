//
//  JLXXAlertController.swift
//  JinglanEx
//
//  Created by apple on 2018/9/17.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

struct JLXXAlertController {
	
	typealias JLXXAlertClosure = () -> ()
	
    static func alert(_ style: UIAlertController.Style = .alert, title: String? = nil, message: String? = nil, cancelTitle: String? = nil, destructiveTitle: String? = nil, presentingController: UIViewController, actions: [UIAlertAction], cancelCallBack: JLXXAlertClosure? = nil, destrCallback: JLXXAlertClosure? = nil) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
		
		/// 取消按钮
		if cancelTitle != nil {
			let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
				
				if cancelCallBack != nil {
					cancelCallBack?()
				}
			}
			alertController.addAction(cancelAction)
		}
		
		/// destructive按钮
		if destructiveTitle != nil {
			let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { (action) in
				
				if destrCallback != nil {
					destrCallback?()
				}
			}
			alertController.addAction(destructiveAction)
		}
		
		// 循环添加action
		for action in actions {
			alertController.addAction(action)
		}
		
		// show
		presentingController.present(alertController, animated: true, completion: nil)
	}
}
