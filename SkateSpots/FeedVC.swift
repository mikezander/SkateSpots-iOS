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
import SwiftKeychainWrapper
import FBSDKLoginKit
import SVProgressHUD
import MIBadgeButton_Swift
import SDWebImage

class FeedVC: UIViewController,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate{
    
    typealias DownloadComplete = () -> ()
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageLabel: MIBadgeButton!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var profileImageCache: NSCache<NSString, UIImage> = NSCache()
    
    var spots = [Spot]()
    var allSpotsR = [Spot]()
    var allSpotsD = [Spot]()
    let manager = CLLocationManager()
    var myLocation = CLLocation()
    var spotNumber = Int()
    var firstRun = true
    var firstSort = true
    var menuShowing = false
    var hasRan = false
    var isLoggedIn = Bool()
    let topItem = IndexPath(item: 0, section: 0)
    var badgeCount = 0
    var unReadUsers = Set<String>()
    
    var heightOffset:CGFloat = 140
    
    var screenSize = CGRect()
    var screenHeight = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isConnected()
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionFound(notification:)), name: notificationName, object: nil)
        
        screenSize = UIScreen.main.bounds
        screenHeight = screenSize.height
        

        if screenHeight == 812.0{
            UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
            heightOffset += 60
        }
 
        spotTableView.showsVerticalScrollIndicator = false
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        menuView.sizeToFit()

        messageLabel.badgeEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right:
            36)

    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spotTableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if Auth.auth().currentUser == nil {
            isLoggedIn = false
            performSegue(withIdentifier: "LogInVC", sender: nil)
            return
        }else{
            
            if UIApplication.isFirstLaunch() && !hasRan{
                UNService.shared.authorize()
                hasRan = true
                checkForCorrectProfileImage()
            }
            
            isLoggedIn = true
            setMessageNotificationBadge()
        }
        
        guard isInternetAvailable() else{
            spotTableView.backgroundView = setUpPlaceholderForNoInternet()
            errorAlert(title: "Internet Connection Error", message: "Make sure you are connected and try again//")
            return
        }
    }
    
    func internetConnectionFound(notification: NSNotification){
        
        loadSpotsbyRecentlyUploaded()
        print("connection made!")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
    @IBAction func signOutFBTest(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Mike: ID remover from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogInVC", sender: nil)
        
    }
    
    func checkForCorrectProfileImage(){
        let ref = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("profile")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let url = snapshot.childSnapshot(forPath: "userImageURL").value as? String {
                if url == DEFAULT_PROFILE_PIC_URL || url == DEFAULT_PROFILE_PIC_WORKING {
                    ref.updateChildValues(["userImageURL": DEFAULT_NEW])
                }
            }
        })
    }

    @IBAction func filterButtonPressed(_ sender: UIButton) {
        if isInternetAvailable() && hasConnected{
            
            SVProgressHUD.show()
            
            self.trailingConstraint.constant = -160
            self.spotTableView.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseOut,animations: {
                            self.spotTableView.layer.opacity = 1.0
                            self.view.layoutIfNeeded()
            })
            
            self.menuShowing = !self.menuShowing
            
            if self.segmentControl.selectedSegmentIndex == 0{
                self.spots = self.allSpotsR
            }else{
                self.spots = self.allSpotsD
            }
            
            switch(sender.tag){
                
            case 0 :
                if self.segmentControl.selectedSegmentIndex == 0{
                    self.spots = self.allSpotsR
                }else{
                    self.spots = self.allSpotsD
                }
                self.filterButton.setTitle("Filter Spots", for: .normal)
                
                break
            case 1:
                self.filterSpotsBy(type: "Skatepark")
                break
            case 2:
                self.filterSpotsBy(type: "Ledges")
                break
            case 3:
                self.filterSpotsBy(type: "Rail")
                break
            case 4:
                self.filterSpotsBy(type: "Stairs/Gap")
                break
            case 5:
                self.filterSpotsBy(type: "Bump")
                break
            case 6:
                self.filterSpotsBy(type: "Manual")
                break
            case 7:
                self.filterSpotsBy(type: "Bank")
                break
            case 8:
                self.filterSpotsBy(type: "Tranny")
                break
            case 9:
                self.filterSpotsBy(type: "Other")
                break
                
            default:
                break
                
            }
            
            SVProgressHUD.dismiss()
            
            self.spotTableView.reloadData()
            
            if self.spotTableView.numberOfRows(inSection: 0) > 0{
                self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
            }
            
        }else{
            
            self.errorAlert(title: "Internet Connection Error", message: "Make sure you have a connection and try again")
        }
        
    }
    
    func filterSpotsBy(type:String){
        let lowercaseType = type.lowercased()
        let filtered = self.spots.filter({return $0.sortBySpotType(type: lowercaseType) == true})
        self.spots = filtered
        self.filterButton.setTitle(type, for: .normal)
        
    }
    
    func setMessageNotificationBadge(){
 
        let userRef = DataService.instance.REF_BASE.child("user-messages").child(Auth.auth().currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in

            self.badgeCount = 0
            self.unReadUsers.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                
                self.messageLabel.badgeString = "\(self.badgeCount)"
                
                for snap in snapshot{
                    let userKey = snap.key
                    
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{

                        for value in spotDict.values{
                        if value.isEqual(0){
                            print(self.badgeCount)
                            self.badgeCount += 1
                            self.unReadUsers.insert(userKey)
                            
                            }
                        }
                     
                    }
                }
                
            }
            
            if self.badgeCount == 0{
                self.messageLabel.badgeBackgroundColor = .clear
                self.messageLabel.badgeTextColor = .clear
            }else{
                self.messageLabel.badgeString = "\(self.badgeCount)"
                self.messageLabel.badgeBackgroundColor = .black
                self.messageLabel.badgeTextColor = .white
                
            }
            
            MessagesVC.shared.unreadUsers = self.unReadUsers
        })
        

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
        
        
        if isLoggedIn{ SVProgressHUD.show() }
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        self.spots.insert(spot, at: 0)
                        
                    }
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.spotTableView.reloadData()
            }
            self.allSpotsR = self.spots
        })
        self.filterButton.setTitle("Filter Spots", for: .normal)
        
    }
    
    func sortSpotsByDistance(completed: @escaping DownloadComplete){
        
        SVProgressHUD.show()
        
        self.spots = self.allSpotsR
        
        self.spots.sort(by: { $0.distance(to: self.myLocation) < $1.distance(to: self.myLocation) })
        
        for spot in self.spots{
            let distanceInMeters = self.myLocation.distance(from: spot.location)
            let milesAway = distanceInMeters / 1609
            spot.distance = milesAway
            
            spot.removeCountry(spotLocation: spot.spotLocation)
            
        }
        completed()
        self.allSpotsD = self.spots
        self.filterButton.setTitle("Filter Spots", for: .normal)
        
    }
    
    @IBAction func toggle(_ sender: UISegmentedControl) {
        
        if hasConnected && isInternetAvailable(){ //Double check this
            
            
            
            if sender.selectedSegmentIndex == 1{
                
                self.manager.delegate = self
                self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.manager.requestWhenInUseAuthorization()
                self.manager.startUpdatingLocation()
                
            }else{
                
                self.loadSpotsbyRecentlyUploaded()
                self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
                self.spotTableView.reloadData()
                
            }
            
        }else{
            self.errorAlert(title: "Internet Connection Error", message: "Make sure you have a connection and try again")
        }
        
    }
    
    func setUpPlaceholderForNoInternet() -> UIView{
        let placeholderView = UIView()
        placeholderView.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: spotTableView.frame.height)
        let placeholderImage = UIImageView()
        placeholderImage.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: spotTableView.frame.height)
        placeholderImage.image = UIImage(named: "noInternetPlaceholder")
        placeholderView.addSubview(placeholderImage)
        return placeholderView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        
        if let location = locations.first {
            print("Found MY location: \(location)")
            myLocation = location
        }
        
        sortSpotsByDistance {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.spotTableView.reloadData()
                self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return (screenHeight - heightOffset)
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(lblClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    func lblClick(tapGesture:UITapGestureRecognizer){
        
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.userKey = spots[tapGesture.view!.tag].user
        self.navigationController?.pushViewController(vc, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpotRowCell") as! SpotRow

        
        cell.userName.isUserInteractionEnabled = true
        
        cell.userName.tag = indexPath.row
        
        cell.userName.addGestureRecognizer(setGestureRecognizer())
        cell.userImage.addGestureRecognizer(setGestureRecognizer())
        
        cell.configureRow(spot: spot)
      
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











