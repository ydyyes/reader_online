//
//  MSYReadContentBGController.swift
//  FasterReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 Restver. All rights reserved.
//

import UIKit

@objcMembers class MSYReadContentBGController: UIViewController {
    
    var pageIndex: Int = 0
    var chapterIndex: Int = 0
    var isHaveEnoughSpaceToShowAd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MSYReaderSetting.shareInstance()?.getReaderBackgroundColor()?.withAlphaComponent(0.95)
        
    }

}
