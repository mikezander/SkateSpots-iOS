//
//  Spot.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import Photos

class Spot {

    private var _spotName: String
    private var _imageUrls: [String]
    private var _distance: Double?
    private var _spotLocation: String
    private var _spotType: String
    private var _spotDescription: String
    private var _kickout: String
    private var _bestTimeToSkate: String
    private var _spotKey: String!
    private var _latitude: CLLocationDegrees
    private var _longitude: CLLocationDegrees
    private var _user: String
    private var _username: String
    private var _userImageURL: String

    var spotName: String {
        return _spotName
    }

    var imageUrls:[String] {
        return _imageUrls
    }
    
    var distance: Double? {
        get {
        return _distance
        
        } set {
        _distance = newValue
        }
    }
    
    var spotLocation: String {
        return _spotLocation
    }
    
    var spotType: String {
        return _spotType
    }
    
    var spotDescription: String {
        return _spotDescription
    }
    
    var kickOut: String {
        return _kickout
    }
    
    var bestTimeToSkate: String {
        return _bestTimeToSkate
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
    
    var user: String {
        return _user
    }
    
    var username: String {
        return _username
    }
    
    var userImageURL: String {
        return _userImageURL
    }
    
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
    
    func removeCountry(spotLocation: String){
        let delimiter = "-"
       _spotLocation = spotLocation.components(separatedBy: delimiter).first!
    }
    
    func sortBySpotType(type: String)->Bool{
        if self.spotType.lowercased().range(of: type) != nil {
            return true
        }else{
            return false
        }

    }
  
    init(spotName: String, imageUrls: [String], spotLocation: String, spotType:String, spotDescription: String, kickOut: String, bestTimeToSkate: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, user: String, username: String, userImageURL: String){
        self._spotName = spotName
        self._imageUrls = imageUrls
        self._spotLocation = spotLocation
        self._spotType = spotType
        self._spotDescription = spotDescription
        self._kickout = kickOut
        self._bestTimeToSkate = bestTimeToSkate
        self._latitude = latitude
        self._longitude = longitude
        self._user = user
        self._username = username
        self._userImageURL = userImageURL
    }
    
    init(spotKey: String, spotData: [String: Any]){
        self._spotKey = spotKey
        
        self._spotName = spotData["spotName"] as? String ?? "no name"
        
        self._imageUrls = spotData["imageUrls"] as? [String] ?? ["https://firebasestorage.googleapis.com/v0/b/sk8spots-b8769.appspot.com/o/post-pics%2F5550AA22-D70E-4403-9984-04BC59ED20E7?alt=media&token=24569b8c-f796-426b-b468-29841252baaf"]


        self._spotLocation = spotData["spotLocation"] as? String ?? "no location"
        
        self._spotType = spotData["spotType"] as? String ?? ""
        
        self._spotDescription = spotData["spotDescription"] as? String ?? "No description"
        
        self._kickout = spotData["kickOut"] as? String ?? "Low"
        
        self._bestTimeToSkate = spotData["bestTimeToSkate"] as? String ?? "Anytime"
        
        self._latitude = spotData["latitude"] as? CLLocationDegrees ?? 0.0
        
        self._longitude = spotData["longitude"] as? CLLocationDegrees ?? 0.0
        
        self._user = spotData["user"] as? String ?? "no user id found"
        
        self._username = spotData["username"] as? String ?? "unknown"
        
        self._userImageURL = spotData["userImageURL"] as? String ?? ""
        
        }
        
    }

