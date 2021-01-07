//
//  MSYBookShelfHeaderView.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit
import TXScrollLabelView

protocol MSYBookShelfHeaderViewDelegate: class {
    func bookShelfHeaderViewBookInfoViewClick(bookShelfHeaderView: MSYBookShelfHeaderView, bookModel: BookCityBookModel)
}

class MSYBookShelfHeaderView: UICollectionReusableView, JLXXCollectionSectionViewProtocol {
    
    @IBOutlet weak var bookContenView: UIView!
    @IBOutlet weak var bookInfoView: UIView!
    
    /** 书的图片 */
    @IBOutlet weak var bookImageView: UIImageView!
    
    /** 书的名称 */
    @IBOutlet weak var bookNameLabel: UILabel!
    
    /** 书的描述 */
    @IBOutlet weak var bookDescLabel: UILabel!
    
    /** 书的作者名称 */
    @IBOutlet weak var bookAuthorLabel: UILabel!
    
    @IBOutlet weak var messageNotiView: UIView!
    
    @IBOutlet weak var messageNotiContentView: UIView!
    
    weak var delegate: AnyObject?
    weak var bookShelfHeaderDelegate: MSYBookShelfHeaderViewDelegate? {
        return delegate as? MSYBookShelfHeaderViewDelegate
    }
    
    /** 滚动文字 */
    private weak var scrollLabel: TXScrollLabelView?
    
    /** 数据 */
    private var dataModel: BookCityBookModel?
    
    func setItem(item: Any?, indexPath: IndexPath) {
        
        guard let model = item as? BookCityBookModel else { return }
        
        bookImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "zhanweitu"))
        bookNameLabel.text = model.title
        bookAuthorLabel.text = "\(model.author) | \(model.majorCate)"
        bookDescLabel.text = model.longIntro
        
        guard dataModel != model else { return }
        
        //公告文字
        let notiText = JPTool.contact_US()
        startScrollRunLable(with: notiText)
        
        dataModel = model
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        bookContenView.layer.cornerRadius = 2
        bookContenView.layer.shadowRadius = 8
        // 阴影的颜色
        bookContenView.layer.shadowColor = UIColor.darkGray.cgColor
        bookContenView.layer.shadowOpacity = 0.3
        // 阴影的范围
        bookContenView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickBookInfo))
        bookInfoView.addGestureRecognizer(tap)
    }
    
    private func startScrollRunLable(with title: String) {
        
        scrollLabel?.endScrolling()
        scrollLabel?.removeFromSuperview()

        let label = TXScrollLabelView(frame: CGRect(x: 0, y: 5, width: JPTool.screenWidth() - 70 , height: 20))
        label.scrollType = .leftRight
        label.scrollVelocity = 1
        label.scrollSpace = 100
        label.scrollTitle = title
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.scrollTitleColor = UIColor.black_222222()
        messageNotiContentView.addSubview(label)
        label.beginScrolling()
        scrollLabel = label
    }
    
    
    @objc private func clickBookInfo() {
        if let model = dataModel {
            bookShelfHeaderDelegate?.bookShelfHeaderViewBookInfoViewClick(bookShelfHeaderView: self, bookModel: model)
        }
    }
    
}
