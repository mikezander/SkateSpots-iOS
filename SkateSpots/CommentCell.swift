//
//  CommentCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/31/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage

class CommentCell: UITableViewCell{

    var profilePhoto: UIImageView!
    var userName: UILabel!
    var comment: UITextView!

    var CellHeight = CGFloat()

    
    let screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
 
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

       CellHeight = 100
    
        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: 10, y: 5, width: 50, height: 50)
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = FLAT_GREEN.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        contentView.addSubview(profilePhoto)
        
        userName = UILabel()
        userName.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width+10 , y: 5, width: screenSize.width - (profilePhoto.frame.origin.x+profilePhoto.frame.width + 25), height: 20)
        userName.textColor = UIColor.blue
        userName.isUserInteractionEnabled = true
        userName.font = UIFont(name: "Avenir",size: 14)
        
        contentView.addSubview(userName)
        
        comment = UITextView()
        comment.isScrollEnabled = false
        comment.isEditable = false
        comment.isSelectable = false
        
        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 5, y: userName.frame.origin.y + 10, width: screenSize.width - (profilePhoto.frame.origin.x+profilePhoto.frame.width + 25), height: 115)
        
        comment.font = UIFont(name: "Helvetica", size: 15)
        
        comment.textColor = UIColor.black
        
        comment.backgroundColor = UIColor.clear

        if screenSize.height <= 568.0 {
            comment.font = UIFont(name: "Helvetica", size: 13)
            userName.font = UIFont(name: "Avenir", size: 12)
        }else if screenSize.height > 568.0 &&  screenSize.height < 700.0{
            comment.font = UIFont(name: "Helvetica", size: 14)
            userName.font = UIFont(name: "Avenir", size: 13)
            //userName.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        }else {
            
            comment.font = UIFont(name: "Helvetica", size: 15)
            userName.font = UIFont(name: "Avenir", size: 14)
        }
        
        print("\(screenSize.height)yooo")
       
        
        contentView.addSubview(comment)

    }
    
    func configureProfilePic(comment: Comment, img: UIImage? = nil){
        
        //download images
        if img != nil{
            
            self.profilePhoto.image = img
            
            
        }else{
            
            //cache image
            
            let ref = FIRStorage.storage().reference(forURL:comment.userImageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    print("Mike: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {
                        
                        
                        if let img = UIImage(data: imgData){
                            self.profilePhoto.image = img
                            FeedVC.imageCache.setObject(img, forKey: comment.userImageURL as NSString)
                        }
                        
                        
                    }
                }
                
            })
        }
        
    }
   
    func emptyImageView(){
        self.profilePhoto.image = nil
    }
 
    

}
