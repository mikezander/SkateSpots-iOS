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
import FirebaseStorage

class SpotVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var spotNameField: UITextField!
    var imagePicker: UIImagePickerController!
    var count = 0
    var imageSelected = false
    var photoURLs = [String]()

    @IBOutlet weak var addPhotoOne: UIImageView!
    @IBOutlet weak var addPhotoTwo: UIImageView!
    @IBOutlet weak var addPhotoThree: UIImageView!
    @IBOutlet weak var addPhotoFour: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //photoURLs = [String]()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        showPhotoActionSheet()

        addPhotoOne.addGestureRecognizer(setGestureRecognizer())
        addPhotoTwo.addGestureRecognizer(setGestureRecognizer())
        addPhotoThree.addGestureRecognizer(setGestureRecognizer())
        addPhotoFour.addGestureRecognizer(setGestureRecognizer())
        
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
        
        addPhotosToStorage(image: defaultImg)
        
        if let imgTwo = addPhotoTwo.image, imageSelected == true, count >= 2{
           addPhotosToStorage(image: imgTwo)
        }
        
        if let imgThree = addPhotoThree.image, imageSelected == true, count >= 3{
           addPhotosToStorage(image: imgThree)
        }
        
        if let imgFour = addPhotoFour.image, imageSelected == true, count == 4{
            addPhotosToStorage(image: imgFour)
        }
       
        performSegue(withIdentifier: "backToFeedVC", sender: nil)
 
    }
    
    func addPhotosToStorage(image: UIImage){

        if let imgData = UIImageJPEGRepresentation(image, 0.2){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.instance.REF_SPOT_IMAGES.child(imgUid).put(imgData, metadata:metadata) {(metadata, error) in
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
            
        }
    }
    
    func addImagePressed(sender: UITapGestureRecognizer) {
        
       showPhotoActionSheet()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            addThumbnailPhoto(count, image)
            imageSelected = true
            count += 1
        }else{
            print("valid image wasn't selected")
        }
        
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(addImagePressed))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    func addThumbnailPhoto(_ count: Int,_ image: UIImage){
        switch count {
        case 0:
            addPhotoOne.image = image
        case 1:
            addPhotoTwo.image = image
        case 2:
            addPhotoThree.image = image
        case 3:
            addPhotoFour.image = image
        default:
            print("max number of photos")
        }
    }
    
    func postToFirebase(imgUrl: [String]){

        
        let spot: Dictionary<String, AnyObject> = [
        "spotName": spotNameField.text! as AnyObject,
        "imageUrls": imgUrl as AnyObject,
        "distance" : 11.1 as AnyObject,
        "spotLocation" : "Location" as AnyObject
        ]
        
        let firebasePost = DataService.instance.REF_SPOTS.childByAutoId()
        firebasePost.setValue(spot)
       
        spotNameField.text = ""
        imageSelected = false
        addPhotoOne.image = UIImage(named: "black_photo_btn")
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

}
