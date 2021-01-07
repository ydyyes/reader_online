//
//  MSYBookCacheListCell.swift
//  FasterReader
//
//  Created by apple on 2019/7/5.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit

class MSYBookCacheListCell: UITableViewCell, JLXXTableViewCellProtocol {
    
    static func rowHeight(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) -> CGFloat {
        return 94 + 5 + 1 + 10
    }
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookNamelabel: UILabel!
    @IBOutlet weak var bookAuthorlabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var currentProgress: UIProgressView!
    
    weak var delegate: AnyObject?
    
    func setItem(item: Any?, indexPath: IndexPath) {
        
        guard let model = item as? MSYBookCacheModel else { return }
        bookCoverImageView.yy_setImage(with: URL(string: model.cover), placeholder: UIImage.init(named: "zhanweitu"))
        bookNamelabel.text = model.bookName
        currentProgress.isHidden = false
        
        setDesLabelTextAndProgress(with: model)
    }
    
    func setDesLabelTextAndProgress(with model: MSYBookCacheModel) {
        
        currentProgress.progress = model.progress

        let strProgress = String(format: "%.2f", model.progress * 100)
        
        if model.downloadStatus == .downloaing {
            desLabel.text = "下载中,缓存进度\(strProgress)%"
        }else if model.downloadStatus == .suspendDownload {
            desLabel.text = "已暂停,缓存进度\(strProgress)%,点击开始下载"
        }else if model.downloadStatus == .notDownload {
            desLabel.text = "未下载,缓存进度\(strProgress)%,点击开始下载"
        }else{
            currentProgress.isHidden = true
            desLabel.text = "已完成"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // 获取 contentView 所有子控件
        // 创建颜色数组
        let colors = NSMutableArray.init();
        // 获取所有子控件颜色
        for view in self.contentView.subviews
        {
            if view.backgroundColor != nil {
                colors .add(view.backgroundColor!);
            }else{
                colors .add(UIColor.clear);
            }
        }
        // 调用super
        super.setSelected(selected, animated: animated)
        // 修改控件颜色
        for i in 0..<self.contentView.subviews.count
        {
            self.contentView.subviews[i].backgroundColor = colors[i] as? UIColor;
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // 获取 contentView 所有子控件
        // 创建颜色数组
        let colors = NSMutableArray.init();
        // 获取所有子控件颜色
        for view in self.contentView.subviews {
            if view.backgroundColor != nil {
                colors .add(view.backgroundColor!);
            }else{
                colors .add(UIColor.clear);
            }
        }
        // 调用super
        super.setHighlighted(highlighted, animated: animated);
        // 修改控件颜色
        for i in 0..<self.contentView.subviews.count{
            self.contentView.subviews[i].backgroundColor = colors[i] as? UIColor;
        }
    }
}
