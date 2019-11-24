//
//  ViewingMapView.swift
//  Inadash
//
//  Created by Michael Alexander on 1/24/18.
//  Copyright © 2018 Inadash Limited. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

@objc protocol DirectionsViewDelegate {
    func directionViewDidRequestDirections(_ directionsView: DirectionsView)
    func directionViewDidRequestExpandMap(_ directionsView: DirectionsView)
}

@IBDesignable
class DirectionsView: UIView {

    var contentView:UIView?
    @IBInspectable var nibName:String?
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var locationPermissionOverlay: UIView!
    @IBOutlet var hideLocationWarningConstraint: NSLayoutConstraint!
    
    @IBOutlet var delegate: DirectionsViewDelegate?
    
    let locationManager = CLLocationManager()
    var propertyCoords: CLLocation!
    
    var spot: Spot! {
        didSet {
            updateMap()
        }
    }

   override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view

        self.mapView.isUserInteractionEnabled = false
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
    }
    
    func loadViewFromNib() -> UIView? {
        guard let nibName = nibName else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

    func updateMap() {
        self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
        self.updateDirections()
    }

    func updateDirections() {
        let userPlacemark = MKPlacemark(coordinate: self.mapView.userLocation.coordinate)
        let spotMapLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(spot.latitude), longitude: CLLocationDegrees(spot.longitude))
        let spotPlacemark = MKPlacemark(coordinate: spotMapLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = spotMapLocation
        self.mapView.addAnnotation(annotation)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: userPlacemark)
        directionsRequest.destination = MKMapItem(placemark: spotPlacemark)
        directionsRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            
            if error != nil {
                self.mapView.showAnnotations([annotation], animated: true)
            } else {
                self.handleDirectionsResponse(response: response, error: error)
            }
        }
    }
    
    func handleDirectionsResponse(response: MKDirections.Response?, error: Error?) {
        guard error == nil else {
            return
        }
        
        if let route = response?.routes.first {
            if let overlay = self.mapView.overlays.first {
                self.mapView.removeOverlay(overlay)
            }

            self.mapView.addOverlays([route.polyline], level: .aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0), animated: true)
        }
    }

    @IBAction private func handleDirectionsRequest() {
        self.delegate?.directionViewDidRequestDirections(self)
    }
    
    @IBAction private func handleExpandMapRequest() {
        self.delegate?.directionViewDidRequestExpandMap(self)
    }
}

extension DirectionsView: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        self.updateDirections()
//    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 4.0
        return renderer
    }

}

extension DirectionsView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            self.mapView.alpha = 0.4
            self.hideLocationWarningConstraint.isActive = false
            self.locationPermissionOverlay.alpha = 1.0
            
        case .authorizedAlways, .authorizedWhenInUse:
            self.mapView.alpha = 1.0
            self.locationPermissionOverlay.alpha = 0.0
            self.hideLocationWarningConstraint.isActive = true
            
        }
    }
    
}

