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

class MapBoxVC: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    var spotAnnotations = [MGLPointAnnotation]()
    var spots = [Spot]()
    var spot: Spot?
    var manager = CLLocationManager()
    var usersLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.styleURL = MGLStyle.lightStyleURL()
        mapView.tintColor = .black
        getUsersLocation()

        loadAnnotationData()
        
        
        
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
                        let annotation = MGLPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
                        annotation.title = spot.spotName
                        annotation.subtitle = spot.spotType
                        self.spotAnnotations.append(annotation)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.spotAnnotations)
                self.mapView.delegate = self
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
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
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
