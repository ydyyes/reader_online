//
//  JLXXCollectionViewDataSourceProvider.swift
//  JinglanIM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

public class JLXXCollectionViewSectionItem {
	
	var sectionHeaderItem: Any?
	
	var sectionFooterItem: Any?
	
	//数组里的每一个元素就是一个row的数据
	var rowItems: NSMutableArray = []
   
}

class JLXXCollectionViewDataSourceProvider: NSObject {
	
	public var dataSource: JLXXCollectionViewDataSourceProtocol

	public var layout: UICollectionViewLayout

	/**
	cell/headerView的代理
	*/
	public weak var delegate: AnyObject?
	
	/**
	所有section的数据
	*/
	public var sectionItems: Array<JLXXCollectionViewSectionItem> = []
	
	init(dataSource: JLXXCollectionViewDataSourceProtocol, layout: UICollectionViewLayout , delegate: AnyObject?) {
		self.dataSource = dataSource
		self.layout = layout
		self.delegate = delegate
		
		super.init()
	}
	
	/**
	根据collectionView 和 indexPath 获取item
	
	@param collectionView collectionView
	@param indexPath 指定的indexPath
	@return item item
	*/
	public func rowItem(for collectionView: UICollectionView, at indexPath: IndexPath) -> Any? {
		if let rowItems = rowItems(for: collectionView, at: indexPath), rowItems.count > indexPath.row {
			return rowItems[indexPath.row]
		}
		return nil
	}
	
	public func rowItems(for collectionView: UICollectionView, at indexPath: IndexPath) -> NSMutableArray? {
		if (sectionItems.count > indexPath.section) {
			return sectionItems[indexPath.section].rowItems
		}
		return nil
	}
	
	/**
	添加count个sectionItem
	
	@param count sectionItem的个数
	*/
	public func addSectionItem(count: Int) {
		for _ in 0..<count {
			sectionItems.append(JLXXCollectionViewSectionItem())
		}
	}
	
	/**
	根据index返回指定的section的sectionItem
	
	@param section 第几个section
	@return 返回一个sectionItem
	*/
	public func getSectionItem(at section: Int) -> JLXXCollectionViewSectionItem {
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

extension JLXXCollectionViewDataSourceProvider: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sectionItems.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (sectionItems.count > section) {
			let sectionItem = sectionItems[section]
			return sectionItem.rowItems.count
		}
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let item = rowItem(for: collectionView, at: indexPath)
		let cellClass = dataSource.cellViewClass(for: collectionView, with: item, at: indexPath.section)
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(cellClass)", for: indexPath)
		guard let collectionViewCell = cell as? JLXXCollectionView.cellType else { return cell }
		collectionViewCell.setItem(item, indexPath: indexPath)
		collectionViewCell.delegate = delegate
		return collectionViewCell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let section = indexPath.section
		let sectionItem: Any?

		let sectionClass: JLXXCollectionView.sectionViewType.Type?
		if kind == UICollectionView.elementKindSectionHeader {
			sectionItem = sectionItems[section].sectionHeaderItem
			sectionClass = dataSource.sectionHeaderViewClass(for: collectionView, with: sectionItem, at: section)
		}else {
			sectionItem = sectionItems[section].sectionFooterItem
			sectionClass = dataSource.sectionFooterViewClass(for: collectionView, with: sectionItem, at: section)
		}
		
		guard let sectionViewClass = sectionClass else { return UICollectionReusableView() }
				
		let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(sectionViewClass)", for: indexPath)
		
		guard let jlxxSectionView = sectionView as? JLXXCollectionView.sectionViewType else { return sectionView }
		jlxxSectionView.setItem(item: sectionItem, indexPath: indexPath)
		jlxxSectionView.delegate = delegate
		
		return jlxxSectionView
	}
	
}
