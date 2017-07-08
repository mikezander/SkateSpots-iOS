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

class SpotVC:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var addPhotoOne: UIImageView!
    @IBOutlet weak var addPhotoTwo: UIImageView!
    @IBOutlet weak var addPhotoThree: UIImageView!
    @IBOutlet weak var addPhotoFour: UIImageView!


    
    //addGestureRecognizer(tapGestureRecognizer)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        showPhotoActionSheet()

        addPhotoTwo.addGestureRecognizer(setGestureRecognizer())
        addPhotoThree.addGestureRecognizer(setGestureRecognizer())
        addPhotoFour.addGestureRecognizer(setGestureRecognizer())
        
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
       self.present(self.imagePicker, animated: true, completion: nil)
        print("image tapped")
    }

  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            addPhotoOne.image = image
  
       
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
