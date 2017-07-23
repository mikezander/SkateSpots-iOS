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
import FirebaseStorage

class SpotPin: NSObject, MKAnnotation{

    let title: String?
    let locationName: String
    let imageUrl: String
    let coordinate: CLLocationCoordinate2D
    
    init(spot:Spot) {
        self.title = spot.spotName
        self.locationName = spot.spotType
        self.imageUrl = spot.imageUrls[0]
        self.coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)

        super.init()
    }
    var subtitle: String? {
        return locationName
    }
    
    var markerTintColor: UIColor  {
        switch locationName {
        case "Skatepark":
            return .red
        default:
            return .green
        }
    }

    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }

}
