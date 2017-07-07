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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var spotCollectionView: UICollectionView!
    
    var spots = [Spot]()
    
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
                        print(spot.imageUrls[1])
                    }
                }
            }
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = spotCollectionView.dequeueReusableCell(withReuseIdentifier: "SpotCollectionView", for: indexPath)
        
        return cell
    }


}

