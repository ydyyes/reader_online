//
//  MSYMineCell.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

class MSYMineCell: UITableViewCell, JLXXTableViewCellProtocol {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var iconImageViewWidth: NSLayoutConstraint!
    
    weak var delegate: AnyObject?
    
    static func rowHeight(for tableView: UITableView, with item: Any?, at indexPath: IndexPath) -> CGFloat {

        return 55.0
    }
    
    func setItem(item: Any?, indexPath: IndexPath) {
        
        guard let model = item as? MSYMineModel else { return }
        nameLabel.text = model.title
        descLabel.text = model.desTitle
        if model.imageName.isEmpty {
            //设置界面
            iconImageViewWidth.constant = 0
        }else {
            //我的界面
            iconImageView.image = UIImage.init(named: model.imageName)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
