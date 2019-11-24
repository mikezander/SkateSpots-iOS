//
//  MapBoxVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 3/30/18.
//  Copyright © 2018 Michael Alexander. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import Kingfisher
import SVProgressHUD



class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
    //var spot: Spot!
}

extension MGLAnnotationView {

    /// Override the layer factory for this class to return a custom CALayer class
    override open class var layerClass: AnyClass {
        return ZPositionableLayer.self
    }
    
    

    /// convenience accessor for setting zPosition
    var stickyZPosition: CGFloat {
        get {
            return (self.layer as! ZPositionableLayer).stickyZPosition
        }
        set {
            (self.layer as! ZPositionableLayer).stickyZPosition = newValue
        }
    }
    
    /// force the pin to the front of the z-ordering in the map view
    func bringViewToFront() {
        superview?.bringSubviewToFront(self)
        stickyZPosition = CGFloat(1.0)
    }
    
    /// force the pin to the back of the z-ordering in the map view
    func setViewToDefaultZOrder() {
        stickyZPosition = CGFloat(0)
    }
    
}

/// iOS 11 automagically manages the CALayer zPosition, which breaks manual z-ordering.
/// This subclass just throws away any values which the OS sets for zPosition, and provides
/// a specialized accessor for setting the zPosition
private class ZPositionableLayer: CALayer {
    
    /// no-op accessor for setting the zPosition
    override var zPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            // do nothing
        }
    }
    
    /// specialized accessor for setting the zPosition
    var stickyZPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            super.zPosition = newValue
        }
    }
}

class MapBoxVC: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var spotAnnotations = [MyCustomPointAnnotation]()
    var spots = [Spot]()
    var spot: Spot?
    var manager = CLLocationManager()
    var menuShowing = false
    var usersLocation = CLLocationCoordinate2D()
    var mapTypeStyle = "Dark"
    let defaults = UserDefaults.standard
    var lastSeenPath = IndexPath(row: 0, section: 0)
    var isPinSelected = false
    var selectedSpot: MGLAnnotation? = nil
    var lastSelectedAnnotation: MGLAnnotation? = nil
    @IBOutlet weak var collectionViewContainer: UIView!
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .light
//        }
        
        if let style = defaults.string(forKey: "MapStyle"){
            mapTypeStyle = style
        }
        loadMapViewStyle(style: mapTypeStyle)

        getUsersLocation()

        loadAnnotationData()

        mapView.delegate = self
        
        collectionViewContainer.layer.borderWidth = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.centerOnUsersLocation()
        }
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        menuView.sizeToFit()
        
