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

    var photoURLs = [String]()
    
    @IBOutlet weak var addPhotoOne: UIImageView!
    @IBOutlet weak var addPhotoTwo: UIImageView!
    @IBOutlet weak var addPhotoThree: UIImageView!
    @IBOutlet weak var addPhotoFour: UIImageView!
    
    @IBOutlet weak var spotNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var SpotTypeControl: UISegmentedControl!

    @IBOutlet weak var ledgeBtn: UIButton!
    @IBOutlet weak var railBtn: UIButton!
    @IBOutlet weak var gapBtn: UIButton!
    @IBOutlet weak var bumpBtn: UIButton!
    @IBOutlet weak var mannyBtn: UIButton!
    @IBOutlet weak var bankBtn: UIButton!
    @IBOutlet weak var trannyBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var bustLabel: UILabel!
    
 
    var imagePicker: UIImagePickerController!
    var count = 0
    var imageSelected = false
    var locationManager = CLLocationManager()
    var locationString: String = ""
    var location: CLLocation?
    var locationFound = false
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var spotType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        spotNameField.delegate = self
        spotNameField.layer.cornerRadius = 0.0
        spotNameField.layer.borderWidth = 1.5
        
        descriptionTextView.delegate = self
        descriptionTextView.text = "Spot Description"
        descriptionTextView.textContainer.maximumNumberOfLines = 4
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 1.5
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        showPhotoActionSheet()

        addPhotoOne.addGestureRecognizer(setGestureRecognizer())
        addPhotoTwo.addGestureRecognizer(setGestureRecognizer())
        addPhotoThree.addGestureRecognizer(setGestureRecognizer())
        addPhotoFour.addGestureRecognizer(setGestureRecognizer())
        
        gapBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let segAttributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.green,
            NSFontAttributeName: UIFont(name: "Avenir-MediumOblique", size: 14)!
        ]
        
        SpotTypeControl.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], for: UIControlState.selected)
    }
 
    
    @IBAction func bustSlider(_ sender: UISlider) {
        bustLabel.text = String(Int(sender.value))
    }
    
    @IBAction func SpotTypePressed(_ sender: UIButton) {
        
        if sender.backgroundColor == UIColor.clear{
            switch sender.tag {
        case 0,1,2,3,4,5,6:
            sender.isSelected = true
            sender.backgroundColor = UIColor.black
            sender.setTitleColor(.green, for: .normal)
            
        case 7:
            sender.isSelected = true
            sender.backgroundColor = UIColor.black
            sender.setTitleColor(.green, for: .normal)
            disableButtonsForTypeOther(btn: ledgeBtn)
            disableButtonsForTypeOther(btn: railBtn)
            disableButtonsForTypeOther(btn: gapBtn)
            disableButtonsForTypeOther(btn: bumpBtn)
            disableButtonsForTypeOther(btn: mannyBtn)
            disableButtonsForTypeOther(btn: bankBtn)
            disableButtonsForTypeOther(btn: trannyBtn)
        default: break
            } //end switch
       
        }else{
           
            switch sender.tag {
            case 0,1,2,3,4,5,6:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
            case 7:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
                ledgeBtn.isEnabled = true
                railBtn.isEnabled = true
                gapBtn.isEnabled = true
                bumpBtn.isEnabled = true
                mannyBtn.isEnabled = true
                bankBtn.isEnabled = true
                trannyBtn.isEnabled = true
            
            default: break
                
            }//end switch
        }
    }
    
    func disableButtonsForTypeOther(btn: UIButton){
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(.black, for: .normal)
        btn.isEnabled = false
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
                locationManager.requestWhenInUseAuthorization()
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
        
        if SpotTypeControl.selectedSegmentIndex == 0{
 
            if !ledgeBtn.isSelected && !railBtn.isSelected && !gapBtn.isSelected && !mannyBtn.isSelected
                && !bumpBtn.isSelected && !trannyBtn.isSelected && !bankBtn.isSelected && !otherBtn.isSelected{
            
                print("A SpotType must be selected!!")
            }
            
            if ledgeBtn.isSelected { spotType += "Ledges" }
            if railBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Rail" }
            if gapBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Stairs/Gap" }
            if bumpBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Bump" }
            if mannyBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Manual" }
            if bankBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Bank" }
            if trannyBtn.isSelected { if spotType != ""{ spotType += "-"}; spotType += "Tranny" }
            if otherBtn.isSelected { spotType += "Other" }

        
        }else{
    
            spotType += "Skatepark"
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

    @IBAction func toggleSpotType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1{
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.ledgeBtn.center.x -= self.view.bounds.width
                    self.railBtn.center.x -= self.view.bounds.width
                    self.gapBtn.center.x -= self.view.bounds.width
                    self.bumpBtn.center.x -= self.view.bounds.width
                    self.mannyBtn.center.x += self.view.bounds.width
                    self.bankBtn.center.x += self.view.bounds.width
                    self.trannyBtn.center.x += self.view.bounds.width
                    self.otherBtn.center.x += self.view.bounds.width
                    
                })
            }
            
        }else{
        
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.ledgeBtn.center.x += self.view.bounds.width
                    self.railBtn.center.x += self.view.bounds.width
                    self.gapBtn.center.x += self.view.bounds.width
                    self.bumpBtn.center.x += self.view.bounds.width
                    self.mannyBtn.center.x -= self.view.bounds.width
                    self.bankBtn.center.x -= self.view.bounds.width
                    self.trannyBtn.center.x -= self.view.bounds.width
                    self.otherBtn.center.x -= self.view.bounds.width
                })
            }
            
        }
    }

    func postToFirebase(imgUrl: [String]){

        let spot: Dictionary<String, AnyObject> = [
        "spotName": spotNameField.text! as AnyObject,
        "imageUrls": imgUrl as AnyObject,
        "spotLocation" : locationString as AnyObject,
        "spotType": spotType as AnyObject,
        "latitude" : latitude as AnyObject,
        "longitude" : longitude as AnyObject,
        "user": FIRAuth.auth()!.currentUser!.uid as AnyObject //may not be safe but works for now
        ]
        
        let firebasePost = DataService.instance.REF_SPOTS.childByAutoId()
        firebasePost.setValue(spot)
       
        spotNameField.text = ""
        imageSelected = false
        addPhotoOne.image = UIImage(named: "black_photo_btn")
        locationString = ""
        spotType = ""

    }
}
extension SpotVC: UITextFieldDelegate, UITextViewDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        spotNameField.layer.borderColor = UIColor.green.cgColor
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       spotNameField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descriptionTextView.resignFirstResponder()
            descriptionTextView.layer.borderColor = UIColor.black.cgColor
            return false
        }
        return true
    }
 
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
        descriptionTextView.layer.borderColor = UIColor.green.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Spot Description"
            descriptionTextView.textColor = UIColor.lightGray
        }
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
    }

}
