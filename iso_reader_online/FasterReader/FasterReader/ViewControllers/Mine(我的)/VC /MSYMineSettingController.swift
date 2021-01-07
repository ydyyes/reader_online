//
//  MSYMineSettingController.swift
//  FasterReader
//
//  Created by apple on 2019/7/3.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit
import SVProgressHUD

class MSYMineSettingController: JLXXTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "设置"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getDataSource()
        self.reloadData()

    }
    
    override func createDataSourceProvider() {
        provider = JLXXTableViewDataSourceProvider(dataSource: MSYMineDataSource.setting, delegate: self)
        provider.addSectionItem(count: 1)
    }
    
    private func getDataSource() {
        let section0 = provider.getSectionItem(at: 0)
        provider.footerItem = JLXXAccount.shared
        section0.rowItems.removeAllObjects()
        let ziliao = (title: "编辑资料", icon: "", des: "")
        let sortTypeTitle: String
        if JPTool.bookshelfSortType() == .readTime {
            sortTypeTitle = "按最近阅读"
        }else {
            sortTypeTitle = "按更新时间"
        }
        let paixu = (title: "书架排序", icon: "", des: sortTypeTitle)
        let clear = (title: "清除缓存", icon: "", des: cacheSize())
        let items = [ziliao, paixu, clear]
        for item in items {
            let model = MSYMineModel()
            model.title = item.title
            model.imageName = item.icon
            model.desTitle = item.des
            section0.rowItems.append(model)
        }
    }

    func didSelectRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) {
        
        guard let model = item as? MSYMineModel else { return }
        
        if model.title == "编辑资料"
        {
            if JLXXAccount.shared.isLogin
            {
                let personalInfo = PersonalInfoViewController()
                navigationController?.pushViewController(personalInfo, animated: true)
            }
            else
            {
                let login = MSYLoginOrBindPhoneController()
                navigationController?.pushViewController(login, animated: true)
            }
        }
        else if model.title == "书架排序"
        {
            excuteSort()
        }
        else if model.title == "清除缓存"
        {
            clearCache()
        }
    }
    
    //排序
    private func excuteSort() {
        let readTimeAction = UIAlertAction(title: "按最近阅读", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            JPTool.changeBookshelfSortType(with: .readTime)
            self.getDataSource()
            self.reloadData()
        }
        
        let updateTimeAction = UIAlertAction(title: "按更新时间", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            JPTool.changeBookshelfSortType(with: .updateTime)
            self.getDataSource()
            self.reloadData()
        }
        JLXXAlertController.alert(title: "书架排序", cancelTitle: "取消", presentingController: self, actions: [readTimeAction, updateTimeAction])
    }

    //清空缓存
    private func clearCache() {
        let clearBrowse = UIAlertAction(title: "清空阅读记录", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: true, bookShelf: false)
        }
        
        let clearBookShelf = UIAlertAction(title: "清空书架列表", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: false, bookShelf: true)
        }
        let clearAll = UIAlertAction(title: "清空阅读记录和书架列表", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.clearKindOfCache(browseHistory: true, bookShelf: true)
        }
        JLXXAlertController.alert(title: "清除缓存", cancelTitle: "取消", presentingController: self, actions: [clearBrowse, clearBookShelf, clearAll])
    }
    
    private func clearKindOfCache(browseHistory: Bool, bookShelf: Bool) {
    
        SVProgressHUD.show(withStatus: "缓存清理中...")
        
        if browseHistory {
            MSYBrowseHistoryCache.share().removeBrowseHistory()
        }
        if bookShelf {
            ADSherfCache.removeAllBooks()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            SVProgressHUD.dismiss()
            self.getDataSource()
            self.reloadData()
        }
    }
    
    private func cacheSize() -> String {
        let bookInfoSize = SZKCleanCache.fileSize(withPath: FasterReaderBookInfoCache)
//        let bookChaptersSize = SZKCleanCache.fileSize(withPath: FasterReaderChaptersCache)
        let res = bookInfoSize
        return String(format: "%.2f M", res)
    }
    
}


extension MSYMineSettingController: MSYMineSettingFooterViewDelegate {
    
    func msyMineSettingFooterViewLoginOrLogout(mineSettingFooterView: MSYMineSettingFooterView, isLogin: Bool) {

        if isLogin {
            let login = MSYLoginOrBindPhoneController()
            navigationController?.pushViewController(login, animated: true)
        }else {
            JLXXAccount.resetUserInfo()
            getDataSource()
            reloadData()
        }
    }
    
}
