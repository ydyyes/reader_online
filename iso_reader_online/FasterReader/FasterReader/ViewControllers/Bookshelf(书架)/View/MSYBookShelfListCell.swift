//
//  MSYBookShelfListCell.swift
//  NightReader
//
//  Created by apple on 2019/6/29.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class MSYBookShelfListCell: UICollectionViewCell, JLXXCollectionViewCellProtocol {
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookNamelabel: UILabel!
    @IBOutlet weak var bookAuthorlabel: UILabel!
    @IBOutlet weak var newestChapterLabel: UILabel!
    
    weak var delegate: AnyObject?
    
    func setItem(_ item: Any?, indexPath: IndexPath) {
        if let model = item as? BookCityBookModel {
            bookCoverImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "zhanweitu"))
            newestChapterLabel.text = "最新章节:\(model.lastChapter)"
            bookNamelabel.text = model.title
            bookAuthorlabel.text = "\(model.author) | \(model.majorCate)"

        }else if let _ = item as? String {
            bookCoverImageView.image = UIImage.init(named: "add")
            newestChapterLabel.text = ""
            bookNamelabel.text = ""
            bookAuthorlabel.text = "添加您喜欢的书籍"
        }
        
        if let model = item as? MSYBrowseHistoryCacheModel {
            bookCoverImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "zhanweitu"))
            newestChapterLabel.text = "最新章节:\(model.lastChapter)"
            bookNamelabel.text = model.bookName
            bookAuthorlabel.text = "\(model.author) | \(model.majorCate)"
            
        }else if let _ = item as? String {
            bookCoverImageView.image = UIImage.init(named: "add")
            newestChapterLabel.text = ""
            bookNamelabel.text = ""
            bookAuthorlabel.text = "添加您喜欢的书籍"
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
