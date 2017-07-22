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
    
    var spotPins = [SpotPin]()
    var spots = [Spot]()
    let manager = CLLocationManager()
    var myLocation = CLLocation()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    
    @IBOutlet weak var mapView: MKMapView!

    let regionRadius: CLLocationDistance = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        

        // set initial location in Yonkers
        let initialLocation = CLLocation(latitude: 40.944164, longitude: -73.860896)
        centerMapOnLocation(location: initialLocation)
        
        
        DataService.instance.REF_SPOTS.observe(.value, with: {(snapshot) in
            
            //self.spots = [] //clears up spot array each time its loaded
            
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

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
   
    
        return view
    }
   
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        let location = view.annotation as! SpotPin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}



