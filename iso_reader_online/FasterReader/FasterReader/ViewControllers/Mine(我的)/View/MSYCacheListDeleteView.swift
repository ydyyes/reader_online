//
//  MSYCacheListDeleteView.swift
//  FasterReader
//
//  Created by apple on 2019/7/9.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit


protocol MSYCacheListDeleteViewDelegate: class {
    func msyCacheListDeleteView(deleteView: MSYCacheListDeleteView, isSelectAll: Bool)
    func msyCacheListDeleteViewDidClickDelete(deleteView: MSYCacheListDeleteView)
}

class MSYCacheListDeleteView: UIView, NibViewable {

    @IBOutlet weak var selectOrCancelAllBUtton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: MSYCacheListDeleteViewDelegate?
    
    @IBAction func clickSelectOrCancel(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.msyCacheListDeleteView(deleteView: self, isSelectAll: sender.isSelected)
    }
    
    @IBAction func clickDelete(_ sender: UIButton) {
        delegate?.msyCacheListDeleteViewDidClickDelete(deleteView: self)
    }
    
}
