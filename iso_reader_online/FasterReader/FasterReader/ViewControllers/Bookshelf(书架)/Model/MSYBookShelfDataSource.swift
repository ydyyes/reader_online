//
//  MSYBookShelfDataSource.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

struct MSYBookShelfDataSource: JLXXCollectionViewDataSourceProtocol {
    
    func cellClassNames() -> Array<JLXXCollectionView.cellType.Type> {
        return [MSYBookShelfCell.self, MSYBookShelfListCell.self]
    }
    
    func cellViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.cellType.Type {
        
        if let layout = collectionView.collectionViewLayout as? MSYBookShelfCollectionViewLayout, layout.layoutStyle == .list {
            return MSYBookShelfListCell.self
        }
        return MSYBookShelfCell.self
    }
    
    func sectionHeaderViewClassNames() -> Array<JLXXCollectionView.sectionViewType.Type> {
        return [MSYBookShelfHeaderView.self]
    }
    
    func sectionHeaderViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.sectionViewType.Type? {
        
        return MSYBookShelfHeaderView.self
    }
    
}

struct MSYBookBrowseHistoryDataSource: JLXXCollectionViewDataSourceProtocol {
    
    func cellClassNames() -> Array<JLXXCollectionView.cellType.Type> {
        return [MSYBookShelfListCell.self]
    }
    
    func cellViewClass(for collectionView: UICollectionView, with item: Any?, at section: Int) -> JLXXCollectionView.cellType.Type {
        
        return MSYBookShelfListCell.self
        
    }
    
}