//        if UIScreen.main.bounds.height >= 812.0{
//            
//        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    
    
    @IBAction func changeMapStyleButtonPressed(_ sender: Any) {
        if menuShowing {
            menuTrailingConstraint.constant = -160
            mapView.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseOut,animations: {
                            self.mapView.layer.opacity = 1.0
                            self.view.layoutIfNeeded()
            })
        } else {
            menuTrailingConstraint.constant = 0
            mapView.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseIn,animations: {
                            self.mapView.layer.opacity = 0.5
                            self.view.layoutIfNeeded()
            })
        }
        menuShowing = !menuShowing
    }
    

    @IBAction func redirectUsersLocationPressed(_ sender: Any) {
        centerOnUsersLocation()
    }
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        if isInternetAvailable() && hasConnected {
            
            SVProgressHUD.show()
            
            menuTrailingConstraint.constant = -160
            mapView.isUserInteractionEnabled = true
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity:1,
                           options: .curveEaseOut,animations: {
                            self.mapView.layer.opacity = 1.0
                            self.view.layoutIfNeeded()
            })
            
            self.menuShowing = !self.menuShowing

            guard let style = sender.titleLabel?.text else { return }
            mapTypeStyle = style
            loadMapViewStyle(style: mapTypeStyle)
            
            SVProgressHUD.dismiss()
        } else {
            self.errorAlert(title: "Internet Connection Error", message: "Make sure you have a connection and try again")
        }
    }
    
    func loadMapViewStyle(style: String) {
        if style == "Light" {
            mapView.styleURL = MGLStyle.lightStyleURL//MGLStyle.lightStyleURL()
            mapView.tintColor = .black
            collectionViewContainer.layer.borderColor = UIColor.darkGray.cgColor
            collectionViewContainer.backgroundColor = .white
        } else if style == "Dark" {
            mapView.styleURL = MGLStyle.darkStyleURL
            mapView.tintColor = .lightGray
            collectionViewContainer.layer.borderColor = UIColor.white.cgColor
            collectionViewContainer.backgroundColor = .black

        } else if style == "Classic" {
            mapView.styleURL = MGLStyle.outdoorsStyleURL
            mapView.tintColor = .blue
            collectionViewContainer.layer.borderColor = UIColor.darkGray.cgColor
            collectionViewContainer.backgroundColor = .white
        }
        
        defaults.set(style, forKey: "MapStyle")
        collectionView.reloadData()
    }
    
    func loadAnnotationData(){
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            //self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let spotDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        //self.spots.append(spot)
                        self.spots.insert(spot, at: 0)
                        let annotation = MyCustomPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
                        annotation.title = spot.spotName
                        annotation.subtitle = spot.spotType
                        annotation.willUseImage = true
                        self.spotAnnotations.insert(annotation, at: 0)
                        //self.spotAnnotations.append(annotation)
                    }

                }
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.spotAnnotations)
                self.collectionView.reloadData()

            }
        })
    }
    
    func sortSpotsByDistance(){
        self.spots.sort(by: { $0.distance(to: CLLocation(latitude: usersLocation.latitude, longitude: usersLocation.longitude)) < $1.distance(to: CLLocation(latitude: usersLocation.latitude, longitude: usersLocation.longitude)) })

        mapView.removeAnnotations(spotAnnotations)
//        spotAnnotations.removeAll()
//        for spot in spots {
//            let annotation = MyCustomPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
//            annotation.title = spot.spotName
//            annotation.subtitle = spot.spotType
//            annotation.willUseImage = true
//            self.spotAnnotations.append(annotation)
//        }
//        
//        mapView.addAnnotations(self.spotAnnotations)
        collectionView.reloadData()
    }
    
    func sortSpotsByRecent(){
        self.spots.sort(by: { $0.spotKey < $1.spotKey })

        mapView.removeAnnotations(spotAnnotations)
        spotAnnotations.removeAll()
        for spot in spots {
            let annotation = MyCustomPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
            annotation.title = spot.spotName
            annotation.subtitle = spot.spotType
            annotation.willUseImage = true
            self.spotAnnotations.append(annotation)
        }
        
        mapView.addAnnotations(self.spotAnnotations)
        collectionView.reloadData()
    }
    
    func getUsersLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func centerOnUsersLocation() {
        getUsersLocation()
        
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.usersLocation.latitude), longitude: CLLocationDegrees(self.usersLocation.longitude))
        self.mapView.setCenter(center, animated: true)
    }

    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let anno = annotation as! MyCustomPointAnnotation
        if let index = spotAnnotations.firstIndex(of: anno) {
            let indexofSelected = IndexPath(item: index, section: 0)
            isPinSelected = true
            collectionView.scrollToItem(at: indexofSelected, at: .left, animated: false)
        }

    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {

        var annotationView: MGLAnnotationView? = nil
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            annotationView?.annotation = castAnnotation
            annotationView?.setViewToDefaultZOrder()

            if castAnnotation.willUseImage == false {               
                annotationView?.bringViewToFront()
                mapView.layoutIfNeeded()
                return annotationView
            } else {
                annotationView?.layer.zPosition = 0.0
                return annotationView
            }
        }

        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            annotationView = view
        } else {
            annotationView = MGLAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        
        return annotationView
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (!castAnnotation.willUseImage) {
                if mapTypeStyle == "Dark" {
                    return  MGLAnnotationImage(image: UIImage(named: "green_anno_white")!, reuseIdentifier: "green_anno_white")
                } else {
                    return MGLAnnotationImage(image: UIImage(named: "green_anno_black")!, reuseIdentifier: "green_anno_black")
                }
            }
        }
        var annotationImage: MGLAnnotationImage? = nil

            annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "green_anno1")
                // If there is no reusable annotation image available, initialize a new one.
        if(annotationImage == nil) {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "green_anno1")!, reuseIdentifier: "green_anno1")
                
        }
        return annotationImage
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let vc = segue.destination as! SpotDetailVC
            vc.spot = spot
        } 
    }
    
    func centerMapOnSelectedSpot(indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            
            let spot = self.spots[indexPath.row]
            if !self.isPinSelected {
                let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(spot.latitude), longitude: CLLocationDegrees(spot.longitude))
                self.mapView.setCenter(center, animated: true)
            } else {
                self.isPinSelected = false
            }

            self.selectedSpot = self.spotAnnotations[indexPath.row]

            if self.lastSelectedAnnotation != nil {
                let pin = self.lastSelectedAnnotation as! MyCustomPointAnnotation
                self.mapView.removeAnnotation(pin)
                pin.willUseImage = true
                self.mapView.addAnnotation(pin)
            }
            if self.selectedSpot != nil {
                let pin = self.selectedSpot as! MyCustomPointAnnotation

                self.mapView.removeAnnotation(pin)
                pin.willUseImage = false
                self.mapView.addAnnotation(pin)
            }
            self.lastSeenPath = indexPath
            self.lastSelectedAnnotation = self.selectedSpot
            
        }
    }
}

extension MapBoxVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        usersLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.setCenter(usersLocation, zoomLevel: 15.0, animated: true)
        if mapView.isUserLocationVisible {
            mapView.showsUserLocation = true
        } else {
            print("user location not found")
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
    }
}

extension MapBoxVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MapCollectionViewCell
        
        let spot = spots[indexPath.row]
        if spots.count > 0 {
            cell.configureCell(spot: spot, style: mapTypeStyle)
            cell.spotCountLabel.text = "\(indexPath.row + 1)/\(spots.count)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath)
        headerView.frame.size.height = 100
        return headerView
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cellRect = collectionView.layoutAttributesForItem(at: lastSeenPath)?.frame {
            let isCellCompletelyVisible = collectionView.bounds.contains(cellRect)
            if !isCellCompletelyVisible {
                collectionView.scrollToItem(at: lastSeenPath, at: .left, animated: true)
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        centerMapOnSelectedSpot(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.spot = spots[indexPath.row]
        performSegue(withIdentifier: "detail", sender: nil)
    }


//    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
//        if let anno = zAnnotationView {
//            anno.superview?.bringSubviewToFront(anno)
//        }
//    }
}
