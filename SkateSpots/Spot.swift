//
//  Spot.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation

class Spot{
    private var _spotName: String
    private var _imageUrls: [String]
    private var _distance: Float
    private var _spotLocation: String
    private var _spotKey: String!
    
    var spotName: String{
        return _spotName
    }

    var imageUrls:[String]{
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
        
        self._spotName = spotData["spotName"] as? String ?? "no name"
        
        self._imageUrls = spotData["imageUrls"] as? [String] ?? ["https://firebasestorage.googleapis.com/v0/b/sk8spots-b8769.appspot.com/o/post-pics%2F5550AA22-D70E-4403-9984-04BC59ED20E7?alt=media&token=24569b8c-f796-426b-b468-29841252baaf"]
        
        self._distance = spotData["distance"] as? Float ?? 0.5

        self._spotLocation = spotData["spotLocation"] as? String ?? "no location"
        
        }
        
    }

