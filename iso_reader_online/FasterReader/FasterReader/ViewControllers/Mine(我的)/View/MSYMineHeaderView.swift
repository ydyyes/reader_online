//
//  MSYMineHeaderView.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

protocol MSYMineHeaderViewDelegate: class {
    func mineHeaderViewDidClickedAvatar(mineHeaderView: MSYMineHeaderView)
}

class MSYMineHeaderView: UIView, NibViewable, JLXXTableHeaderViewProtocol {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var recomendCodeLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    
    weak var delegate: AnyObject?
    weak var mineHeaderDelegate: MSYMineHeaderViewDelegate? {
        return delegate as? MSYMineHeaderViewDelegate
    }
    
    static func headerViewHeight(for tableView: UITableView, with item: Any?) -> CGFloat {
        return 148 + 8
    }
    
    func setItem(item: Any?) {
        
        guard let model = item as? JLXXAccount else { return }
        
        avatarImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "touxiang"))
        userNameLabel.text = model.nickname
        recomendCodeLabel.text = "推荐码: \(model.invitation_code)"
        userTypeLabel.text = model.u_type
        //已登录,就隐藏这个label
        loginLabel.isHidden = model.isLogin
        
    }
    
    @IBAction func clickUserAvatar(_ sender: UIButton) {
        mineHeaderDelegate?.mineHeaderViewDidClickedAvatar(mineHeaderView: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.layer.masksToBounds = true
    }
    
}
