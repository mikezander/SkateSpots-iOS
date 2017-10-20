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
    
    var currentUserRef = DatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserRef = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid)
        
        guard hasConnected else {
            errorAlert(title: "Network Connection Error", message: "Make sure you connected and try again")
            return
        }
        
        loadSpotsArray()
        
    }
    
    func loadSpotsArray(){
        
        DataService.instance.getSpotsFromUser(userRef: currentUserRef, child: "favorites", completionHandlerForGET: {success, data, keys, error in
            
            if error == nil{
                self.spots = data!
                self.uniqueIDs = keys
                
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
        
        if spots.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x:0, y:0,width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height))
            emptyLabel.text = "Add spots to favorites!"
            emptyLabel.alpha = 0.4
            emptyLabel.textAlignment = NSTextAlignment.center
            self.spotTableView.backgroundView = emptyLabel
            self.spotTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
            
        }else{
            spotTableView.backgroundView?.isHidden = true
            return spots.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete{
            
            currentUserRef.child("favorites").child(uniqueIDs[indexPath.row]).removeValue()
            
            uniqueIDs.remove(at: indexPath.item)
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
            spotDetailPage.isFavorite = true
        }
    }
    
    
}


