//
//  JLXXViewController.swift
//  TTT
//
//  Created by apple on 2018/9/13.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

open class JLXXViewController: UIViewController {

	var nodataContainerView: UIView?

	open override func viewDidLoad() {
        super.viewDidLoad()
		
		automaticallyAdjustsScrollViewInsets = false
		extendedLayoutIncludesOpaqueBars = true
		view.backgroundColor = UIColor.white
		
	}

	deinit {
		debugPrint("--------------deinit \(self)-------------")
	}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}
	
	func pushToViewController(_ controller: JLXXViewController, animated: Bool = true) {
		
		navigationController?.pushViewController(controller, animated: animated)
	}
	
}


extension JLXXViewController {
	
	func showNodaView(_ text: String? = "暂无数据...", imageName: String = "img_zanwushuju") {
		
		if let containerView = nodataContainerView {
			for view in containerView.subviews {
				view.removeFromSuperview()
			}
		}
		nodataContainerView?.removeFromSuperview()
		
		let y = view.bounds.height / 4.5
		let width: CGFloat = view.bounds.width
		let height: CGFloat = 170
		let x: CGFloat = 0.0
		let centerX = width / 2.0
		
		let containerView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
		view.addSubview(containerView)
		containerView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
		nodataContainerView = containerView

		let nodataImageView = UIImageView(image: UIImage.init(named: imageName))
		containerView.addSubview(nodataImageView)
		let imageVieweHight = nodataImageView.bounds.height
		nodataImageView.center = CGPoint(x: centerX, y: imageVieweHight / 2.0)
		
		let nodataLabel = UILabel()
		containerView.addSubview(nodataLabel)
		nodataLabel.textAlignment = .center
		nodataLabel.font = JLPingFangSCFont(size: 14.0)
		nodataLabel.textColor = COLOR_333333
		nodataLabel.text = text
		nodataLabel.numberOfLines = 0
		nodataLabel.sizeToFit()
		let nodataLabelY = nodataImageView.frame.maxY + 10.0
		let labelHight: CGFloat = nodataLabel.bounds.height
		nodataLabel.frame = CGRect(x: 0, y: nodataLabelY, width: centerX, height: labelHight)
		nodataLabel.center = CGPoint(x: centerX, y: nodataLabel.center.y)

	}
	
	func hiddenNodaView() {
		nodataContainerView?.removeFromSuperview()
		nodataContainerView = nil
	}
	
}
