//
//  Spot.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation

class Spot{
    private var _spotName: String!
    private var _imageUrls: [String]!
    private var _distance: Float!
    private var _spotLocation: String!
    private var _spotKey: String!
    
    var spotName: String{
        return _spotName
    }
    
    
    var imageUrls: [String]{
        return _imageUrls
    }
    
    var distance: Float{
        return _distance
    }
    
    var spotLocation: String{
        return _spotLocation
    }
    
    var spotKey: String{
        return _spotKey
    }
    
    init(spotName: String, imageUrls: [String], distance: Float, spotLocation: String){
        self._spotName = spotName
        self._imageUrls = imageUrls
        self._distance = distance
        self._spotLocation = spotLocation
    }
    
    init(spotKey: String, spotData: Dictionary<String, AnyObject>){
        self._spotKey = spotKey
        
        if let spotName = spotData["spotName"] as? String{
            self._spotName = spotName
            
        }
        
        if let imageUrls = spotData["imageUrls"] as? [String]{
            self._imageUrls = imageUrls
            
        }
        
        if let distance = spotData["distance"] as? Float{
            self._distance = distance
        }
        
        if let spotLocation = spotData["spotLocation"] as? String{
            self._spotLocation = spotLocation
        }
        
    }
}
