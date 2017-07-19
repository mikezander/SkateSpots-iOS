//
//  SpotPin.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/19/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//
import UIKit
import Foundation
import MapKit
import Contacts

class SpotPin: NSObject, MKAnnotation{

    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
         self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }

}
