//
//  MSYBookBrowseHistoryController.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class MSYBookBrowseHistoryController: JLXXCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNav()
    }
    
    override func createDataSourceProvider() {
        let layout = UICollectionViewFlowLayout()
        let width = JL_SCREEN_W
        let height: CGFloat = 94 + 14 + 1 + 10
        layout.itemSize = CGSize(width: width, height: height)
        provider = JLXXCollectionViewDataSourceProvider(dataSource: MSYBookBrowseHistoryDataSource(), layout: layout, delegate: self)
        provider.addSectionItem(count: 1)
        getDataSource()
    }
    
    private func getDataSource() {
        let sectionItem0 = provider.getSectionItem(at: 0)
        sectionItem0.rowItems.removeAllObjects()
        if let browseHistory = MSYBrowseHistoryCache.share().getBrowseHistory() as? [MSYBrowseHistoryCacheModel] {
            sectionItem0.rowItems.addObjects(from: browseHistory)
        }
    }

    
    func didSelect(for collectionView: UICollectionView, with item: Any?, at indexPath: IndexPath) {
        if let cacheModelModel = item as? MSYBrowseHistoryCacheModel
        {
            //跳转到阅读界面
            let reading = ADPageViewController()
            reading.cover = cacheModelModel.cover
            reading.bookId = cacheModelModel.bookId
            reading.bookName = cacheModelModel.bookName
            reading.lastChapter = cacheModelModel.lastChapter
            reading.author = cacheModelModel.author
            reading.majorCate = cacheModelModel.majorCate
            reading.updated = cacheModelModel.updated
            navigationController?.pushViewController(reading, animated: true)
        }
    }

}

// MARK: - 导航栏相关设置
extension MSYBookBrowseHistoryController {
    
    private func setUpNav() {
        let titleView = UILabel(frame: CGRect(x: 0, y: 0 , width: 180, height: 44))
        titleView.text = "阅读记录"
        titleView.textAlignment = .center
        titleView.font = JLPingFangSCFont(style: "Semibold", size: 16.0)
        titleView.textColor = COLOR_666666
        navigationItem.titleView = titleView
        
        //右按钮
        let right = UIButton(type: .custom)
        right.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        right.titleLabel?.font = JLPingFangSCFont(size: 14.0)
        right.setTitle("清空  ", for: .normal)
        right.setTitleColor(COLOR_666666, for: .normal)
        right.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)
    }
    
    @objc private func rightButtonClick() {
        clearCache()
    }
    
    //清空缓存
    private func clearCache() {
        let clearBrowse = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            MSYBrowseHistoryCache.share().removeBrowseHistory()
            self.getDataSource()
            self.reloadData()
        }
        
        JLXXAlertController.alert(title: "清空阅读记录", cancelTitle: "取消", presentingController: self, actions: [clearBrowse])
    }

}
