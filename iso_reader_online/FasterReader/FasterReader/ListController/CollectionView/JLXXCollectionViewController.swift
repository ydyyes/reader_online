//
//  JLXXCollectionViewController.swift
//  JinglanIM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

class JLXXCollectionViewController: UIViewController, JLXXCollectionViewProtocol {
	
	public var collectionView: JLXXCollectionView!
	public var provider: JLXXCollectionViewDataSourceProvider!
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = UIColor.white
        
		createDataSourceProvider()
		creatCollectionView()
        
		if #available(iOS 11.0, *) {
			collectionView.contentInsetAdjustmentBehavior = .never
        }else {
            automaticallyAdjustsScrollViewInsets = false
        }
	}
	
	open func createDataSourceProvider() {
		fatalError("createDataSourceProvider() has not been implemented, you must override this mehtod")
	}
	
	/**
	设置sectionHeaderItem
	*/
	public func setSectionHeaderItem(item: Any?, at section: Int) {
		let sectionItem = provider.getSectionItem(at: section)
		sectionItem.sectionHeaderItem = item;
	}
	
	/**
	注意:如果需要设置sectionHeaderItem的话,必须先调用setHeaderItem 方法,
	因为调用此方法,是给最后一个section添加数据的话,
	会自动刷新tableview
	*/
	public func addData(data: Array<Any>?, at section: Int, isClear existedData: Bool = true) {
		//删除原来的数据
		if existedData {
			provider.clearSectionItem(at: section)
		}
		//没有数据的话,刷新列表
		guard let newDatas = data else {
			
			reloadData()
			
			return
		}
		//添加数据
		let sectionItem = provider.getSectionItem(at: section)
		sectionItem.rowItems.addObjects(from: newDatas)
		//需要刷新reloadData
		reloadData()
	}
	
	/**
	添加数据的时候,是不是给最后一个section添加数据
	
	@param section 指定的section
	@return 是不是最后一个
	*/
	public func isLastSection(section: Int) -> Bool{
		var lastSection = false;
		if section == (provider.sectionItems.count - 1) {
			lastSection = true;
		}
		return lastSection;
	}
	
	func scrollToBottom(animated: Bool) {
		let sections = collectionView.numberOfSections - 1
		let rows = collectionView.numberOfItems(inSection: sections)
		if rows > 0 {
			collectionView.scrollToItem(at: IndexPath(row: rows - 1, section: sections), at: .bottom, animated: animated)
		}
	}
    
    func reloadData() {
        collectionView.reloadData()
    }
	
}

extension JLXXCollectionViewController {
	private func creatCollectionView() {
		let screenWidth = UIScreen.main.bounds.width
		let screenHeight = UIScreen.main.bounds.height
		var tabBarHeight = tabBarController?.tabBar.bounds.height ?? 0.0
		if (hidesBottomBarWhenPushed) {
			//当tabbar不显示时,高度应设置为0
			tabBarHeight = 0.0
		}
        let statusBar = UIApplication.shared.statusBarFrame.height
        let navBarHeight = navigationController?.navigationBar.bounds.height ?? 0.0
        let height = screenHeight - statusBar - navBarHeight - tabBarHeight
        let frame = CGRect(x: 0, y: statusBar + navBarHeight, width: screenWidth, height: height)
		collectionView = JLXXCollectionView(frame: frame, collectionViewLayout: provider.layout)
		collectionView.dataSource = provider
		collectionView.jlxxDelegate = self
		collectionView.backgroundColor = .white
		view.addSubview(collectionView)
		
		//注册cell
		for cellClass in provider.dataSource.cellClassNames() {
			if cellClass.isNibCell  {
				collectionView.register(UINib.init(nibName: "\(cellClass)", bundle: Bundle(for: cellClass)), forCellWithReuseIdentifier: "\(cellClass)")
			}else {
				collectionView.register(cellClass, forCellWithReuseIdentifier: "\(cellClass)")
			}
		}
		
		//注册sectionHeader
		for sectionViewClass in provider.dataSource.sectionHeaderViewClassNames() {
			if sectionViewClass.isNibSectionView  {
				collectionView.register(UINib.init(nibName: "\(sectionViewClass)", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(sectionViewClass)")
			}else {
				collectionView.register(sectionViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(sectionViewClass)")
			}
		}
		
		for sectionViewClass in provider.dataSource.sectionFooterViewClassNames() {
			if sectionViewClass.isNibSectionView  {
				collectionView.register(UINib.init(nibName: "\(sectionViewClass)", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "\(sectionViewClass)")
			}else {
				collectionView.register(sectionViewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "\(sectionViewClass)")
			}
		}
	}
	
}
