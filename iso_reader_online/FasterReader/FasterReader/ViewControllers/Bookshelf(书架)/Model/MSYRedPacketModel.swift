//
//  File.swift
//  FasterReader
//
//  Created by apple on 2019/7/9.
//  Copyright © 2019 Restver. All rights reserved.
//

import Foundation
import HandyJSON

class MSYAdModel: HandyJSON {
    
//    location：内部位置 1 开屏 2 文章末尾 3 书架图书 4书架浮标

    required init() {}
    
    var cover = "http://upld.17k.ren/xiaoshuo/97/98/5b3f02b2d264.png"
    var id = 0
    var link = ""
    var location = 0
    var title = ""
    
    static func getFloadAdRequest(success: @escaping (MSYAdModel) -> () ) {
        let paramsDict = NSMutableDictionary()
        
        JPNetWork.sharedManager()?.requestPostMethod(withPathUrl: JPTool.bookshelfFloatAdPath(), withParamsDict: paramsDict, withSuccessBlock: { (response) in

            guard let responseDic = response as? Dictionary<String, Any>,
                let data = responseDic["data"] as? [Dictionary<String, Any>],
                let models = [MSYAdModel].deserialize(from: data) as? [MSYAdModel] else { return }
            
            let res = models.filter({ (model) -> Bool in
                return model.location == 4
            })
            
            if let first = res.first {
                success(first)
            }else{
                print("没有书架浮动红包广告")
            }
            
            }, withFailurBlock: { (error) in }
        )
    }
    
    
}
