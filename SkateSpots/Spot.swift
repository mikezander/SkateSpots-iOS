//
//  Spot.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import Photos

class Spot{

    private var _spotName: String
    private var _imageUrls: [String]
    private var _distance: Double?
    private var _spotLocation: String
    private var _spotType: String
    private var _spotKey: String!
    private var _latitude: CLLocationDegrees
    private var _longitude: CLLocationDegrees
    
    var spotName: String{
        return _spotName
    }

    var imageUrls:[String]{
        return _imageUrls
    }
    
    var distance: Double?{
        get {
        return _distance
        
        }set{
        _distance = newValue
        }
    }
    
    var spotLocation: String{
        return _spotLocation
    }
    
    var spotType: String{
        return _spotType
    }
    
    var spotKey: String{
        return _spotKey
    }
    
    var latitude: CLLocationDegrees{
        return _latitude
    }
    
    var longitude: CLLocationDegrees{
        return _longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
    
    init(spotName: String, imageUrls: [String], spotLocation: String, spotType:String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        self._spotName = spotName
        self._imageUrls = imageUrls
        self._spotLocation = spotLocation
        self._spotType = spotType
        self._latitude = latitude
        self._longitude = longitude
    }
    
    init(spotKey: String, spotData: Dictionary<String, AnyObject>){
        self._spotKey = spotKey
        
        self._spotName = spotData["spotName"] as? String ?? "no name"
        
        self._imageUrls = spotData["imageUrls"] as? [String] ?? ["https://firebasestorage.googleapis.com/v0/b/sk8spots-b8769.appspot.com/o/post-pics%2F5550AA22-D70E-4403-9984-04BC59ED20E7?alt=media&token=24569b8c-f796-426b-b468-29841252baaf"]


        self._spotLocation = spotData["spotLocation"] as? String ?? "no location"
        
        self._spotType = spotData["spotType"] as? String ?? ""
        
        self._latitude = spotData["latitude"] as? CLLocationDegrees ?? 0.0
        
        self._longitude = spotData["longitude"] as? CLLocationDegrees ?? 0.0
         
        
        }
        
    }

