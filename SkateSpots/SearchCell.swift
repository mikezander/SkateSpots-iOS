//
//  SearchCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class SearchCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: CircleView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    func configureCell(user: User) {
        
        self.userNameLbl.text = user.userName
        
        self.profilePicImageView.sd_setImage(with: URL(string: user.userImageURL), placeholderImage: UIImage(named: "profile-placeholder"))
        
    }
}
