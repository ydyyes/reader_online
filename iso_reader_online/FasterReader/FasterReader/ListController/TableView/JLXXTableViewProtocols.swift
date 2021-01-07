//
//  TableViewProtocols.swift
//  TTT
//
//  Created by cnsuer on 2018/8/14.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

/// tableViewDelegate的选中某一行cell
@objc public protocol JLXXTableViewProtocol {
	
	@objc optional func didSelectRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath)

    @objc optional func didDeselectRowAt(for tableView: UITableView, with item: Any?, at indexPath: IndexPath)

    /// 有一个返回值,用来判断是否需要从列表中删除该数据
    @objc optional func deleteRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) -> Bool
    
    //    func insertRow(for tableView: UITableView, with item: Any?, at indexPath: IndexPath)
}

/// JLXXRefreshTableView的下拉刷新和上拉加载
public protocol JLXXTableViewRefreshProtocol: class {
	
	/// 下拉刷新触发的方法
	func pullDownToRefresh()
	
	/// 上拉加载触发的方法
	func pullUpToLoadMore()
	
}

/// 设置每个cell的,代理,高度,数据
public protocol JLXXTableViewCellProtocol: class {

	/**
	cell是不是用xib创建的
	默认false
	*/
	static var isNibCell: Bool { get }

	static func rowHeight(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) -> CGFloat

	var delegate: AnyObject? { set get }
	
	func setItem(item: Any?, indexPath: IndexPath)

}

extension JLXXTableViewCellProtocol {
	
	static var isNibCell: Bool {
		return true
	}
	
}

/// 设置每个Section的SectionView的,代理,高度,数据
public protocol JLXXTableSectionViewProtocol: class {
	
	var delegate: AnyObject? { set get }
	
	static func sectionViewHeight(for tableView: UITableView, with item: Any?, at section: Int) -> CGFloat
	
	func setItem(item: Any?, at section: Int)
	
}

/// 设置每个TableView的TableHeaderView或者TableViewFooterView的,代理,高度,数据
public protocol JLXXTableHeaderViewProtocol: class {
	
	var delegate: AnyObject? { set get }
	
	static func headerViewHeight(for tableView: UITableView, with item: Any?) -> CGFloat
	
	func setItem(item: Any?)
	
}


