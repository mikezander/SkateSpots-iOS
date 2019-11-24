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
import SVProgressHUD
import AVFoundation
//import AudioToolbox

class LocationLabel: UILabel, Jitterable {
    
}

class LocationImageView: UIImageView, Jitterable {
    
}

class SpotVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate{
    
    var photoURLs = [String]()
    var user: User!
    
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
    @IBOutlet weak var anytimeBtn: UIButton!
    @IBOutlet weak var weekdayBtn: UIButton!
    @IBOutlet weak var weekendBtn: UIButton!
    @IBOutlet weak var nightBtn: UIButton!
    @IBOutlet weak var addSpotButton: UIButton!
    @IBOutlet weak var topPhotoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationLabel: LocationLabel!
    @IBOutlet weak var locationImageView: LocationImageView!
   
    var imagePicker: UIImagePickerController!
    var count = 0
    var imageSelected = false
    var locationManager = CLLocationManager()
    var locationString: String = ""
    var location: CLLocation?
    var locationFound = false
    var locationFoundIndex: Int?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var spotType: String = ""
    var bestTimeToSkate: String = ""
    var hasRan = false
    var generator: UIImpactFeedbackGenerator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            shadow.shadowOffset = CGSize(width: 0, height: 1)
            let titleFont : UIFont = UIFont(name: "Avenir-Book", size: 15)!//UIFont.systemFont(ofSize: 15.0)

            SpotTypeControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .shadow: shadow, .font: titleFont], for: .selected)
            SpotTypeControl.setTitleTextAttributes([.foregroundColor: UIColor.black, .shadow: shadow, .font: titleFont], for: .normal)

            SpotTypeControl.backgroundColor = .lightGray
            SpotTypeControl.selectedSegmentTintColor = .black
        }
        
       
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        addSpotButton.layer.cornerRadius = 12.0
        
        spotNameField.delegate = self
        spotNameField.layer.cornerRadius = 7.0
        spotNameField.layer.borderWidth = 1.0
        
        descriptionTextView.delegate = self
        descriptionTextView.text = "Spot Description"
        descriptionTextView.textContainer.maximumNumberOfLines = 6
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.cornerRadius = 7.0
        descriptionTextView.layer.borderWidth = 1.0
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        showPhotoActionSheet()
 
        addPhotoOne.addGestureRecognizer(setGestureRecognizer())
        addPhotoTwo.addGestureRecognizer(setGestureRecognizer())
        addPhotoThree.addGestureRecognizer(setGestureRecognizer())
        addPhotoFour.addGestureRecognizer(setGestureRecognizer())
        
        gapBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        anytimeBtn.isSelected = true
        anytimeBtn.backgroundColor = UIColor.black
        anytimeBtn.setTitleColor(.white, for: .normal)
        
        addSpotButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addSpotButton.layer.shadowOffset = CGSize(width:0.0,height: 2.0)
        addSpotButton.layer.shadowOpacity = 1.0
        addSpotButton.layer.shadowRadius = 0.0
        addSpotButton.layer.masksToBounds = false
        addSpotButton.layer.cornerRadius = 4.0
        
        topPhotoLabel.isHidden = true
        
        generator = UIImpactFeedbackGenerator(style: .light)
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
    }

    @IBAction func bustSlider(_ sender: UISlider) {
        bustLabel.text = String(Int(sender.value))
        
        if Int(sender.value) == 0{
            bustLabel.text = "Low"
        }else if Int(sender.value) == 1{
            bustLabel.text = "Medium"
        }else if Int(sender.value) == 2{
            bustLabel.text = "High"
        }
    }
    
    @IBAction func SpotTypePressed(_ sender: UIButton) {
        
        if sender.backgroundColor == UIColor.clear {
            switch sender.tag {
            case 0,1,2,3,4,5,6:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                otherBtn.backgroundColor = UIColor.clear
                otherBtn.setTitleColor(.black, for: .normal)
                otherBtn.isSelected = false
                
            case 7:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                disableButtonsForTypeOther(btn: ledgeBtn)
                disableButtonsForTypeOther(btn: railBtn)
                disableButtonsForTypeOther(btn: gapBtn)
                disableButtonsForTypeOther(btn: bumpBtn)
                disableButtonsForTypeOther(btn: mannyBtn)
                disableButtonsForTypeOther(btn: bankBtn)
                disableButtonsForTypeOther(btn: trannyBtn)
            case 8:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                disableButtonsForTypeOther(btn: weekdayBtn)
                disableButtonsForTypeOther(btn: weekendBtn)
                disableButtonsForTypeOther(btn: nightBtn)
            case 9:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                disableButtonsForTypeOther(btn: anytimeBtn)
                disableButtonsForTypeOther(btn: weekendBtn)
                disableButtonsForTypeOther(btn: nightBtn)
            case 10:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                disableButtonsForTypeOther(btn: anytimeBtn)
                disableButtonsForTypeOther(btn: weekdayBtn)
                disableButtonsForTypeOther(btn: nightBtn)
            case 11:
                sender.isSelected = true
                sender.backgroundColor = UIColor.black
                sender.setTitleColor(.white, for: .normal)
                disableButtonsForTypeOther(btn: anytimeBtn)
                disableButtonsForTypeOther(btn: weekdayBtn)
                disableButtonsForTypeOther(btn: weekendBtn)
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
            case 8:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
                weekdayBtn.isEnabled = true
                weekendBtn.isEnabled = true
                nightBtn.isEnabled = true
            case 9:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
                anytimeBtn.isEnabled = true
                weekendBtn.isEnabled = true
                nightBtn.isEnabled = true
            case 10:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
                anytimeBtn.isEnabled = true
                weekdayBtn.isEnabled = true
                nightBtn.isEnabled = true
            case 11:
                sender.isSelected = false
                sender.backgroundColor = UIColor.clear
                sender.setTitleColor(.black, for: .normal)
                anytimeBtn.isEnabled = true
                weekdayBtn.isEnabled = true
                weekendBtn.isEnabled = true
                
            default: break
                
            }//end switch
        }
    }
    
    func disableButtonsForTypeOther(btn: UIButton){
        btn.backgroundColor = UIColor.clear
        btn.setTitleColor(.black, for: .normal)
    }
    
    @objc func addImagePressed(sender: UITapGestureRecognizer) {
        showPhotoActionSheet()
    }
    
    @IBAction func longPressDelete(_ sender: UILongPressGestureRecognizer){
        print("long press pressed")
        if sender.state == UIGestureRecognizer.State.ended {
            
            if count == 0{
                return
            }else if count == 1 {
                addPhotoOne.image = UIImage(named: "black_photo_btn")
                
                if locationFoundIndex == 1{
                    clearLocationData()
                }
                imageSelected = false
                count -= 1
            }else if count == 2 {
                addPhotoTwo.image = UIImage(named: "black_photo_btn")
                
                if locationFoundIndex == 2 {
                    clearLocationData()
                }
                
                count -= 1
            }else if count == 3{
                addPhotoThree.image = UIImage(named: "black_photo_btn")
                
                if locationFoundIndex == 3 {
                    clearLocationData()
                }
                
                count -= 1
            } else if count == 4 {
                addPhotoFour.image = UIImage(named: "black_photo_btn")
                
                if locationFoundIndex == 4 {
                    clearLocationData()
                }
                
                count -= 1
            }
            
        }
        
    }
    
    func clearLocationData() {
        
        locationImageView.jitter()
        locationLabel.jitter()
        locationLabel.text = "Location not found"
        locationImageView.image = UIImage(named: "x")!
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        locationFound = false
        latitude = nil
        longitude = nil
        locationString = ""
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(addImagePressed))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    func showPhotoActionSheet(){
        
        guard isInternetAvailable() && hasConnected else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
            return
        }

        var actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        
            if UIApplication.isFirstLaunch() && !hasRan{

                    actionSheet = UIAlertController(title: "*Sk8Spots prefers portrait(vertical) spot photos*\n\nPhoto Source", message: "Choose a source", preferredStyle: .actionSheet)
                    self.hasRan = true
            }
        
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else { print("Sorry cant take photo") }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            let photos = PHPhotoLibrary.authorizationStatus()
            
            if photos == .notDetermined {
                
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{ } else { }
                })
            }
            
            
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

         self.present(actionSheet, animated: true, completion: nil)
    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        dismiss(animated: true, completion: nil)
