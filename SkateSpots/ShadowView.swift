//
//  ShadowView.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/8/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.lightGray
        let shadowSize : CGFloat = 7.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: UIScreen.main.bounds.width + shadowSize,
                                                   height: frame.size.height + shadowSize))
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.8
        layer.shadowPath = shadowPath.cgPath
    }
}

