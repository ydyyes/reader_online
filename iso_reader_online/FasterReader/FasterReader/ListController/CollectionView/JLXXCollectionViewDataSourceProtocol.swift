//
//  JLXXCollectionViewDataSourceProtocol.swift
//  JinglanIM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

public protocol JLXXCollectionViewDataSourceProtocol {

	/**
	需要显示的cell的类名组成的数组
	*/
	func cellClassNames() -> Array<JLXXCollectionView.cellType.Type>

	/**
	根据item或者(和)section获取cellClass
	
	@param tableView tableView
	@param section 指定的section
	@param item item
	@return cellClass
	*/
	func cellViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.cellType.Type
	
	/**
	需要显示的sectionHeaderView的类名组成的数组
	*/
	func sectionHeaderViewClassNames() -> Array<JLXXCollectionView.sectionViewType.Type>
	func sectionFooterViewClassNames() -> Array<JLXXCollectionView.sectionViewType.Type>

	/**
	根据headerItem或者(或)section获取headerViewClass/sectionFooterViewClass
	
	@param tableView tableView
	@param section 指定的section
	@param item headerItem
	@return sectionViewClass
	*/
	func sectionHeaderViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.sectionViewType.Type?
	
	func sectionFooterViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.sectionViewType.Type?

}

extension JLXXCollectionViewDataSourceProtocol {

	func sectionHeaderViewClassNames() -> Array<JLXXCollectionView.sectionViewType.Type> {
		return []
	}
	
	func sectionFooterViewClassNames() -> Array<JLXXCollectionView.sectionViewType.Type> {
		return []
	}
	
	func sectionHeaderViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.sectionViewType.Type? {
		return nil
	}
	
	func sectionFooterViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.sectionViewType.Type? {
		return nil
	}
}
