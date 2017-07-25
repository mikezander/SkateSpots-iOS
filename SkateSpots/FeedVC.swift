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
import CoreLocation

class FeedVC: UIViewController,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate{

    let manager = CLLocationManager()
    var myLocation = CLLocation()
    typealias DownloadComplete = () -> ()
    var firstSort = true
    var spotNumber = Int()
   
    @IBOutlet weak var spotTableView: UITableView!
    
    var spots = [Spot]()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { self.spotTableView.reloadData() }
        
        loadSpotsbyRecentlyUploaded()
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

       guard FIRAuth.auth()?.currentUser != nil else{
            performSegue(withIdentifier: "LogInVC", sender: nil)
            return
        }
        
    }
 

    func loadSpotsbyRecentlyUploaded(){
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot{
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        //self.spots.append(spot)
                        self.spots.insert(spot, at: 0)
                    }
                }
            }
            DispatchQueue.main.async { self.spotTableView.reloadData() }
        })
    
    }

    func sortSpotsByDistance(completed: @escaping DownloadComplete){
        
        spots.sort(by: { $0.distance(to: myLocation) < $1.distance(to: myLocation) })
    
        for spot in spots{
            let distanceInMeters = myLocation.distance(from: spot.location)
            let miles = distanceInMeters / 1609
            spot.distance = miles
        }
        completed()
    }
    
    @IBAction func toggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1{
            
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        
        }else{
            
            loadSpotsbyRecentlyUploaded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found MY location: \(location)")
            myLocation = location
        }
        sortSpotsByDistance {
             DispatchQueue.main.async {self.spotTableView.reloadData()}
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let heightOffset:CGFloat = 140
        return (screenHeight - heightOffset)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return spots.count
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let navController = segue.destination as! UINavigationController
        if let spotCell = sender as? SpotPhotoCell,
            //let spotDetailPage = navController.viewControllers[0] as? DetailVC{
            let spotDetailPage = segue.destination as? DetailVC {
            let spot = spotCell.spot
            print("\(spot?.spotName as Any)yooooo")
            spotDetailPage.spot = spot
        }
    }

}











