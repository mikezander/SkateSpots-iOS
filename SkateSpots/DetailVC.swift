//
//  DetailVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class DetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var spot: Spot!
    
    var scrollView: UIScrollView!
    var containerView = UIView()
    var collectionview: UICollectionView!
    var cellId = "Cell"
    var imageView: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight + 500)
        
        containerView = UIView()
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
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
        

        //imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: screenWidth, height: screenHeight - 100))
        //self.collectionview.addSubview(imageView)
        
        
     
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

        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DetailPhotoCell
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 130)) //y sets image height**
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
