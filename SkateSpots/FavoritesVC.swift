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
import FirebaseDatabase

class FavoritesVC:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var spots = [Spot]()
    var spot: Spot!
    var uniqueIDs = [String]()
    
    @IBOutlet weak var spotTableView: UITableView!
    let currentUserRef = DataService.instance.REF_USERS.child(FIRAuth.auth()!.currentUser!.uid)

    override func viewDidLoad() {
        super.viewDidLoad()
        
       loadSpotsArray()
        
       loadAutoIdArray()
        
        for id in uniqueIDs{
        print(id)
        }
        

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
    
    func loadAutoIdArray(){
        
        DataService.instance.retrieveFavoritesAutoIDs(userRef: currentUserRef, completionHandlerForGET: { success, data in
            if success == true{
                self.uniqueIDs = data!
                print(self.uniqueIDs)
            }else{
            print("error getting favorite auto ids")
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        
        if editingStyle == .delete{
            
            currentUserRef.child("favorites").child(uniqueIDs[indexPath.row]).removeValue()
            
        spots.remove(at: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]
     
       let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteCell

       cell.emptyImageView()
        
        if let img = FeedVC.imageCache.object(forKey: NSString(string: spot.imageUrls[0])){
            
            cell.configureFavoriteCell(spot: spot,img: img)
        }else{
            cell.configureFavoriteCell(spot:spot)
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let spotCell = sender as? FavoriteCell,
            let spotDetailPage = segue.destination as? DetailVC {
            let spot = spotCell.spot
            spotDetailPage.spot = spot
            spotDetailPage.favoriteButton.isEnabled = false
        }
    }

        
}


