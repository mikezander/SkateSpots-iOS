//
//  CircleView.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/26/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class CircleView: UIImageView{

    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2 
    }
    
    
}
