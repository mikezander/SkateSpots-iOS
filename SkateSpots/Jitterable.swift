//
//  Jitterable.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 3/15/18.
//  Copyright © 2018 Michael Alexander. All rights reserved.
//

import UIKit

protocol Jitterable {}

extension Jitterable where Self: UIView {
    func jitter() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x: center.x - 5.0, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: center.x + 5.0, y: center.y))
        layer.add(animation, forKey: "position")
    }
}
