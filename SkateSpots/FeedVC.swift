//
//  ViewController.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/5/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class FeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var spotCollectionView: UICollectionView!
    
    var spots = [Spot]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot{
                    print("Snap:\(snap)")
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        self.spots.append(spot)
                       // print(spot.imageUrls[1])
                    }
                }
            }
            self.spotCollectionView.reloadData()
        })
  
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //performSegue(withIdentifier: "LogInVC", sender: nil)
       guard FIRAuth.auth()?.currentUser != nil else{
            performSegue(withIdentifier: "LogInVC", sender: nil)
            return
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let spot = spots[indexPath.row]
        //print("fdsf\(spot.imageUrls[2])")

        
        let cell = spotCollectionView.dequeueReusableCell(withReuseIdentifier: "SpotCollectionView", for: indexPath) as! SpotCollectionViewCell

        
        if let img = FeedVC.imageCache.object(forKey:spot.imageUrls[0] as NSString){
            cell.configureCell(spot: spot, img: img, count: 0)
        }else{
            cell.configureCell(spot: spot,img: nil, count: 0)
        }
        
        return cell
    }


}

