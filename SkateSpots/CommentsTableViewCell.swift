//
//  CommentsTableViewCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/8/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: Comment! {
        didSet {
           layoutCell()
        }
    }

    func layoutCell() {
        userLabel.text = comment.userName
        print(comment.userName, comment.userImageURL, "here123")
        userImageView.kf.setImage(with: URL(string: comment.userImageURL))
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        commentTextView.text = comment.comment
        commentTextView.isEditable = false
        commentTextView.isScrollEnabled = false
        
    }
}
