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

}
