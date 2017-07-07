//
//  ViewController.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/5/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var spotCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.instance.REF_SPOTS.observe(<#T##eventType: FIRDataEventType##FIRDataEventType#>, with: <#T##(FIRDataSnapshot) -> Void#>)
  
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

