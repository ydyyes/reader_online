//
//  MyDataSource.swift
//  TTT
//
//  Created by cnsuer on 2018/8/14.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

public class JLXXTableViewSectionItem {
	
	var sectionHeaderItem: Any?
	
	var sectionFooterItem: Any?
	
	//数组里的每一个元素就是一个row的数据
	var rowItems: NSMutableArray = []
}

public class JLXXTableViewDataSourceProvider: NSObject {
	
	public var dataSource: JLXXTableViewDataSourceProtocol
	/**
	tableview刷新后,
	是否使用已存在的headerView(sectionHeaderView和tableviewHeaderView)
	默认true
	*/
	public var isUseCacheView: Bool = true
	
	/**
	cell/headerView的代理
	*/
	public weak var delegate: AnyObject?
	/**
	所有section的数据
	*/
	public var sectionItems: Array<JLXXTableViewSectionItem> = []
	
	public var headerItem: Any?

	public var footerItem: Any?
	
	init(dataSource: JLXXTableViewDataSourceProtocol, delegate: AnyObject?) {
		self.dataSource = dataSource
		self.delegate = delegate
		super.init()
	}
	
	/**
	根据tableView 和 indexPath 获取item
	
	@param tableView tableView
	@param indexPath 指定的indexPath
	@return item item
	*/
	
	public func rowItem(for tableView: UITableView, at indexPath: IndexPath) -> Any? {
		if let rowItems = rowItems(for: tableView, at: indexPath), rowItems.count > indexPath.row {
			return rowItems[indexPath.row]
		}
		return nil;
	}
	
	public func rowItems(for tableView: UITableView, at indexPath: IndexPath) -> NSMutableArray? {
		if (sectionItems.count > indexPath.section) {
			return sectionItems[indexPath.section].rowItems
		}
		return nil;
	}
	
	/**
	添加count个sectionItem
	
	@param count sectionItem的个数
	*/
	public func addSectionItem(count: Int) {
		for _ in 0..<count {
			sectionItems.append(JLXXTableViewSectionItem())
		}
	}

	/**
	根据index返回指定的section的sectionItem

	@param section 第几个section
	@return 返回一个sectionItem
	*/
	public func getSectionItem(at section: Int) -> JLXXTableViewSectionItem {
		if (section >= sectionItems.count) {
			fatalError("sectionItem(for section:) 给定的section大于当前dataSource中sectionItems的个数")
		}
		return sectionItems[section]
	}
	
	/**
	清除所有section中的RowItems数据
	*/
	public func clearAllSectionRowItems() {
		for section in 0..<sectionItems.count {
			clearSectionItem(at: section)
		}
	}
	
	/**
	清除指定section中的rowItems的数据
	*/
	public func clearSectionItem(at section: Int = 0) {
		let item = getSectionItem(at: section)
		item.rowItems.removeAllObjects()
	}
	
	/**
	清除指定section的 header/footerItem中的数据
	*/
	public func clearSectionHeaderItem(at section: Int) {
		let item = getSectionItem(at: section)
		item.sectionHeaderItem = nil
		item.sectionFooterItem = nil
	}
	
	/**
	清除dataSource中的所有数据
	*/
	public func reomveAllItems() {
		sectionItems.removeAll()
	}

}

extension JLXXTableViewDataSourceProvider: UITableViewDataSource {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return sectionItems.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (sectionItems.count > section) {
			let sectionItem = sectionItems[section]
			return sectionItem.rowItems.count
		}
		return 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let item = rowItem(for: tableView, at: indexPath)
		let cellClass = dataSource.cellViewClass(for: tableView, with: item, at: indexPath.section)
		let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellClass)", for: indexPath)
		guard let tableViewCell = cell as? JLXXTableView.cellType else { return cell }
		tableViewCell.setItem(item: item, indexPath: indexPath)
		tableViewCell.delegate = delegate
		return tableViewCell
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		return dataSource.canEditRow(for: tableView, at: indexPath)
	}
		
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
        guard let jlxxTableView = tableView as? JLXXTableView, let theDelegate = jlxxTableView.jlxxDelegate else { return }
        
		if editingStyle == .delete {

            let item = rowItem(for: tableView, at: indexPath)
			let isChange = theDelegate.deleteRow?(for: tableView, with: item, at: indexPath)
			
			if let isChange = isChange, isChange, let items = rowItems(for: tableView, at: indexPath) {
				items.removeObject(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .none)
			}

		}
	}
}
