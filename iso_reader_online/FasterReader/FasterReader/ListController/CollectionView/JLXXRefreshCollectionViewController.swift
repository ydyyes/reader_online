//
//  JLXXRefreshCollectionViewController.swift
//  NightReader
//
//  Created by apple on 2019/6/28.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class JLXXRefreshCollectionViewController: JLXXCollectionViewController {

    //limit_begin：从第几条开始取(默认从第0条开始取)
    public var limit_begin: Int = 0
    
    //limit_num：需要取几条(默认取20条)
    public var limit_num: Int = 20
    
    ///是否开启上拉加载
    public var loadMoreEnable = false
    
    /// 是否是下拉刷新数据
    public var isRefresh: Bool {
        if limit_begin == 0 {
            return true
        }
        return false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshDelegate = self
        collectionView.isHadRefreshAction = true
    }
    
    
    /// 网络请求
    public func loadRequest() {
        fatalError("loadRequest() has not been implemented, you must override this mehtod")
    }
    
    public func addRefreshData(_ refreshData: Array<Any>?, at section: Int = 0) {
        
        guard let data = refreshData else { return }
        
        //如果是刷新,而且刷新的数量等于(大于,不会出现)limit_num,则设置上拉加载更多
        if  isRefresh && data.count >= limit_num, loadMoreEnable {
            collectionView.isHadLoadMoreAction = true
        }
        //如果是刷新的话
        //删除以前的数据
        if isRefresh {
            provider.clearSectionItem(at: section)
        }
        
        //添加数据
        let sectionItem = provider.getSectionItem(at: section)
        sectionItem.rowItems.addObjects(from: data)
        
        //需要刷新reloadData
        reloadData()
    }
    
    /**
     请求失败后的处理方法
     */
    public func requestDidFaile(_ text: String? = "暂无数据...") {
        if isRefresh {
            //如果是刷新
            provider.clearAllSectionRowItems()
            //刷新数据
            reloadData()
        }else{
            //加载更多
            collectionView.endLoadWithNoMoreData()
        }
    }
    
    public override func reloadData() {
        collectionView.reloadData()
        //停止刷新动作
        stopRefreshing()
    }
    
    public func stopRefreshing() {
        //停止刷新动作
        collectionView.jlxxStopRefreshing()
    }
    
}

extension JLXXRefreshCollectionViewController: JLXXCollectionViewRefreshProtocol {
    
    public func pullDownToRefresh() {
        collectionView.jlxxResetFooter()
        limit_begin = 0
        loadRequest()
    }
    
    public func pullUpToLoadMore() {
        limit_begin += 20
        loadRequest()
    }
    
}

