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
import MapKit
import FBSDKCoreKit

class FeedVC: UIViewController,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate{

    let manager = CLLocationManager()
    var myLocation = CLLocation()
    typealias DownloadComplete = () -> ()
    var firstSort = true
    var spotNumber = Int()
   
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var spots = [Spot]()
    var allSpotsR = [Spot]()
    var allSpotsD = [Spot]()
    var firstRun = true
   
    let topItem = IndexPath(item: 0, section: 0)

    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var profileImageCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var menuShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { self.spotTableView.reloadData() }
        
        loadSpotsbyRecentlyUploaded()
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        menuView.sizeToFit()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spotTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       // performSegue(withIdentifier: "LogInVC", sender: nil) used for logging out, firebase tracks phone id*
        if FIRAuth.auth()?.currentUser == nil {
            performSegue(withIdentifier: "LogInVC", sender: nil)
           return
        }
        
        
    }

  

    @IBAction func signOutFBTest(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrent(nil)
        
    }

    @IBAction func filterButtonPressed(_ sender: UIButton) {
        
        trailingConstraint.constant = -160
        self.spotTableView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                       options: .curveEaseOut,animations: {
                        self.spotTableView.layer.opacity = 1.0
                        self.view.layoutIfNeeded()
        })
        
        menuShowing = !menuShowing
        
        if segmentControl.selectedSegmentIndex == 0{
            spots = allSpotsR
        }else{
            spots = allSpotsD
        }

        if sender.tag == 0{
            if segmentControl.selectedSegmentIndex == 0{
                spots = allSpotsR
            }else{
                spots = allSpotsD
            }
         
            filterButton.setTitle("Filter Spots", for: .normal)
        
        }else if sender.tag == 1{
            let filtered = spots.filter({return $0.sortBySpotType(type: "skatepark") == true})
            spots = filtered
            filterButton.setTitle("Skatepark", for: .normal)
        
        }else if sender.tag == 2{
            let filtered = spots.filter({return $0.sortBySpotType(type: "ledges") == true})
            spots = filtered
            filterButton.setTitle("Ledges", for: .normal)
            
        }else if sender.tag == 3{
            let filtered = spots.filter({return $0.sortBySpotType(type: "rail") == true})
            spots = filtered
            filterButton.setTitle("Rail", for: .normal)
            
        }else if sender.tag == 4{
            let filtered = spots.filter({return $0.sortBySpotType(type: "stairs/gap") == true})
            spots = filtered
            filterButton.setTitle("Stairs/Gap", for: .normal)
            
        }else if sender.tag == 5{
            let filtered = spots.filter({return $0.sortBySpotType(type: "bump") == true})
            spots = filtered
            filterButton.setTitle("Bump", for: .normal)
            
        }else if sender.tag == 6{
            let filtered = spots.filter({return $0.sortBySpotType(type: "manual") == true})
            spots = filtered
            filterButton.setTitle("Manual", for: .normal)
            
        }else if sender.tag == 7{
            let filtered = spots.filter({return $0.sortBySpotType(type: "bank") == true})
            spots = filtered
            filterButton.setTitle("Bank", for: .normal)

        }else if sender.tag == 8{
            let filtered = spots.filter({return $0.sortBySpotType(type: "tranny") == true})
            spots = filtered
            filterButton.setTitle("Tranny", for: .normal)
            
        }else if sender.tag == 9{
            let filtered = spots.filter({return $0.sortBySpotType(type: "other") == true})
            spots = filtered
            filterButton.setTitle("Other", for: .normal)
            
        }
        spotTableView.reloadData()
        spotTableView.scrollToRow(at: topItem, at: .top, animated: false)
    }
   
    @IBAction func openFilterMenu(_ sender: Any) {
    
        if menuShowing{
            trailingConstraint.constant = -160
            self.spotTableView.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseOut,animations: {
                            self.spotTableView.layer.opacity = 1.0
                            self.view.layoutIfNeeded()
            })
        }else{
            trailingConstraint.constant = 0
            self.spotTableView.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseIn,animations: {
                            self.spotTableView.layer.opacity = 0.5
                            self.view.layoutIfNeeded()
            })
        }
        menuShowing = !menuShowing
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
            self.allSpotsR = self.spots
        })
        filterButton.setTitle("Filter Spots", for: .normal)
    }

    func sortSpotsByDistance(completed: @escaping DownloadComplete){
        
        spots = allSpotsR
 
        spots.sort(by: { $0.distance(to: myLocation) < $1.distance(to: myLocation) })

    
        for spot in spots{
            let distanceInMeters = myLocation.distance(from: spot.location)
            let miles = distanceInMeters / 1609
            spot.distance = miles
            
            spot.removeCountry(spotLocation: spot.spotLocation)

        }
        completed()
        self.allSpotsD = spots
        filterButton.setTitle("Filter Spots", for: .normal)
        
    }
    

    @IBAction func toggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1{
            
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        
        }else{
            
            loadSpotsbyRecentlyUploaded()
            spotTableView.scrollToRow(at: topItem, at: .top, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found MY location: \(location)")
            myLocation = location
        }
        sortSpotsByDistance {
             DispatchQueue.main.async {
             self.spotTableView.reloadData()
             self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
            }
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
 

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotRowCell") as! SpotRow
        
        if let img = FeedVC.imageCache.object(forKey: spot.userImageURL as NSString){

            cell.configureRow(spot: spot, img: img)
        }else{
            cell.configureRow(spot: spot)
        }

        cell.delegate = self
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let spotCell = sender as? SpotPhotoCell,
            let spotDetailPage = segue.destination as? DetailVC {
            let spot = spotCell.spot
            spotDetailPage.spot = spot
        }
    }
}
extension FeedVC: SpotRowDelegate{

    func didTapDirectionsButton(spot: Spot) {
        let coordinate = CLLocationCoordinate2DMake(spot.latitude, spot.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = spot.spotName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}











