//
//  MSYMineModel.swift
//  NightReader
//
//  Created by apple on 2019/7/1.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import Foundation

class MSYMineModel {
    var title = ""
    var imageName = ""
    var desTitle = ""
    
}

@objcMembers class MSYBookCacheModel: NSObject, NSCoding {
    var bookId = ""
    var bookName = ""
    var cover = ""
    var lastChapter = ""
    var author = ""
    var majorCate = ""
    var updated = ""
    
    
    var chaptersCount: Int = 0
    var downloadChaptersCount: Int = 0
    var downloadStatus = MSYBookDownloadStatus.suspendDownload {
        didSet{
            MSYBookCache.setDownloadState(downloadStatus, bookid: bookId)
        }
    }
    var progress: Float {
        let pro = Float(downloadChaptersCount) / Float( chaptersCount)
        return pro
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        bookId = aDecoder.decodeObject(forKey: "bookId") as? String ?? ""
        bookName = aDecoder.decodeObject(forKey: "bookName") as? String ?? ""
        cover = aDecoder.decodeObject(forKey: "cover") as? String ?? ""
        lastChapter = aDecoder.decodeObject(forKey: "lastChapter") as? String ?? ""
        author = aDecoder.decodeObject(forKey: "author") as? String ?? ""
        majorCate = aDecoder.decodeObject(forKey: "majorCate") as? String ?? ""
        updated = aDecoder.decodeObject(forKey: "updated") as? String ?? ""

        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bookId, forKey: "bookId")
        aCoder.encode(bookName, forKey: "bookName")
        aCoder.encode(cover, forKey: "cover")
        aCoder.encode(lastChapter, forKey: "lastChapter")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(majorCate, forKey: "majorCate")
        aCoder.encode(updated, forKey: "updated")

    }
    
}
