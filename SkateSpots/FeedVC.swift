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

class FeedVC: UIViewController,UITableViewDataSource, UITableViewDelegate{

   
    @IBOutlet weak var spotTableView: UITableView!
    
    var spots = [Spot]()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { self.spotTableView.reloadData() }
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot{
                    print("Snap:\(snap)")
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        self.spots.append(spot)
                    }
                }
            }
            DispatchQueue.main.async { self.spotTableView.reloadData() }
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
   /* var categories = ["Action", "Drama", "Science Fiction", "Kids", "Horror"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }*/

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotRowCell") as! SpotRow
        
        print("\(indexPath.row)\(spot.spotName)")
        cell.configureRow(spot: spot)
        
        return cell
    }
    
  /*  func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let spot = spots[indexPath.row]

        let cell = spotCollectionView.dequeueReusableCell(withReuseIdentifier: "SpotCollectionView", for: indexPath) as! SpotCollectionViewCell
        
        if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[0] as NSString){
            cell.configureCell(spot: spot, img: img, count: 0)
        }else{
            cell.configureCell(spot: spot, count: 0)
        }
        
        return cell
    }*/

    
}

