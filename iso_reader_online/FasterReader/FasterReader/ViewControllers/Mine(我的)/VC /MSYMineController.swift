//
//  MSYMineController.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class MSYMineController: JLXXTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height = JL_SCREEN_H - JL_TAB_BAR_H(self)
        tableView.frame = CGRect(x: 0, y: 0, width: JL_SCREEN_W, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        getUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func createDataSourceProvider() {
        provider = JLXXTableViewDataSourceProvider(dataSource: MSYMineDataSource.mine, delegate: self)
        provider.headerItem = "临时数据"
        let section0 = JLXXTableViewSectionItem()
        provider.sectionItems.append(section0)
        let shouji = (title: "绑定手机", icon: "mine_shouji_icon")
        let yuedu = (title: "阅读记录", icon: "jilu_icon_my")
        let huancun = (title: "缓存列表", icon: "xaizai_icon")
        let haoyou = (title: "邀请好友", icon: "yaoqing_icon")
        let fankui = (title: "意见反馈", icon: "yijian_icon_my")
        let shezhi = (title: "设置", icon: "shezhi_icon")
        let items = [shouji, yuedu, huancun,  haoyou, fankui, shezhi]
        for item in items {
            let model = MSYMineModel()
            model.title = item.title
            model.imageName = item.icon
            section0.rowItems.append(model)
        }
    }

    func didSelectRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) {
        
        guard let model = item as? MSYMineModel else { return }
        
        if model.title == "绑定手机", model.desTitle == "未绑定"
        {
            let bind = MSYLoginOrBindPhoneController()
            bind.type = .bindPhone
            navigationController?.pushViewController(bind, animated: true)
        }
        else if model.title == "阅读记录"
        {
            let browseHistory = MSYBookBrowseHistoryController()
            navigationController?.pushViewController(browseHistory, animated: true)
        }
        else if model.title == "缓存列表"
        {
            if JLXXAccount.shared.isLogin
            {
                let cache = MSYBookCacheListController()
                navigationController?.pushViewController(cache, animated: true)
            }
            else
            {
                startLogin()
            }
        }
        else if model.title == "邀请好友"
        {
            let fenxiang = ShareViewController()
            navigationController?.pushViewController(fenxiang, animated: true)
        }
        else if model.title == "意见反馈"
        {
            if JLXXAccount.shared.isLogin
            {
                let fankui = MSYFeedBackController()
                navigationController?.pushViewController(fankui, animated: true)
            }
            else
            {
                startLogin()
            }
        }
        else if model.title == "设置"
        {
            let setting = MSYMineSettingController()
            navigationController?.pushViewController(setting, animated: true)
        }
    }
    
    
}


extension MSYMineController {
    
    private func getUserInfo() {

        if !ZJPNetWork.netWorkAvailable() {
            ZJPAlert.show(withMessage: JPTool.noNetWorkAlert(), time: 1.5)
            return;
        }
        
        JLXXAccount.getUserInfo(success: { [weak self] in
            guard let self = self else { return }
            self.provider.headerItem = JLXXAccount.shared
            let sectionItem = self.provider.getSectionItem(at: 0)
            let model = sectionItem.rowItems[0] as? MSYMineModel
            model?.desTitle = JLXXAccount.shared.isBindPhone ? "已绑定" : "未绑定"
            self.reloadData()
        }, failed: { (errMsg) in
            ZJPAlert.show(withMessage: errMsg, time: 1.3)
        })
        
    }
    
    private func startLogin() {
        let login = MSYLoginOrBindPhoneController()
        navigationController?.pushViewController(login, animated: true)
    }
}


extension MSYMineController: MSYMineHeaderViewDelegate {
    
    func mineHeaderViewDidClickedAvatar(mineHeaderView: MSYMineHeaderView) {
        
        if JLXXAccount.shared.isLogin
        {
            let personalInfo = PersonalInfoViewController()
            navigationController?.pushViewController(personalInfo, animated: true)
        }
        else
        {
            startLogin()
        }
        
    }
    
}
