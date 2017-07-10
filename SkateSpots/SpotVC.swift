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
    
    @IBAction func addSpotPressed(_ sender: Any) {
        
        guard let spotName = spotNameField.text, spotName != "" else{
            print("Spot Name must be entered")
            return
        }
        
        guard let img = addPhotoOne.image, imageSelected == true else{
            print("an image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.instance.REF_SPOT_IMAGES.child(imgUid).put(imgData, metadata:metadata) {(metadata, error) in
                
                if error != nil{
                    print("unable to upload image to firebase storage")
                }else{
                    print("successfully uploaded to firebase sotrage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL{
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
        //let vc = FeedVC()
       // present(vc, animated: true, completion: nil)
    }
    func imageTapped(sender: UITapGestureRecognizer) {
        
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
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped))
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
    
    func postToFirebase(imgUrl: String){
        let spot: Dictionary<String, AnyObject> = [
        "spotName": spotNameField.text! as AnyObject,
        "imageUrls": [imgUrl] as AnyObject,
        "distance" : 0.1 as AnyObject,
        "spotLocation" : "fuck it for now" as AnyObject
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
