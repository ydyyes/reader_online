//
//  DataSource.swift
//  TTT
//
//  Created by cnsuer on 2018/8/14.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

public protocol JLXXTableViewDataSourceProtocol {
	
	/**
	需要显示的cell的类名组成的数组
	*/
	func cellClassNames() -> Array<JLXXTableView.cellType.Type>
	
	/**
	根据item或者(和)section获取cellClass
	
	@param tableView tableView
	@param section 指定的section
	@param item item
	@return cellClass
	*/
	func cellViewClass(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.cellType.Type
	
	/**
	根据headerItem或者(或)section获取headerViewClass
	
	@param tableView tableView
	@param section 指定的section
	@param item headerItem
	@return headerViewClass
	*/
	func sectionHeaderViewClass(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.sectionViewType.Type?
	
	/**
	*根据sectionHeaderItem获取sectionHeaderView
	*/
	func sectionHeaderView(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.sectionViewType?

	/**
	*获取tableView的HeaderView
	*/
	func headerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType?
	
    /**
     *获取tableView的FooterView
     */
    func footerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType?
	
	func canEditRow(for tableView: UITableView, at indexPath: IndexPath) -> Bool
	
}

extension JLXXTableViewDataSourceProtocol {
	
	public func sectionHeaderViewClass(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.sectionViewType.Type? {
		return nil
	}

	public func sectionHeaderView(for tableView: UITableView, with item: Any?, at section: Int) -> JLXXTableView.sectionViewType? {
		return nil
	}
	
	func headerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType? {
		return nil
	}
    
    func footerView(for tableView: UITableView, with item: Any?) -> JLXXTableView.headerViewType? {
        return nil
    }
	
	func canEditRow(for tableView: UITableView, at indexPath: IndexPath) -> Bool {
		return false
	}
	
}
