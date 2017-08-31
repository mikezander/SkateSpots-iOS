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

class MapVC: UIViewController{
    
    var spot: Spot?
    var spotPins = [SpotPin]()
    var spots = [Spot]()
    var manager = CLLocationManager()
    var myLocation = CLLocation()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    @IBOutlet weak var mapView: MKMapView!

    let regionRadius: CLLocationDistance = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsersLocation()
        
        mapView.delegate = self

        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            self.spots = [] //clears up spot array each time its loaded
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshot{
                    if let spotDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let spot = Spot(spotKey: key, spotData: spotDict)
                        let spotPin = SpotPin(spot: spot)
                        
                        self.spotPins.append(spotPin)
            
                    }
                }
                
            }
           
            self.mapView.addAnnotations(self.spotPins)
        })
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getUsersLocation(){
    
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @IBAction func refreshLocationPressed(_ sender: Any) {
        
        getUsersLocation()
        
    }
  
    
}
extension MapVC: CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
        
        manager.stopUpdatingLocation()
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find MY location: \(error.localizedDescription)")
    }
}

extension MapVC: MKMapViewDelegate {
   
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? SpotPin else { return nil }
        
        let identifier = "pin"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
  
            FIRStorage.storage().reference(forURL: annotation.imageUrl).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
                let image = UIImage(data: data!)
                let cropRect = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
                let myImageView = UIImageView(frame: cropRect)
                myImageView.clipsToBounds = true
                myImageView.image = image
                view.leftCalloutAccessoryView = myImageView
                view.isHighlighted = true

            })

            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    
       view.pinTintColor = annotation.markerTintColor
       
    
        return view
    }
   
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let spotPin = view.annotation as! SpotPin
        spot = spotPin.spot
        performSegue(withIdentifier: "DetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if segue.identifier == "DetailVC"{
            
            let vc = segue.destination as! DetailVC
            vc.spot = spot
        }
    
}

}

