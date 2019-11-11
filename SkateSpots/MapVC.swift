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

class MapVC: UIViewController {
    
    var spot: Spot?
    var spotAnnotations = [SpotAnnotation]()
    var spots = [Spot]()
    var manager = CLLocationManager()
    var myLocation = CLLocation()
    
    @IBOutlet weak var  mapCollectionView: UICollectionView!
    // required map variables
    var selectedSpot: Spot? = nil
    var lastSelectedAnnotation: SpotAnnotation? = nil
    var lastSeenPath = IndexPath(row: 0, section: 0)
    var isPinSelected = false
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    
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
                        self.spots.append(spot)
//                        let spotAnnotation = SpotAnnotation()
//                        self.spotPins.append(spotPin)
//                        self.spotPins.append(spotPin)
//                        self.spotPins.append(spotPin)
//                        self.spotPins.append(spotPin)
//                        self.spotPins.append(spotPin)
                    }
                }
            }
      
            DispatchQueue.main.async {
                self.addAnnotationsToMap(spot: self.spots)
                self.mapCollectionView.reloadData()
                //self.mapView.addAnnotations(self.spotPins)
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
            //TODO: Refactor
            let spot = self.spots[indexPath.row]
            if !self.isPinSelected {
                let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(spot.latitude), longitude: CLLocationDegrees(spot.longitude))
                self.mapView.setCenter(center, animated: true)
            } else {
                self.isPinSelected = false
            }
               
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

                            self.lastSelectedAnnotation = spotAnnotation
                            self.lastSeenPath = indexPath
                        }
                   }
               }

           }
       }
}


extension MapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
        
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
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
            isPinSelected = true
            mapCollectionView.scrollToItem(at: indexofSelected, at: .left, animated: false)
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
            cell.configureCell(spot: spots[indexPath.row], style: "")
            cell.spotCountLabel.text = "\(indexPath.row + 1)/\(spots.count)"
         }
         
         return cell
     }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         if scrollView == mapCollectionView {
             if let cellRect = mapCollectionView.layoutAttributesForItem(at: lastSeenPath)?.frame {
                 let isCellCompletelyVisible = mapCollectionView.bounds.contains(cellRect)
                 if !isCellCompletelyVisible {
                     mapCollectionView.scrollToItem(at: lastSeenPath, at: .left, animated: true)
                 }
             }
         }
     }
     
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         centerMapOnSelectedProperty(indexPath: indexPath)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: view.frame.width, height: 100)
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//         let property = mapProperties[indexPath.row]
//         let tabController = self.tabBarController as! TenantMainTabBarViewController
//         let nc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "property_nc") as! UINavigationController
//         let vc = nc.viewControllers.first as! PropertyDetailsViewController
//         vc.property = property
//         nc.modalPresentationStyle = .custom
//         nc.transitioningDelegate = tabController
//         tabController.present(nc, animated: true, completion: nil)
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




