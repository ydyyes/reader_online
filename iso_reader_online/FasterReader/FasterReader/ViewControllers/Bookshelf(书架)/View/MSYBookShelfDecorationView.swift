//
//  MSYBookShelfDecorationView.swift
//  NightReader
//
//  Created by apple on 2019/6/27.
//  Copyright © 2019 MSYMobile. All rights reserved.
//

import UIKit

let MSYBookShelfKindDecoration = "MSYBookShelfDecorationView"

class MSYBookShelfDecorationView: UICollectionReusableView {

    @IBOutlet weak var leftBackGroungImageView: UIImageView!
    @IBOutlet weak var centerBackGroungImageView: UIImageView!
    @IBOutlet weak var rightBackGroungImageView: UIImageView!
    
    private let leftImage = UIImage.init(named: "left.9")
    private let centerImage = UIImage.init(named: "zhongjian.9")
    private let rightImage = UIImage.init(named: "right.9")

    override func awakeFromNib() {
        super.awakeFromNib()

//        backgroundColor = .red
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let width = layoutAttributes.bounds.width
        let height = layoutAttributes.bounds.height
        
        
        var x :CGFloat = 0
        
        leftBackGroungImageView.frame = CGRect(x: x, y: 0, width: width / 4, height: height)
        if var leftImage = leftImage {
            let edge = UIEdgeInsets(top: 0, left: leftImage.size.width * 0.4, bottom: 0, right: 0)
            leftImage = leftImage.resizableImage(withCapInsets: edge, resizingMode: .stretch)
            leftBackGroungImageView.image = leftImage
        }

        x = leftBackGroungImageView.frame.maxX - 1
        centerBackGroungImageView.frame = CGRect(x: x, y: 0, width: width / 2, height: height)
        if var centerImage = centerImage {
            let protect = centerImage.size.width * 0.4
            let edge = UIEdgeInsets(top: 0, left: protect, bottom: 0, right: protect)
            centerImage = centerImage.resizableImage(withCapInsets: edge, resizingMode: .stretch)
            centerBackGroungImageView.image = centerImage
        }

        x = centerBackGroungImageView.frame.maxX - 1
        rightBackGroungImageView.frame = CGRect(x: x, y: 0, width: width / 4, height: height)
        if var rightImage = rightImage {
            let edge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightImage.size.width * 0.5)
            rightImage = rightImage.resizableImage(withCapInsets: edge, resizingMode: .stretch)
            rightBackGroungImageView.image = rightImage
        }

    }
    
}
