//
//  TableView.swift
//  TTT
//
//  Created by cnsuer on 2018/8/15.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

open class JLXXTableView: UITableView {
	
	public typealias headerViewType = (UIView & JLXXTableHeaderViewProtocol)
	public typealias sectionViewType = (UIView & JLXXTableSectionViewProtocol)
	public typealias cellType = (UITableViewCell & JLXXTableViewCellProtocol)
	
    /// 当选中行后,是否自动取消选中状态
    public var deselectRowWhenSelectRow = true
    
	internal weak var jlxxDelegate: JLXXTableViewProtocol?
	internal weak var refreshDelegate: JLXXTableViewRefreshProtocol?
	
	private var headerView: JLXXTableView.headerViewType?
	private var sectionViews: Dictionary<String, sectionViewType> = [:]
    
    public var isHadRefreshAction: Bool = false {
        willSet(isHadRefresh){
            if isHadRefreshAction == isHadRefresh { return }
            if isHadRefresh {
                mj_header = MJRefreshNormalHeader { [weak self] in
                    guard let this = self else { return }
                    this.refreshDelegate?.pullDownToRefresh()
                }
            }else {
                mj_header = nil
            }
        }
    }
    
    public var isHadLoadMoreAction: Bool = false {
        willSet(isHadLoadMore){
            if isHadLoadMoreAction == isHadLoadMore { return }
            if isHadLoadMore {
                mj_footer = MJRefreshAutoNormalFooter { [weak self] in
                    guard let this = self else { return }
                    this.refreshDelegate?.pullUpToLoadMore()
                }
            }else {
                mj_footer = nil
            }
        }
    }
	
	
	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		separatorColor = UIColor.clear
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		separatorStyle = .none
		keyboardDismissMode = .onDrag //UIScrollViewKeyboardDismissModeOnDrag;
		delegate = self
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    func jlxxResetFooter() {
        isHadLoadMoreAction = false
        mj_footer = nil
    }
    
    func jlxxStartRefreshing() {
        if let header = mj_header {
            header.beginRefreshing()
        }
    }
    
    func jlxxStopRefreshing() {
        if let header = mj_header, header.isRefreshing {
            header.endRefreshing()
        }
        if let footer = mj_footer, footer.isRefreshing {
            footer.endRefreshing()
        }
    }
    
    func endLoadWithNoMoreData() {
        if let footer = mj_footer, footer.isRefreshing {
            mj_footer.endRefreshingWithNoMoreData()
        }
    }
	
	open override func reloadData() {
		guard let provider = dataSource as? JLXXTableViewDataSourceProvider else {
			
			super.reloadData()
			return
		}
        
        let headerItem = provider.headerItem
        if let view = provider.dataSource.headerView(for: self, with: headerItem) {
            self.tableHeaderView = view
			view.delegate = provider.delegate
            view.setItem(item: headerItem)
		}
        
        let footerItem = provider.footerItem
        if let view = provider.dataSource.footerView(for: self, with: footerItem) {
            self.tableFooterView = view
            view.delegate = provider.delegate
            view.setItem(item: footerItem)
        }

		super.reloadData()

	}
}

extension JLXXTableView: UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let provider = tableView.dataSource as? JLXXTableViewDataSourceProvider else { return 0 }
		let item = provider.rowItem(for: tableView, at: indexPath)
		let cellClass = provider.dataSource.cellViewClass(for: tableView, with: item, at: indexPath.section)
		let rowHeight = cellClass.rowHeight(for: tableView, with: item, at: indexPath)
		return rowHeight
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let provider = tableView.dataSource as? JLXXTableViewDataSourceProvider else { return 0 }
		let sectionHeaderItem = provider.sectionItems[section].sectionHeaderItem
		guard let headerViewClass = provider.dataSource.sectionHeaderViewClass(for: tableView, with: sectionHeaderItem, at: section) else { return 0 }
		return headerViewClass.sectionViewHeight(for: tableView, with: sectionHeaderItem, at: section)
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		guard let provider = tableView.dataSource as? JLXXTableViewDataSourceProvider else { return nil }
		let sectionHeaderItem = provider.sectionItems[section].sectionHeaderItem

		let stringSection = String(section)
		if provider.isUseCacheView, let headerView = sectionViews[stringSection] {
			headerView.setItem(item: sectionHeaderItem, at: section)
			return headerView
		}
		
		if let headerView = provider.dataSource.sectionHeaderView(for: tableView, with: sectionHeaderItem, at: section){
			headerView.delegate = provider.delegate
			headerView.setItem(item: sectionHeaderItem, at: section)
			sectionViews[stringSection] = headerView
			return headerView
		} else {
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
		guard let provider = dataSource as? JLXXTableViewDataSourceProvider else { return }
		
		let item = provider.rowItem(for: tableView, at: indexPath)
		jlxxDelegate?.didSelectRow?(for: tableView, with: item, at: indexPath)
        
        if deselectRowWhenSelectRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
	}
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let provider = dataSource as? JLXXTableViewDataSourceProvider else { return }
        let item = provider.rowItem(for: tableView, at: indexPath)
        jlxxDelegate?.didDeselectRowAt?(for: tableView, with: item, at: indexPath)
    }

}



