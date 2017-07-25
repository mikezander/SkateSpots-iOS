//
//  DetailVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class DetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var spot: Spot!
    
    var scrollView: UIScrollView!
    var containerView = UIView()
    var collectionview: UICollectionView!
    var cellId = "Cell"
    var ratingView = CosmosView()
 
    let screenSize = UIScreen.main.bounds

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight * 2)
        
        containerView = UIView()
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        let customNav = UIView(frame: CGRect(x:0,y: 0,width: screenWidth,height: 50))
        customNav.backgroundColor = UIColor(red: 127/255, green: 173/255, blue: 82/255, alpha: 1)

       // (127, 173, 82)
        self.view.addSubview(customNav)
        
        let btn1 = UIButton()
        btn1.setTitle("Back", for: .normal)
       
        btn1.frame = CGRect(x:0, y:20, width: 45,height: 35)
        btn1.addTarget(self, action:#selector(backButtonPressed), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth, height: screenHeight)
        layout.scrollDirection = .horizontal
 
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.collectionViewLayout = layout
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(DetailPhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.containerView.addSubview(collectionview)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.center = CGPoint(x: screenWidth / 2, y: screenHeight - 125)
        label.textAlignment = .center
        label.text = spot.spotName
        self.containerView.addSubview(label)
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        label2.font = UIFont.preferredFont(forTextStyle: .caption1)
        label2.textColor = .black
        label2.center = CGPoint(x: screenWidth / 2, y: screenHeight - 100)
        label2.textAlignment = .center
        label2.text = spot.spotType
        self.containerView.addSubview(label2)
        
        let ratingDisplayView = CosmosView(frame: CGRect(x:0, y:0, width: 250,height: 20))
        ratingDisplayView.center = CGPoint(x: screenWidth / 2 , y: screenHeight - 80)
        ratingDisplayView.settings.updateOnTouch = false
        ratingDisplayView.settings.fillMode = .precise
        containerView.addSubview(ratingDisplayView)
        

        ratingView.settings.starSize = 30
        ratingView.frame = CGRect(x: 0 , y: 0, width: 250, height: 100)
        ratingView.center = CGPoint(x: screenWidth / 2 + 35, y: screenHeight + (screenHeight - 100))
        ratingView.settings.fillMode = .precise
        containerView.addSubview(ratingView)
        
        let rateBtn = RoundedButton(frame: CGRect(x:0, y:0, width: 100,height: 20))
        rateBtn.center = CGPoint(x: screenWidth / 2, y: screenHeight + (screenHeight - 100))
        rateBtn.setTitle("Rate Spot!", for: .normal)
        rateBtn.backgroundColor = UIColor.black
        rateBtn.cornerRadius = 2.0
        rateBtn.addTarget(self, action:#selector(rateSpotPressed), for: .touchUpInside)
        
        rateBtn.alpha = 0.3
        rateBtn.isEnabled = false
        containerView.addSubview(rateBtn)
        
        
        ratingView.didFinishTouchingCosmos = { rating in
            rateBtn.alpha = 1
            rateBtn.isEnabled = true
            let displayRating = String(format: "%.1f", rating)
            self.ratingView.text = "(\(displayRating))"
            self.ratingView.settings.filledBorderColor = UIColor.black
        }
       
}
    
    func rateSpotPressed(){
   
        let rating: Dictionary<String, AnyObject> = [
            "rating": ratingView.rating as AnyObject]
        
    let firebasePost = DataService.instance.REF_SPOTS.child(spot.spotKey)
    firebasePost.updateChildValues(rating)
    
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = CGRect(x:0, y:50, width:scrollView.contentSize.width, height:scrollView.contentSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return spot.imageUrls.count
    }

    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 150))
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DetailPhotoCell
  
        cell.spotImage = image
        cell.addSubview(image)
        
        if indexPath.row < spot.imageUrls.count{

            
            if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[indexPath.row] as NSString){
                print(indexPath.row)
                
                cell.configureCell(spot: spot, img: img, count: indexPath.row)
            }else{
                cell.configureCell(spot: spot, count: indexPath.row)
            }
            
            
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

      /*  let btn1 = UIButton(type: .custom)
        btn1.setTitle("Back", for: .normal)
        btn1.frame = CGRect(x: 0, y: 10, width: 50, height: 50)
        btn1.addTarget(self, action: #selector(DetailVC.backButtonPressed(_:)), for: .touchUpInside)
       customNavBar.addSubview(btn1)
    
        photoCollectionView.reloadData()
        
        spotNameLabel.text = spot.spotName
        spotTypeLabel.text = spot.spotType
        self.automaticallyAdjustsScrollViewInsets = false
        
   
    }

   
    func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension DetailVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return spot.imageUrls.count
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailPhotoCell
        
        if indexPath.row < spot.imageUrls.count{
            
            if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[indexPath.row] as NSString){
                print(indexPath.row)
                
                cell.configureCell(spot: spot, img: img, count: indexPath.row)
            }else{
                cell.configureCell(spot: spot, count: indexPath.row)
            }
            
          
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //top, left, bottom, right

        return UIEdgeInsets(top: -18, left: 0, bottom: 0, right: 0)
    }
    
}

extension DetailVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        print("working")
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width

            return CGSize(width: screenWidth , height: self.scrollView.frame.height * 0.8)
        }
        
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}*/
