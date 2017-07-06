//
//  RoundTextField.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextfield: UITextField{

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    
    }
    
    @IBInspectable var borderColor: UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColor: UIColor?{
        didSet{
            backgroundColor = bgColor
        }
    }
    
    @IBInspectable var placeHolerColor: UIColor?{
        didSet{
            
            let rawString = attributedPlaceholder?.string != nil ? attributedPlaceholder!.string : ""
            
            let str = NSAttributedString(string: rawString, attributes: [NSForegroundColorAttributeName: placeHolerColor!])
            attributedPlaceholder = str
        }
    }
}
