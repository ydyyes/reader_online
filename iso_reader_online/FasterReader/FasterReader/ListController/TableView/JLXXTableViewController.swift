//
//  TableViewController.swift
//  TTT
//
//  Created by cnsuer on 2018/8/15.
//  Copyright © 2018年 JLXX. All rights reserved.
//

import UIKit

open class JLXXTableViewController: UIViewController, JLXXTableViewProtocol {

	public var tableView: JLXXTableView!
	public var provider: JLXXTableViewDataSourceProvider!
	
	open override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = UIColor.white
        
        createDataSourceProvider()
        creatTableView()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
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
	
     @o@objc@objc  bjc  @pa@objc ram section 指定的section
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
		let sections = tableView.numberOfSections - 1
		let rows = tableView.numberOfRows(inSection: sections)
		if rows > 0 {
			tableView.scrollToRow(at: IndexPath(row: rows - 1, section: sections), at: .bottom, animated: animated)
		}
	}
	
    public func reloadData() {
        tableView.reloadData()
    }
}

extension JLXXTableViewController {
	private func creatTableView() {
		let screenWidth = UIScreen.main.bounds.width
		let screenHeight = UIScreen.main.bounds.height
		let statusBar = UIApplication.shared.statusBarFrame.height
		let navBarHeight = navigationController?.navigationBar.bounds.height ?? 0.0
		let height = screenHeight - statusBar - navBarHeight
		let frame = CGRect(x: 0, y: statusBar + navBarHeight, width: screenWidth, height: height)
		tableView = JLXXTableView(frame: frame, style: .plain)
		tableView.estimatedRowHeight = 0
		tableView.estimatedSectionHeaderHeight = 0
		tableView.estimatedSectionFooterHeight = 0
		tableView.dataSource = provider
		tableView.jlxxDelegate = self
		tableView.backgroundColor = UIColor.white
		view.addSubview(tableView)
		
		//注册cell
		for cellClass in provider.dataSource.cellClassNames() {
			if cellClass.isNibCell {
				tableView.register(UINib.init(nibName: "\(cellClass)", bundle: Bundle(for: cellClass)), forCellReuseIdentifier: "\(cellClass)")
			}else{
				tableView.register(cellClass, forCellReuseIdentifier: "\(cellClass)")
			}
		}
		
	}

}
