//
//  MapVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/19/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Contacts
import FirebaseStorage
import SDWebImage
import SVProgressHUD
import Kingfisher

class MapVC: UIViewController, SpotDetailDelegate {
    
    var spot: Spot?
    var spotAnnotations = [SpotAnnotation]()
    var spots = [Spot]()
    var manager = CLLocationManager()
    var userLocation: CLLocation? = nil
    var resetLocation = false
    @IBOutlet var refreshLocationButton:  UIButton!

    
    @IBOutlet weak var  mapCollectionView: UICollectionView!
    // required map variables
    var selectedSpot: Spot? = nil
    var lastSelectedAnnotation: SpotAnnotation? = nil
    var lastSeenPath = IndexPath(row: 0, section: 0)
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 50000
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        getUsersLocation()

        loadAnnotationData()
        
        if isInternetAvailable() && hasConnected {
            mapView.delegate = self
        }else{
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.internetConnectionFound(notification:)), name: internetConnectionNotification, object: nil)
            
            errorAlert(title: "Internet Connection Error", message: "Make sure you are connected and try again")
            return
        }
   
    }


    func loadAnnotationData(){
        
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
                if let location = self.userLocation {
                    //sorts spots closest to user's location
                    self.spots.sort(by: { $0.distance(to: location) < $1.distance(to: location) })
                    for spot in self.spots {
                        let distanceInMeters = location.distance(from: spot.location)
                        let milesAway = distanceInMeters / 1609
                        spot.distance = milesAway
                    }
                }
                
                self.addAnnotationsToMap(spot: self.spots)
                self.mapCollectionView.reloadData()
                
                if let firstSpotLat = self.spots.first?.latitude, let firstSpotLong = self.spots.first?.longitude, self.userLocation == nil {
                    self.mapView.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(firstSpotLat), longitude: CLLocationDegrees(firstSpotLong)), animated: true)
                }
            }
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getUsersLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @IBAction func refreshLocationPressed(_ sender: Any) {
        resetLocation = true
        getUsersLocation()
        
    }
    
    @objc func internetConnectionFound(notification: NSNotification){
        loadAnnotationData()
        mapView.delegate = self
        NotificationCenter.default.removeObserver(self, name: internetConnectionNotification, object: nil)
    }
    
    func addAnnotationsToMap(spot: [Spot]) {
        self.spotAnnotations = []
        let annotations: [SpotAnnotation] = spots.map { spot in
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(spot.latitude), CLLocationDegrees(spot.longitude))
            let annotation = SpotAnnotation()
            annotation.coordinate = location
            annotation.spot = spot
            spotAnnotations.append(annotation)
            return annotation
        }
        mapView.addAnnotations(annotations)
        //mapView.showAnnotations(mapView.annotations, animated: true)

    }
    
    func centerMapOnSelectedProperty(indexPath: IndexPath) {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if self.spots.indices.contains(indexPath.row) {
                let spot = self.spots[indexPath.row]

                   self.selectedSpot = spot
                   if self.lastSelectedAnnotation != nil {
                       let anno = self.mapView.view(for: self.lastSelectedAnnotation!)
                       anno?.setViewToDefaultZOrder()
                       anno?.image = UIImage(named: "green_anno1")
                   }
                
                   for anno in self.mapView.annotations {
                       if let spotAnnotation = anno as? SpotAnnotation,
                        spotAnnotation.spot.spotKey == self.selectedSpot?.spotKey {
                            let anno = self.mapView.view(for: spotAnnotation)
                            anno?.image = UIImage(named: "green_anno_black")
                            anno?.bringViewToFront()
  
//                        self.centerMapOnLocation(location: self.selectedSpot!.location)

                            self.lastSelectedAnnotation = spotAnnotation
                            self.lastSeenPath = indexPath
                        }
                   }
               }

           }
       }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "detail" {
            let vc = segue.destination as! SpotDetailVC
            vc.spot = spot
            vc.spots = spots
            vc.delegate = self
         }
     }
    
    func nearbySpotPressed(spot: Spot, spots: [Spot]) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
            vc.spot = spot
            vc.spots = spots
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}


extension MapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        userLocation = location

        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
        
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
        
        if resetLocation {
            SVProgressHUD.show()
            refreshLocationButton.isUserInteractionEnabled = false
            
            mapView.removeAnnotations(mapView.annotations)
            DispatchQueue.main.async {
                if let location = self.userLocation {
                    //sorts spots closest to user's location
                    self.spots.sort(by: { $0.distance(to: location) < $1.distance(to: location) })
                    for spot in self.spots {
                        let distanceInMeters = location.distance(from: spot.location)
                        let milesAway = distanceInMeters / 1609
                        spot.distance = milesAway
                    }
                }
                self.addAnnotationsToMap(spot: self.spots)
                self.mapCollectionView.reloadData()
                self.mapCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)

            }
            self.resetLocation = false
            SVProgressHUD.dismiss()
            refreshLocationButton.isUserInteractionEnabled = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}

extension MapVC: MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
    
        let annotationView: MKAnnotationView

        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            annotationView = view
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }

        let spotAnnotation = annotation as! SpotAnnotation

        annotationView.annotation = spotAnnotation
        annotationView.setViewToDefaultZOrder()

        if spotAnnotation.spot.spotKey == selectedSpot?.spotKey {
            annotationView.bringViewToFront()
            annotationView.image = UIImage(named: "green_anno_black")
            return annotationView
        }

        let pinImage = UIImage(named: "green_anno1")
        annotationView.image = pinImage

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? SpotAnnotation,
            let index = spots.firstIndex(where: { $0.spotKey == annotation.spot.spotKey }) {
            let indexofSelected = IndexPath(item: index, section: 0)
            mapCollectionView.isPagingEnabled = false
            mapCollectionView.scrollToItem(at: indexofSelected, at: .left, animated: false)
            mapCollectionView.isPagingEnabled = true

        }
    }
    
    func resizeAnnotationImageForIpad(image: UIImage?, selected: Bool) -> UIImage? {
        let size: CGFloat = selected ? 60.0 : 50.0
        let resizedSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContext(resizedSize)
        image?.draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MapCollectionViewCell
         if spots.count > 0 {
            let spot = spots[indexPath.row]
            cell.configureCell(spot: spot, style: "")
            cell.spotCountLabel.text = spot.distance != nil ? "\(String(format: "%.1f", spot.distance!)) miles away": "\(indexPath.row + 1)/\(spots.count)"
         }
         
         return cell
     }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mapCollectionView.isPagingEnabled = false
         if scrollView == mapCollectionView {
            if let cellRect = mapCollectionView.layoutAttributesForItem(at: lastSeenPath)?.frame {
                 let isCellCompletelyVisible = mapCollectionView.frame.contains(cellRect)
                 if !isCellCompletelyVisible {
                     mapCollectionView.scrollToItem(at: lastSeenPath, at: .left, animated: true)
                 }
             }
         }
        mapCollectionView.isPagingEnabled = true

     }
     
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         centerMapOnSelectedProperty(indexPath: indexPath)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.spot = spots[indexPath.row]
        performSegue(withIdentifier: "detail", sender: nil)
     }
}


class SpotAnnotation: MKPointAnnotation {

    var spot: Spot!;
    
}

extension MKAnnotationView {
    
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
        stickyZPosition = CGFloat(0.1)
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





