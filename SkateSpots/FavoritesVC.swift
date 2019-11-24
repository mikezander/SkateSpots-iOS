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

class FavoritesVC:UIViewController, UITableViewDelegate, UITableViewDataSource, SpotDetailDelegate {

    var allSpots = [Spot]()
    var spots = [Spot]()
    var spot: Spot!
    var uniqueIDs = [String]()
    
    @IBOutlet weak var spotTableView: UITableView!
    
    var currentUserRef = DatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
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
    
    func emptyFavoritesLabel()->UIView{
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let emptyView = UIView(frame: CGRect(x: 0, y:0 , width:screenWidth , height: screenHeight))
        
        let emptyLabel = UILabel(frame: CGRect(x: (screenWidth / 2) - 100, y: (screenHeight / 2) - 120, width: 200, height: 200))
        emptyLabel.text = "Add spots to favorites"
        emptyLabel.alpha = 0.4
        emptyLabel.textAlignment = NSTextAlignment.center
        emptyView.addSubview(emptyLabel)
        
        let emptyImage = UIImage(named: "add_fav_empty")
        let emptyImageView = UIImageView(image: emptyImage)
        emptyImageView.frame = CGRect(x: view.center.x - 40, y: emptyLabel.frame.origin.y - 20, width: 80, height: 80)
        emptyImageView.alpha = 0.4

        emptyView.addSubview(emptyImageView)
        return emptyView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if spots.count == 0 {
//            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0 ,width: 200 ,height: 200))
//            emptyLabel.text = "Add spots to favorites!"
//            emptyLabel.alpha = 0.4
//            emptyLabel.textAlignment = NSTextAlignment.center
//
//            let emptyImage = UIImage(named: "inbox")
//            let emptyImageView = UIImageView(image: emptyImage)
//            emptyImageView.frame = CGRect(x: emptyLabel.frame.origin.x + 50, y: emptyLabel.frame.origin.y - 20, width: 100, height: 100)
//            emptyImageView.alpha = 0.4
            
            self.spotTableView.backgroundView = self.emptyFavoritesLabel()
            self.spotTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
            
        } else {
            spotTableView.backgroundView?.isHidden = true
            return spots.count
        }
        
    }
    
    func nearbySpotPressed(spot: Spot, spots: [Spot]) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
            vc.spot = spot
            vc.spots = allSpots
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
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
        
        cell.configureFavoriteCell(spot:spot)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let spotCell = sender as? FavoriteCell,
            let spotDetailPage = segue.destination as? SpotDetailVC {
            let spot = spotCell.spot
            
            spotDetailPage.spot = spot
            spotDetailPage.spots = allSpots
            spotDetailPage.isFavorite = true
            spotDetailPage.delegate = self
        }
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}




