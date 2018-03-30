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

class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
}

class MapBoxVC: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    var spotAnnotations = [MyCustomPointAnnotation]()
    var spots = [Spot]()
    var spot: Spot?
    var manager = CLLocationManager()
    var menuShowing = false
    var usersLocation = CLLocationCoordinate2D()
    
    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.styleURL = MGLStyle.lightStyleURL()
        mapView.tintColor = .white
        getUsersLocation()

        loadAnnotationData()
        self.mapView.delegate = self
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
    
    func loadAnnotationData(){
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            //self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        self.spots.append(spot)
                        let annotation = MyCustomPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
                        annotation.title = spot.spotName
                        annotation.subtitle = spot.spotType
                        annotation.willUseImage = true
                        
                        
                        self.spotAnnotations.append(annotation)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.spotAnnotations)
                
            }
        })
    }
    
    func getUsersLocation(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let spotName = annotation.title!!
        let index = spots.index{$0.spotName == spotName}
        
        spot = spots[index!]
        performSegue(withIdentifier: "detail", sender: nil)

    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let cropRect = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
        let myImageView = UIImageView(frame: cropRect)
        myImageView.clipsToBounds = true
        
        let spotName = annotation.title!!
        let index = spots.index{$0.spotName == spotName}
        
        guard let i = index else { return nil }
        
        spot = spots[i]
        
        myImageView.kf.setImage(with: URL(string: spot!.imageUrls[0]), placeholder: nil, options: [.scaleFactor(50.0)], progressBlock: nil) { (image, error, cacheType, url) in
            
        }
        
        return myImageView
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
        let reuseIdentifier = "reusableDotView"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red:0.03, green:0.80, blue:0.69, alpha:1.0)
        }
        
        return annotationView
    }
    
    // This delegate method is where you tell the map to load an image for a specific annotation based on the willUseImage property of the custom subclass.
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        // For better performance, always try to reuse existing annotations.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "green_anno")
        
        // If there is no reusable annotation image available, initialize a new one.
        if(annotationImage == nil) {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "green_anno")!, reuseIdentifier: "green_anno")
        }
        
        return annotationImage
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let vc = segue.destination as! DetailVC
            vc.spot = spot
        }
    }
}

extension MapBoxVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        usersLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.setCenter(usersLocation, zoomLevel: 10, animated: true)
        mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
    }
}
