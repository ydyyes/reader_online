//
//  MSYBookShelfCollectionViewLayout.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit


private let bookCoverImageViewHeight: CGFloat = 105
private let bookNamelabelHeight: CGFloat = 15
private let newestChapterLabelHeight: CGFloat = 10

//cell的最后一个元素到底部的距离
private let lastCellItemToBottomMargin: CGFloat = 19

private let decorationViewHeight: CGFloat = 18
//装饰视图的底部距cell的底部的距离
private let decorationViewToCellBottom: CGFloat = decorationViewHeight + 10 + 30 + lastCellItemToBottomMargin

class MSYBookShelfCollectionViewLayout: UICollectionViewFlowLayout {
    
    enum LayoutStyle {
        case list //列表模式
        case bookShelf //书架模式
    }
    
    var layoutStyle: LayoutStyle = .bookShelf
    var originX: CGFloat = 33.0 * JL_SCREEN_W_SCALE()
    var itemSpacing: CGFloat = 33.0 * JL_SCREEN_W_SCALE()
    var lineSpacing: CGFloat = 19.0
    var oneLineMaxCount: CGFloat = 3
    
    lazy var bookItemSize: CGSize = {
        guard let collectionView = collectionView else { return .zero }
        let width = (collectionView.frame.size.width - 4 * itemSpacing) / oneLineMaxCount
        let height: CGFloat = bookCoverImageViewHeight + 25 + bookNamelabelHeight + 5 + newestChapterLabelHeight + lastCellItemToBottomMargin
        let size = CGSize(width: width, height: height)
        return size
    }()

    lazy var bookHeaderSize: CGSize = {
        guard let collectionView = collectionView else { return .zero }
        let height: CGFloat = 40 + 105 + 35 + 30
        let size = CGSize(width: collectionView.bounds.width, height: height)
        return size
    }()
    
    //保存所有自定义的section背景的布局属性
    private var decorationViewAttrs: [Int:UICollectionViewLayoutAttributes] = [:]
    private var cellAttributesArray: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    private var supplementaryAttributesArray: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()

    
    convenience init(layoutStyle: LayoutStyle) {
        self.init()
        self.layoutStyle = layoutStyle
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        guard let collectionView = collectionView else { return }
        
        //是list,就用flowLayout自己的布局信息
        if layoutStyle == .list {
            let width = collectionView.frame.size.width
            let height: CGFloat = 94 + 14 + 1 + 10
            itemSize = CGSize(width: width, height: height)
            headerReferenceSize = bookHeaderSize
            return
        }
        
        register(UINib.init(nibName: "MSYBookShelfDecorationView", bundle: nil), forDecorationViewOfKind: MSYBookShelfKindDecoration)
        
        // 如果collectionView当前没有分区，则直接退出
        guard let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) else {
            return
        }
        
        // 删除旧的装饰视图的布局数据
        decorationViewAttrs.removeAll()
        cellAttributesArray.removeAll()
        supplementaryAttributesArray.removeAll()
        
        if let supplementaryAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) {
            supplementaryAttributesArray.append(supplementaryAttributes)
        }

        //分别计算secton0中item的布局信息和所需要的装饰视图的布局属性
        for index in 0..<numberOfItems {
        
            //获取该每个item的布局属性
            guard let item = self.layoutAttributesForItem(at: IndexPath(item: index, section: 0) ) else {
                return
            }
            //添加到cellAttrs数组中
            self.cellAttributesArray.append(item)
            
            //如果index是每行的最后一个item的话,取出布局属性,添加装饰视图
            guard (index + 1) % Int(oneLineMaxCount) == 0 else {
                continue
            }
            
            let y: CGFloat = item.frame.maxY - decorationViewToCellBottom
            let decorationFrame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: decorationViewHeight)

            //根据上面的结果计算卡片装饰图的布局属性
            let decorationAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: MSYBookShelfKindDecoration, with: IndexPath(item: index, section: 0))
            decorationAttribute.zIndex = -1;
            decorationAttribute.frame = decorationFrame
            //将该装饰图的布局属性保存起来
            self.decorationViewAttrs[index] = decorationAttribute
        }
    
    }
    
    //返回rect范围下父类的所有元素的布局属性以及子类自定义装饰视图的布局属性
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            
            //是list,就用flowLayout自己的布局信息
            if layoutStyle == .list {
                return super.layoutAttributesForElements(in: rect)
            }
            
            cellAttributesArray.append(contentsOf: supplementaryAttributesArray.filter {
                return rect.intersects($0.frame)
            })
            cellAttributesArray.append(contentsOf: decorationViewAttrs.values.filter {
                return rect.intersects($0.frame)
            })
            return cellAttributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        //是list,就用flowLayout自己的布局信息
        if layoutStyle == .list {
            return super.layoutAttributesForItem(at: indexPath)
        }
        
        let row = indexPath.row
        let attrtibutes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        //第一个sesction的第一个item需要重新设置起点
        if row == 0 {
            attrtibutes.frame = CGRect(x: originX, y: bookHeaderSize.height, width: bookItemSize.width, height: bookItemSize.height)
            return attrtibutes
        }

        let preIndex = indexPath.row - 1
        let prevLayoutAttributes = self.cellAttributesArray[preIndex]
        let preFrame = prevLayoutAttributes.frame
        
        let preMaxX = preFrame.maxX
        if preMaxX + itemSpacing + bookItemSize.width <= self.collectionViewContentSize.width {
            //同一行
            let x = preMaxX + itemSpacing
            let y = preFrame.origin.y
            attrtibutes.frame = CGRect(x: x, y: y, width: bookItemSize.width, height: bookItemSize.height)
        }else {
            //新的一行
            let y = preFrame.maxY + lineSpacing
            let x = originX
            attrtibutes.frame = CGRect(x: x, y: y, width: bookItemSize.width, height: bookItemSize.height)
        }
        
        return attrtibutes
    }
    
    //返回对应于indexPath的位置的装饰视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //是list,就用flowLayout自己的布局信息
        if layoutStyle == .list {
            return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
        }
        
        if elementKind == MSYBookShelfKindDecoration {
            return self.decorationViewAttrs[indexPath.row]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        //是list,就用flowLayout自己的布局信息
        if layoutStyle == .list {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
        
        if elementKind == UICollectionView.elementKindSectionHeader {
            let att = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            att.frame = CGRect(x: 0, y: 0, width: bookHeaderSize.width, height: bookHeaderSize.height)
            return att
        }
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    override var collectionViewContentSize: CGSize {
        
        guard let collectionView = collectionView else { return .zero }
        
        //是list,就用flowLayout自己的布局信息
        if layoutStyle == .list {
            return super.collectionViewContentSize
        }
        
        let sections = collectionView.numberOfSections
        var totalCount = 0
        for i in 0..<sections {
            let count = collectionView.numberOfItems(inSection: i)
            totalCount += count
        }
        
        let width = collectionView.bounds.width
        var height: CGFloat = 0
        
        //一行最多几个
        let intOneLineMaxCount = floor(oneLineMaxCount)
        //总行数
        let maxLine = CGFloat(totalCount) / intOneLineMaxCount
        var intMaxLine = floor(maxLine)
        // 余数是否大于0,则有另一行
        let yushu = CGFloat(totalCount).truncatingRemainder(dividingBy: intOneLineMaxCount)
        if yushu > 0 {
            intMaxLine += 1
        }
        
        //这仅仅列出了cell的h高度,还要加上headerview的高度
        height = intMaxLine * (bookItemSize.height + lineSpacing) - lineSpacing
        
        height += bookHeaderSize.height
        
        return CGSize(width: width, height: height)
    }
}
