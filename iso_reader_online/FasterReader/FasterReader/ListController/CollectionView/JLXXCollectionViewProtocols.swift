
//
//  CollectionViewProtocols.swift
//  JinglanIM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

/// tableViewDelegate的选中某一行cell
@objc public protocol JLXXCollectionViewProtocol {

	@objc optional func didSelect(for collectionView: UICollectionView, with item: Any?, at indexPath: IndexPath)
	
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView) // any offset changes

    @objc optional func scrollViewDidEndScroll(_ scrollView: UIScrollView)
}

/// 设置每个cell的,代理,高度,数据
public protocol JLXXCollectionViewCellProtocol: class {
	
	/**
	cell是不是用xib创建的
	默认false
	*/
	static var isNibCell: Bool { get }

	var delegate: AnyObject? { set get }
	
	func setItem(_ item: Any?, indexPath: IndexPath)
	
}

extension JLXXCollectionViewCellProtocol {
	
	static var isNibCell: Bool {
		return true
	}
}


/// 设置每个Section的SectionView的,代理,高度,数据
public protocol JLXXCollectionSectionViewProtocol: class {
	
	/**
	view是用xib创建的
	默认false
	*/
	static var isNibSectionView: Bool { get }
	
	var delegate: AnyObject? { set get }

	func setItem(item: Any?, indexPath: IndexPath)

}

extension JLXXCollectionSectionViewProtocol {
	
	static var isNibSectionView: Bool {
		return true
	}
}

/// JLXXRefreshTableView的下拉刷新和上拉加载
public protocol JLXXCollectionViewRefreshProtocol: class {
	
	/// 下拉刷新触发的方法
	func pullDownToRefresh()
	
	/// 上拉加载触发的方法
	func pullUpToLoadMore()
	
}