//        guard let selectedImage = info[.editedImage] as? UIImage else { return }
//        userProflieView.image = selectedImage
//        imageSelected = true
//    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[.editedImage] as? UIImage {
//            guard let properOrientatedImage =  image.rotateCameraImageToProperOrientation(imageSource: image) else { return }

            if (!locationFound) && (latitude == nil) && (longitude == nil){
                
                if(picker.sourceType == .camera){
                    locationManager = CLLocationManager()
                    self.locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
                    
                } else {

                    if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset, let location = asset.location {
                        latitude = location.coordinate.latitude
                        longitude = location.coordinate.longitude
                        reverseGeocodeLocation(location: location)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.locationLabel.alpha = 1.0
                            self.locationImageView.alpha = 1.0
                            self.locationLabel.text = "Location not found"
                            self.locationImageView.image = UIImage(named: "x")!
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.locationLabel.jitter()
                            self.locationImageView.jitter()
                        }
                    }
                }
            }

            addThumbnailPhoto(count, image)
            addPhotoOne.layer.borderWidth = 1.5
            addPhotoOne.layer.borderColor = FLAT_GREEN.cgColor
            topPhotoLabel.isHidden = false
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
    
    @IBAction func addSpotButtonPressed(_ sender: Any) {
        
        guard isInternetAvailable() && hasConnected else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
            return
        }
        
        guard let spotName = spotNameField.text, spotName != "" else{
            errorAlert(title: "Error", message: "You must enter a spot name!")
            return
        }
        
        guard let defaultImg = addPhotoOne.image, imageSelected == true else{
            errorAlert(title: "Error", message: "You must upload a spot image!")
            return
        }
        
        if !locationFound{
            errorAlert(title: "Location not found!", message: "* Make sure at least one of your photos have been taken at the spot ")
            return
        }
        
        if SpotTypeControl.selectedSegmentIndex == 0 {
            
            if !ledgeBtn.isSelected && !railBtn.isSelected && !gapBtn.isSelected && !mannyBtn.isSelected
                && !bumpBtn.isSelected && !trannyBtn.isSelected && !bankBtn.isSelected && !otherBtn.isSelected{
                
                errorAlert(title: "Error", message: "A spot type must be selected!")
                return
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
        
        if anytimeBtn.isSelected{ bestTimeToSkate = "Anytime" }
        if weekdayBtn.isSelected{ bestTimeToSkate = "Weekday" }
        if weekendBtn.isSelected{ bestTimeToSkate = "Weekend" }
        if nightBtn.isSelected{ bestTimeToSkate = "Night" }
        
        SVProgressHUD.setForegroundColor(FLAT_GREEN)
        SVProgressHUD.show()
        
        addPhotosToStorage(image: defaultImg, true)
        //performSegue was here in v2.0
    }
    
    
    func addPhotosToStorage(image: UIImage,_ isDefault: Bool){
        if let imgData = image.jpegData(compressionQuality: 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let uploadTask = DataService.instance.REF_SPOT_IMAGES.child(imgUid).putData(imgData, metadata:metadata) {(metadata, error) in
                
                if error != nil {
                    SVProgressHUD.dismiss()
                    self.errorAlert(title: "Error uploading image", message: "There was an error uploading you image/s to storage, please try again.")
                }else{
                    
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                        self.photoURLs.append(url)
                        
                        if self.photoURLs.count == self.count {
                            
                            self.postToFirebase(imgUrl: self.photoURLs)
                        }
                    }
                }
                
            }
            if isDefault {
                _ = uploadTask.observe(.success) { snapshot in
                    
                    if let imgTwo = self.addPhotoTwo.image, self.imageSelected == true, self.count >= 2 {
                        self.addPhotosToStorage(image: imgTwo, false)
                    }
                    
                    if let imgThree = self.addPhotoThree.image, self.imageSelected == true, self.count >= 3 {
                        self.addPhotosToStorage(image: imgThree, false)
                    }
                    
                    if let imgFour = self.addPhotoFour.image, self.imageSelected == true, self.count == 4 {
                        self.addPhotosToStorage(image: imgFour, false)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        if latitude == nil && longitude == nil {
            
            if let location = locations.first{
                print("1")
                print("Found user's location: \(location.coordinate.latitude)")
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                reverseGeocodeLocation(location: location)
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.locationLabel.alpha = 1.0
            self.locationImageView.alpha = 1.0
            self.locationLabel.text = "Location not found"
            self.locationImageView.image = UIImage(named: "x")!
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.locationLabel.jitter()
            self.locationImageView.jitter()
        }
        
        if error.localizedDescription == "The operation couldn’t be completed. (kCLErrorDomain error 1.)" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.errorAlert(title: "Your location was not found!", message: "Make sure you have allowed location for Sk8Spots. Go to settings, then scroll down to Sk8Spots and allow location access.")
            }
        }

    }
    
    
    func reverseGeocodeLocation(location: CLLocation){
        
        activityIndicator.startAnimating()
        
        let geoCoder = CLGeocoder()

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            guard error == nil else{
                
                self.errorAlert(title: "Internet Connetion Error", message: "Bad internet connection while trying to find this photos location. Retry when you are connected")
                
                self.longitude = nil
                self.latitude = nil
                
                DispatchQueue.main.async{self.activityIndicator.stopAnimating()}
                
                return
            }
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary as Any, terminator: "")
            
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
                self.locationString += "-" //used as deliminator in Spot.swift
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country, terminator: "")
                self.locationString += country as String
            }
            
            self.locationFound = true
            self.locationFoundIndex = self.count
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
               
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.locationLabel.alpha = 1.0
                    self.locationImageView.alpha = 1.0
                    self.locationLabel.text = "Location found"
                    self.locationImageView.image = UIImage(named: "green_check")
                    self.view.layoutIfNeeded()
                }, completion: nil)

                let systemSoundID: SystemSoundID = 1114
                AudioServicesPlaySystemSound (systemSoundID)
            }

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
        
        var spot: Dictionary<String, AnyObject> = [
            "spotName": spotNameField.text! as AnyObject,
            "imageUrls": imgUrl as AnyObject,
            "spotLocation" : locationString as AnyObject,
            "spotType": spotType as AnyObject,
            "spotDescription": descriptionTextView.text as AnyObject,
            "kickOut": bustLabel.text as AnyObject,
            "bestTimeToSkate": bestTimeToSkate as AnyObject,
            "latitude" : latitude as AnyObject,
            "longitude" : longitude as AnyObject,
            "user": Auth.auth().currentUser!.uid as AnyObject //may not be safe but works for now
        ]
        
        let firebasePost = DataService.instance.REF_SPOTS.childByAutoId()
        
        DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("profile").observeSingleEvent(of: .value,with: { (snapshot) in
            if !snapshot.exists() { print("Username not found! SpotRow.swift"); SVProgressHUD.dismiss(); return }
            
            if let username = snapshot.childSnapshot(forPath: "username").value as? String{
                
                if let userImageURL = snapshot.childSnapshot(forPath: "userImageURL").value as? String{
                    
                    self.user = User(userName: username, userImageURL: userImageURL, bio: "", link: "", igLink: "")
                    
                    spot["username"] = self.user.userName as AnyObject?
                    spot["userImageURL"] = self.user.userImageURL as AnyObject?
                    
                    firebasePost.setValue(spot)
                    
                }
            }
        })
        
        let userSpotsDict: Dictionary<String,AnyObject> = [firebasePost.key: true as AnyObject]
        
        DataService.instance.updateDBUser(uid: Auth.auth().currentUser!.uid, child: "spots", userData: userSpotsDict)
        
        spotNameField.text = ""
        imageSelected = false
        addPhotoOne.image = UIImage(named: "black_photo_btn")
        locationString = ""
        spotType = ""
        
        SVProgressHUD.dismiss()

        performSegue(withIdentifier: "backToFeedVC", sender: nil)
    }

}

extension SpotVC: UITextFieldDelegate, UITextViewDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        spotNameField.layer.borderColor = FLAT_GREEN.cgColor
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
        descriptionTextView.layer.borderColor = FLAT_GREEN.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Spot Description"
            descriptionTextView.textColor = UIColor.lightGray
        }
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
    }
}
