//
//  MSYMineDataSource.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

enum MSYMineDataSource {
    case mine
    case setting
}

extension MSYMineDataSource: JLXXTableViewDataSourceProtocol {
    
    func cellClassNames() -> Array<JLXXTableView.cellType.Type> {
        return [MSYMineCell.self]
    }
    
    func cellViewClass(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.cellType.Type {
        return MSYMineCell.self
    }
    
    func headerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType? {
        
        if self == .setting {
            return nil
        }
        let height = MSYMineHeaderView.headerViewHeight(for: tableView, with: item)
        let headerView = MSYMineHeaderView.fromNib()
        headerView.frame = CGRect(x: 0, y: 0, width: JL_SCREEN_W, height: height)
        return headerView
    }
    
    func footerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType? {
        
        if self == .mine {
            return nil
        }
        
        let height = MSYMineSettingFooterView.headerViewHeight(for: tableView, with: item)
        let footerView = MSYMineSettingFooterView.fromNib()
        footerView.frame = CGRect(x: 0, y: 0, width: JL_SCREEN_W, height: height)
        return footerView
    }
    
}


struct MSYBookCacheListDataSource: JLXXTableViewDataSourceProtocol{
    func cellClassNames() -> Array<JLXXTableView.cellType.Type> {
        return [MSYBookCacheListCell.self]
    }
    
    func cellViewClass(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.cellType.Type {
        return MSYBookCacheListCell.self
    }
    
    func canEditRow(for tableView: UITableView, at indexPath: IndexPath) -> Bool {
        return true
    }
    
}
