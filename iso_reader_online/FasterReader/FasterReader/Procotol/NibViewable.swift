//
//  NibViewable.swift
//  Wallet
//
//  Created by apple on 2018/6/8.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

protocol NibViewable{
//	static func fromNib() -> Self
	static func fromNib(for index: Int) -> Self

}

extension NibViewable where Self : UIView {
//	static func fromNib() -> Self {
//		return Bundle(for: self).loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
//	}
	static func fromNib(for index: Int = 0) -> Self {
		return Bundle(for: self).loadNibNamed("\(self)", owner: nil, options: nil)?[index] as! Self
	}
}
