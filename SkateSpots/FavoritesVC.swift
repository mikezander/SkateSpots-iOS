//
//  FavoritesVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/19/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage

class FavoritesVC:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var spots = [Spot]()
    
    @IBOutlet weak var spotTableView: UITableView!
    let currentUserRef = DataService.instance.REF_USERS.child(FIRAuth.auth()!.currentUser!.uid)

    override func viewDidLoad() {
        super.viewDidLoad()
        
       loadSpotsArray()

        
        
        
    }
    
    func loadSpotsArray(){
    
        DataService.instance.getSpotsFromUser(userRef: currentUserRef, child: "favorites", completionHandlerForGET: {success, data, error in
            
            if error == nil{
                self.spots = data!
                print(self.spots.count)
            }
             DispatchQueue.main.async {
                 self.spotTableView.reloadData()
              }
            
        })
    
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]
     
       let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteCell

       
        if let img = FeedVC.imageCache.object(forKey: NSString(string: spot.imageUrls[0])){
            
            cell.configureFavoriteCell(spot: spot,img: img)
        }else{
            cell.configureFavoriteCell(spot:spot)
        }

        return cell
    }

        
}


