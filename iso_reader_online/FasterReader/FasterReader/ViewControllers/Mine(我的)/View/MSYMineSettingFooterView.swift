//
//  MSYMineSettingFooterView.swift
//  FasterReader
//
//  Created by apple on 2019/7/4.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit

protocol MSYMineSettingFooterViewDelegate: class {
    func msyMineSettingFooterViewLoginOrLogout(mineSettingFooterView: MSYMineSettingFooterView, isLogin: Bool)
}

class MSYMineSettingFooterView: UIView, NibViewable, JLXXTableHeaderViewProtocol {
    
    @IBOutlet weak var loginOrLoginoutButton: UIButton!
    
    weak var delegate: AnyObject?
    weak var mineSettingFooterDelegate: MSYMineSettingFooterViewDelegate? {
        return delegate as? MSYMineSettingFooterViewDelegate
    }
    static func headerViewHeight(for tableView: UITableView, with item: Any?) -> CGFloat {
        return 55
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loginOrLoginoutButton.layer.cornerRadius = 8
        loginOrLoginoutButton.layer.masksToBounds = true
    }
    
    func setItem(item: Any?) {
        guard let model = item as? JLXXAccount else { return }
        if model.isLogin {
            loginOrLoginoutButton.setTitle("退出", for: .normal)
        }else{
            loginOrLoginoutButton.setTitle("登录", for: .normal)
        }
    }
    
    @IBAction func loginOrLoginoutButtonClick(_ sender: UIButton) {
        
       let isLogin = sender.titleLabel?.text == "登录"
        mineSettingFooterDelegate?.msyMineSettingFooterViewLoginOrLogout(mineSettingFooterView: self, isLogin: isLogin)
    }
    
}
