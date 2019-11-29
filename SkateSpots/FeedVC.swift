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
import RevealingSplashView
import Foundation
import GeoFire
import GoogleMobileAds

class FeedVC: UIViewController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, SpotDetailDelegate {

    typealias DownloadComplete = () -> ()
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: MIBadgeButton!
    @IBOutlet var bannerView: GADBannerView!

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
    var initialLoad = true
    var activityItems = [Any]()
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launch_screen_icon")!, iconInitialSize: CGSize(width: 120, height: 120), backgroundImage: UIImage(named: "city_push")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableGoogleAds()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        if #available(iOS 13.0, *) {
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            shadow.shadowOffset = CGSize(width: 0, height: 1)
            let titleFont : UIFont = UIFont.systemFont(ofSize: 15.0)

            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .shadow: shadow, .font: titleFont], for: .selected)
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black, .shadow: shadow, .font: titleFont], for: .normal)

            segmentControl.backgroundColor = .white
            segmentControl.selectedSegmentTintColor = .black
            
            
//
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
        }
  
        if UserDefaults.standard.bool(forKey: "launch") == true {
            setupSplashView()
            UserDefaults.standard.set(false, forKey: "launch")
        }

        isConnected()
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionFound(notification:)), name: internetConnectionNotification, object: nil)

        spotTableView.showsVerticalScrollIndicator = false

        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        menuView.sizeToFit()
        
        messageLabel.badgeEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right:
            36)

    }

    private func enableGoogleAds() {
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-2517724326209105/9254765611"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spotTableView.reloadData()
        
//        DataService.instance.REF_USERS.observe(.value, with: {(snapshot) in
//            var users = [User]()
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
//                for snap in snapshot{
//
//
//
//                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
//                        let key = snap.key
//                        let user = User(userKey: key, userData: spotDict)
//                        users.append(user)
//                    }
//                }
//                print(users.count, "here")
//            }
//        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser == nil {
            isLoggedIn = false
            performSegue(withIdentifier: "LogInVC", sender: nil)
            return
        }else{
            if UIApplication.isFirstLaunch() && !hasRan {
                UNService.shared.authorize()
                hasRan = true
                checkForCorrectProfileImage()
            }
            
            isLoggedIn = true
            setMessageNotificationBadge()
        }
        
        guard isInternetAvailable() else{
            spotTableView.backgroundView = setUpPlaceholderForNoInternet()
            errorAlert(title: "Internet Connection Error", message: "Make sure you have a internet connection and try again.")
            return
        }
    }
    
    @objc func internetConnectionFound(notification: NSNotification){
        revealingSplashView.startAnimation()
        loadSpotsbyRecentlyUploaded()
        NotificationCenter.default.removeObserver(self, name: internetConnectionNotification, object: nil)
    }

    func setupSplashView() {
        let blackLayerView = UIView(frame: self.view.frame)
        blackLayerView.backgroundColor = .black
        blackLayerView.alpha = 0.6
        revealingSplashView.backgroundImageView?.addSubview(blackLayerView)
        
        view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .popAndZoomOut
        
        UIView.animate(withDuration: 2.5) {
            blackLayerView.alpha = 1.0
        }
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
            
            if self.segmentControl.selectedSegmentIndex == 0 {
                self.spots = self.allSpotsR
            }else{
                self.spots = self.allSpotsD
            }
            
            if let spotType = sender.titleLabel?.text {
                if spotType == "All" {
                    spots = segmentControl.selectedSegmentIndex == 0 ? allSpotsR : allSpotsD
                } else {
                    filterSpotsBy(type: spotType)
                }
            }

            SVProgressHUD.dismiss()
            
            self.spotTableView.reloadData()
            
            if self.spotTableView.numberOfRows(inSection: 0) > 0 {
                self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
            }
            
        } else {
            self.errorAlert(title: "Internet Connection Error", message: "Make sure you have a connection and try again")
        }
        
    }
    
    func filterSpotsBy(type:String){
        let lowercaseType = type.lowercased()
        let filtered = self.spots.filter({ return $0.sortBySpotType(type: lowercaseType) == true })
        self.spots = filtered
        self.filterButton.setTitle(type, for: .normal)
        
    }
    
    func setMessageNotificationBadge(){
        let userRef = DataService.instance.REF_BASE.child("user-messages").child(Auth.auth().currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            
            self.badgeCount = 0
            self.unReadUsers.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                self.messageLabel.badgeString = "\(self.badgeCount)"
                
                for snap in snapshot {
                    let userKey = snap.key
                    
                    if let spotDict = snap.value as? Dictionary<String, AnyObject> {
                        for value in spotDict.values{
                        if value.isEqual(0) {
                            self.badgeCount += 1
                            self.unReadUsers.insert(userKey)
                            }
                        }
                    }
                }
            }
            
            if self.badgeCount == 0 {
                self.messageLabel.badgeBackgroundColor = .clear
                self.messageLabel.badgeTextColor = .clear
            } else {
                self.messageLabel.badgeString = "\(self.badgeCount)"
                self.messageLabel.badgeBackgroundColor = .black
                self.messageLabel.badgeTextColor = .white
            }
            MessagesVC.shared.unreadUsers = self.unReadUsers
        })
    }
    
    @IBAction func openFilterMenu(_ sender: Any) {
        
        if menuShowing {
            trailingConstraint.constant = -160
            self.spotTableView.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseOut,animations: {
                            self.spotTableView.layer.opacity = 1.0
                            self.view.layoutIfNeeded()
            })
        } else {
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
        
        
        if isLoggedIn && !initialLoad{ SVProgressHUD.show() }

        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in

           
            self.spots = [] //clears up spot array each time its loaded

            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        self.spots.insert(spot, at: 0)
                    }
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.revealingSplashView.finishHeartBeatAnimation()
                self.spotTableView.reloadData()
            }
            self.allSpotsR = self.spots
            
            // bad, refactor whole app using singleton
            let favoritesVC = self.tabBarController!.viewControllers![1] as! FavoritesVC
            favoritesVC.allSpots = self.spots
            
            let profileVC = self.tabBarController!.viewControllers![3] as! ProfileVC
            profileVC.allSpots = self.spots

        })

        self.filterButton.setTitle("Filter Spots", for: .normal)
        
        initialLoad = false
    }
    
    func sortSpotsByDistance(completed: @escaping DownloadComplete){
        self.spots = self.allSpotsR

        self.spots.sort(by: { $0.distance(to: self.myLocation) < $1.distance(to: self.myLocation) })

        for spot in self.spots {
            let distanceInMeters = self.myLocation.distance(from: spot.location)
            let milesAway = distanceInMeters / 1609
            spot.distance = milesAway
            spot.removeCountry(spotLocation: spot.spotLocation)
        }
        
        self.allSpotsD = self.spots
        self.filterButton.setTitle("Filter Spots", for: .normal)
        completed()  
    }
    
    @IBAction func toggle(_ sender: UISegmentedControl) {
        if hasConnected && isInternetAvailable() {
            
//            if segmentControl.selectedSegmentIndex == 1 {
//                if CLLocationManager.locationServicesEnabled() {
//                    switch CLLocationManager.authorizationStatus() {
//                        case .notDetermined, .restricted, .denied:
//                            self.errorAlert(title: "Your location was not found!", message: "Make sure you have allowed location for Sk8Spots. Go to settings, scroll down to Sk8Spots and allow location access.")
//                            self.segmentControl.selectedSegmentIndex = 0
//                        case .authorizedAlways, .authorizedWhenInUse:
//                            break
//                        @unknown default:
//                        break
//                    }
//                    } else {
//                    self.errorAlert(title: "Your location was not found!", message: "Make sure you have allowed location for Sk8Spots. Go to settings, scroll down to Sk8Spots and allow location access.")
//                    self.segmentControl.selectedSegmentIndex = 0
//                }
//            }
            

            
            

            if sender.selectedSegmentIndex == 1 {
                
                self.manager.delegate = self
                self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.manager.requestWhenInUseAuthorization()
                self.manager.startUpdatingLocation()
                
            } else {
                
                self.loadSpotsbyRecentlyUploaded()
                self.spotTableView.scrollToRow(at: self.topItem, at: .top, animated: false)
                self.spotTableView.reloadData()
                
            }
            
            
            
            
        } else {
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
            myLocation = location
        }
        
        if segmentControl.selectedSegmentIndex == 0 {
            segmentControl.selectedSegmentIndex = 1
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
        if segmentControl.selectedSegmentIndex == 1 {
            segmentControl.selectedSegmentIndex = 0
        }
        self.errorAlert(title: "Your location was not found!", message: "Make sure you have allowed location for Sk8Spots. Go to settings, scroll down to Sk8Spots and allow location access.")
    }
    
    //MARK: SpotDetailDelegate
    func nearbySpotPressed(spot: Spot, spots: [Spot]) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
            vc.spot = spot
            vc.spots = spots
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return (screenHeight - heightOffset)
//    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(lblClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    @objc func lblClick(tapGesture:UITapGestureRecognizer) {
        let vc = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.allSpots = spots
        vc.userKey = spots[tapGesture.view!.tag].user
        self.navigationController?.pushViewController(vc, animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 456.0
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
            let spotDetailPage = segue.destination as? SpotDetailVC {
            let spot = spotCell.spot
            spotDetailPage.spot = spot
            spotDetailPage.spots = self.spots
            spotDetailPage.delegate = self

        }
    }
}
extension FeedVC: SpotRowDelegate {
    func didTapDirectionsButton(spot: Spot) {
        
        
          if (UIApplication.shared.canOpenURL(URL(string:"https://waze.com/ul")!)) {  //First check Waze Mpas installed on User's phone or not.
            UIApplication.shared.open(URL(string: "https://www.waze.com/ul?ll=\(spot.latitude)%2C\(spot.longitude)&navigate=yes&zoom=1000")!) //It will open native wazw maps app.
           } else {
                print("Can't use waze://");
           }
        
        
        
//
//        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!){
//            UIApplication.shared.open(URL(string:
//                "comgooglemaps://?saddr=&daddr=\(Float(spot.latitude)),\(Float(spot.longitude))&directionsmode=driving")!, options: [:], completionHandler: { (completed) in  })
//        } else {
//            let coordinate = CLLocationCoordinate2DMake(spot.latitude, spot.longitude)
//            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
//            mapItem.name = spot.spotName
//            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
//        }
    }
  
}

extension FeedVC: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received ad")
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}



