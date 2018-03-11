//
//  HeaderCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage

class HeaderCell: UITableViewCell, UITextViewDelegate{
    
    var profilePhoto: UIImageView!
    var userName: UILabel!
    var bio: UITextView!
    var link: UITextView!
    var igLink: UIButton!
    var contributions: UILabel!
    var status: UILabel!
    
    var igUsername = ""
    
    let screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: screenSize.width / 2 - 65, y: 10, width: 125, height: 125)
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.borderColor = FLAT_GREEN.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height / 2
        profilePhoto.clipsToBounds = true

        contentView.addSubview(profilePhoto)

        userName = UILabel()
        userName.frame = CGRect(x: 0 , y: profilePhoto.frame.origin.y + 135, width: screenSize.width, height: 20)
        userName.textAlignment = .center
        userName.textColor = UIColor.black
        userName.font = UIFont(name: "Avenir-Bold",size: 18)
        
        contentView.addSubview(userName)
        
        bio = UITextView()
        bio.frame = CGRect(x: 0 , y: userName.frame.origin.y + 17, width: screenSize.width, height: 20)
        bio.textContainer.maximumNumberOfLines = 2
        bio.textAlignment = .center
        bio.textColor = UIColor.black
        bio.backgroundColor = UIColor.clear
        bio.font = UIFont(name: "Avenir",size: 15)
        contentView.addSubview(bio)
        
        link = UITextView()
        link.frame = CGRect(x: 0 , y: bio.frame.origin.y, width: screenSize.width, height: 20)
        link.textAlignment = .center
        link.isUserInteractionEnabled = true
        link.isScrollEnabled = false
        link.isEditable = false
        link.isSelectable = true
        link.dataDetectorTypes = .link
        link.textColor = UIColor.blue
        link.backgroundColor = UIColor.groupTableViewBackground
        link.font = UIFont(name: "Avenir",size: 14)
        contentView.addSubview(link)
        
        
        
        igLink = UIButton()
        igLink.frame = CGRect(x: 0, y: link.frame.origin.y + link.frame.height + 7, width: screenSize.width, height: 20)
        igLink.isUserInteractionEnabled = true
        igLink.isHidden = true
        igLink.setImage(UIImage(named:"IGLogo"), for: .normal)
        igLink.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 20)
        igLink.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        igLink.backgroundColor = UIColor.groupTableViewBackground
        igLink.setTitleColor(UIColor.blue, for: .normal)
        igLink.titleLabel?.font = UIFont(name: "Avenir",size: 15)
        igLink.addTarget(self, action: #selector(instagramLinkPressed), for: .touchUpInside)
        contentView.addSubview(igLink)
  
        contributions = UILabel()
        contributions.frame = CGRect(x: profilePhoto.frame.origin.x , y: igLink.frame.origin.y + 85, width: 150, height: 20)
        contributions.textColor = UIColor.lightGray
        contributions.font = UIFont(name: "Avenir-Black",size: 14)
        contentView.addSubview(contributions)
        
    }
    
    
    func returnHeight()->CGFloat{
        
        return contributions.frame.origin.y
    }
    
    func instagramLinkPressed(){
        
        if igUsername != ""{
            
            let appURL = NSURL(string: "instagram://user?username=\(igUsername)")!
            let webURL = NSURL(string: "https://instagram.com/\(igUsername)")!
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                application.open(webURL as URL)
            }
            
        }else{
            return
        }
        
    }
    
    
    func configureProfilePic(userImage: String){
        self.profilePhoto.sd_setImage(with: URL(string: userImage), placeholderImage: UIImage(named: "profile-placeholder"))
    
    }
    
}
