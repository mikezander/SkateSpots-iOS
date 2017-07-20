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

class MapVC: UIViewController {
    
    var spotPins = [SpotPin]()
    let manager = CLLocationManager()
    var myLocation = CLLocation()
    
    
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

                        let spotPin = SpotPin(title: spot.spotName ,
                                                     locationName: spot.spotLocation,
                                                     coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude))
                        self.spotPins.append(spotPin)
                        //self.mapView.addAnnotation(spotPin)
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
