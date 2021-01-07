//
//  MSYBookShelfCell.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit


protocol MSYBookShelfCellDelegate: class {
    func msyBookShelfCell(msyBookShelfCell: MSYBookShelfCell, delete bookMolde: BookCityBookModel)
}

class MSYBookShelfCell: UICollectionViewCell, JLXXCollectionViewCellProtocol {
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var newestChapterLabel: UILabel!
    @IBOutlet weak var bookNamelabel: UILabel!
    
    weak var delegate: AnyObject?
    weak var bookShelfCellDelegate: MSYBookShelfCellDelegate? {
        return delegate as? MSYBookShelfCellDelegate
    }
    
    private var dataModel: BookCityBookModel?
    
    func setItem(_ item: Any?, indexPath: IndexPath) {
        
        if let model = item as? BookCityBookModel {
            bookCoverImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "zhanweitu"))
            newestChapterLabel.text = "最新章节:\(model.lastChapter)"
            bookNamelabel.text = model.title
            dataModel = model
        }else if let _ = item as? String {
            bookCoverImageView.image = UIImage.init(named: "add")
            newestChapterLabel.text = ""
            bookNamelabel.text = ""
        }

        
        
        /*
         
         self.bookNameLb.text = model.title;//书籍名称
         self.updateLb.text = [NSString stringWithFormat:@"更新至%@",model.lastChapter];
         
         //    [Utils cutImage:self.bookImg];
         [self.bookImg yy_setImageWithURL:[NSURL URLWithString:model.cover] placeholder:[UIImage imageNamed:@"zhanweitu"]];//书籍封面图
         self.bookImg.yy_imageURL = [NSURL URLWithString:model.cover];
         
         if ([model.over isEqualToString:@"1"]) {//完结
         self.bookStateImg.image = [UIImage imageNamed:@"wangjie"];
         }else{//连载
         self.bookStateImg.image = [UIImage imageNamed:@"lianzai"];
         }
         
         if (model.redSpot) {// 更新的小红点
         self.redView.hidden = NO;
         self.bookNameLeftSpace.constant = 7+2;
         }else{
         self.redView.hidden = YES;
         self.bookNameLeftSpace.constant = 2;
         }
         if (indexPath.row == dataArr.count) {
         self.bookStateImg.image = [UIImage imageNamed:@""];
         self.bookImg.image = [UIImage imageNamed:@"add"];
         self.bookNameLb.text = @"";
         self.redView.hidden = YES;
         self.updateLb.text = @"";
         }
         
         */
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let lonPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressToDelete))
        self.addGestureRecognizer(lonPress)
    }
    
    @objc private func longPressToDelete() {
        
        if let model = dataModel {
            bookShelfCellDelegate?.msyBookShelfCell(msyBookShelfCell: self, delete: model)
        }
    }

}
