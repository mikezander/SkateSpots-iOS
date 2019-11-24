//
//  UserCommentCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/7/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//
import UIKit

class UserCommentCell : UITableViewCell {
   // let textView = UITextView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViewsAndlayout()
//        textView.translatesAutoresizingMaskIntoConstraints = false
//
//        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

    }
    
    public func setHeight() {
        
        textView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height:  textView.sizeThatFits(textView.frame.size).height)
        contentView.frame.size.height = textView.sizeThatFits(textView.frame.size).height
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.backgroundColor = .red
        layoutIfNeeded()

//        let sizeThatShouldFitTheContent =
//        let height = sizeThatShouldFitTheContent.height
//        textView.heightAnchor.constraint(equalToConstant: height).isActive = true
//        frame.size.height = height
//        layoutIfNeeded()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //Add View Programmatically or in xib
    let textView: UITextView = {
        let txtView = UITextView()
        //txtView.translatesAutoresizingMaskIntoConstraints = false
//        txtView.sizeToFit()
        txtView.isScrollEnabled = false
        return txtView
    }()

    //…

    /// Add and sets up subviews with programmically added constraints
    func addSubViewsAndlayout() {
        contentView.addSubview(textView) //will crash if not added
        textView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height:  textView.sizeThatFits(textView.frame.size).height)

//        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
}
