//
//  RoundedShadowUIView.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 3/11/18.
//  Copyright © 2018 Michael Alexander. All rights reserved.
//

import UIKit

class RoundedShadowUIView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = frame.width / 2
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 2.0
        layer.masksToBounds = false
    }
    
}
