//
//  SpotVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/8/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase
import Photos
import CoreLocation
import FirebaseStorage
import AssetsLibrary

class SpotVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var spotNameField: UITextField!
    var imagePicker: UIImagePickerController!
    var count = 0
    var imageSelected = false
    var photoURLs = [String]()
    var locationManager = CLLocationManager()
    var locationString: String = ""
    var location: CLLocation?
    var locationFound = false
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?

    @IBOutlet weak var addPhotoOne: UIImageView!
    @IBOutlet weak var addPhotoTwo: UIImageView!
    @IBOutlet weak var addPhotoThree: UIImageView!
    @IBOutlet weak var addPhotoFour: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        showPhotoActionSheet()

        addPhotoOne.addGestureRecognizer(setGestureRecognizer())
        addPhotoTwo.addGestureRecognizer(setGestureRecognizer())
        addPhotoThree.addGestureRecognizer(setGestureRecognizer())
        addPhotoFour.addGestureRecognizer(setGestureRecognizer())
        
    }
    
    func addImagePressed(sender: UITapGestureRecognizer) {
        
        showPhotoActionSheet()
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(addImagePressed))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }

    func showPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else { print("Sorry cant take photo") }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(actionSheet, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            if (!locationFound) && (latitude == nil) && (longitude == nil){
            if(picker.sourceType == .camera){
                
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.requestLocation()
    
            }else{
            
                if let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL{
                    let asset = PHAsset.fetchAssets(withALAssetURLs:[imageUrl as URL], options: nil).firstObject as PHAsset?

                    if asset?.location != nil{
                        let location = asset?.location
                        
                        latitude = location?.coordinate.latitude
                        longitude = location?.coordinate.longitude
                        
                        reverseGeocodeLocation(location: location!)
                    }
                }
            }
        }

            addThumbnailPhoto(count, image)
            imageSelected = true
            count += 1
        }else{
            print("valid image wasn't selected")
        }
    }
    
    func addThumbnailPhoto(_ count: Int,_ image: UIImage){
        switch count {
        case 0:
            DispatchQueue.main.async {self.addPhotoOne.image = image}
        case 1:
            DispatchQueue.main.async {self.addPhotoTwo.image = image}
        case 2:
            DispatchQueue.main.async {self.addPhotoThree.image = image}
        case 3:
            DispatchQueue.main.async {self.addPhotoFour.image = image}
        default:
            print("max number of photos")
        }
    }
    
    @IBAction func addSpotPressed(_ sender: Any) {
        
        guard let spotName = spotNameField.text, spotName != "" else{
            print("a spot Name must be entered")
            return
        }
        
        guard let defaultImg = addPhotoOne.image, imageSelected == true else{
            print("a default image must be selected")
            return
        }
        
        addPhotosToStorage(image: defaultImg, true)
        
        performSegue(withIdentifier: "backToFeedVC", sender: nil)
    }
    
    
    func addPhotosToStorage(image: UIImage,_ isDefault: Bool){

        if let imgData = UIImageJPEGRepresentation(image, 0.2){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
           let uploadTask = DataService.instance.REF_SPOT_IMAGES.child(imgUid).put(imgData, metadata:metadata) {(metadata, error) in
 
                if error != nil{
                    print("unable to upload image to firebase storage")
                }else{
                    
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                        self.photoURLs.append(url)
                        
                        if self.photoURLs.count == self.count{
                        
                            self.postToFirebase(imgUrl: self.photoURLs)
                        }
                    }
                }
                
            }
            if isDefault{ 
            _ = uploadTask.observe(.success) { snapshot in
               
                if let imgTwo = self.addPhotoTwo.image, self.imageSelected == true, self.count >= 2{
                    self.addPhotosToStorage(image: imgTwo, false)
                }
                
                if let imgThree = self.addPhotoThree.image, self.imageSelected == true, self.count >= 3{
                    self.addPhotosToStorage(image: imgThree, false)
                }
                
                if let imgFour = self.addPhotoFour.image, self.imageSelected == true, self.count == 4{
                    self.addPhotosToStorage(image: imgFour, false)
                }
                }
            }
        }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location.coordinate.latitude)")
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            reverseGeocodeLocation(location: location)
        }
        /*print("running")
        let latitude = String(describing: manager.location?.coordinate.latitude)
        let longitude = String(describing: manager.location?.coordinate.longitude)
        
        print("Lat: \(latitude) Long: \(longitude)")
        
        let location = CLLocation(latitude: (manager.location?.coordinate.latitude)!, longitude:(manager.location?
            .coordinate.longitude)!)
       print(location)
        reverseGeocodeLocation(location: location)
        */
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    
    func reverseGeocodeLocation(location: CLLocation){
    
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            
            print(placeMark.addressDictionary, terminator: "")
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName, terminator: "")
            
               // self.locationString += locationName as String
               // self.locationString += " "
                
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street, terminator: "")
                print("yoo")
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city, terminator: "")
                self.locationString += city as String
                self.locationString += ","
            }
            
            // State  // can also get Zip code. use "ZIP"
            if let state = placeMark.addressDictionary!["State"] as? NSString {
                print(state, terminator: "")
                self.locationString += state as String
                self.locationString += " "
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country, terminator: "")
                self.locationString += country as String
            }
            
            self.locationFound = true
        })
    
    }

    func postToFirebase(imgUrl: [String]){

        let spot: Dictionary<String, AnyObject> = [
        "spotName": spotNameField.text! as AnyObject,
        "imageUrls": imgUrl as AnyObject,
        "spotLocation" : locationString as AnyObject,
        "latitude" : latitude as AnyObject,
        "longitude" : longitude as AnyObject
        ]
        
        let firebasePost = DataService.instance.REF_SPOTS.childByAutoId()
        firebasePost.setValue(spot)
       
        spotNameField.text = ""
        imageSelected = false
        addPhotoOne.image = UIImage(named: "black_photo_btn")
        locationString = ""

    }
}
