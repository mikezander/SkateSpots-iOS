//
//  DetailVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class DetailVC: UIViewController{
    
    var spot: Spot!
    
    @IBOutlet weak var spotTypeLabel: UILabel!
    @IBOutlet weak var customNavBar: UIView!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = UIButton(type: .custom)
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

            return CGSize(width: screenWidth , height: self.photoCollectionView.frame.height)
        }
        
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
