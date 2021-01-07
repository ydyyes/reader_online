//
//  JLXXCollectionView.swift
//  JinglanIM
//
//  Created by apple on 2019/3/28.
//  Copyright © 2019年 JLXX. All rights reserved.
//

import UIKit

public class JLXXCollectionView: UICollectionView {

	public typealias sectionViewType = (UICollectionReusableView & JLXXCollectionSectionViewProtocol)
	public typealias cellType = (UICollectionViewCell & JLXXCollectionViewCellProtocol)
	
	internal weak var jlxxDelegate: JLXXCollectionViewProtocol?
    internal weak var refreshDelegate: JLXXCollectionViewRefreshProtocol?

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

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
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
    
}

extension JLXXCollectionView: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            jlxxDelegate?.scrollViewDidEndScroll?(scrollView)
        }else{
            jlxxDelegate?.scrollViewDidScroll?(scrollView)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        debugPrint("scrollViewDidEndScrollingAnimation")
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            jlxxDelegate?.scrollViewDidEndScroll?(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        jlxxDelegate?.scrollViewDidEndScroll?(scrollView)
    }
    
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let provider = dataSource as? JLXXCollectionViewDataSourceProvider else { return }
		
		let item = provider.rowItem(for: collectionView, at: indexPath)
		jlxxDelegate?.didSelect?(for: collectionView, with: item, at: indexPath)
		collectionView.deselectItem(at: indexPath, animated: true)
	}
	
}
