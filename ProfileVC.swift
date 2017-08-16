//
//  ProfileVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileVC: UIViewController{

    var spots = [Spot]()
    var user: User? = nil
    let currentUserRef = DataService.instance.REF_USERS.child(FIRAuth.auth()!.currentUser!.uid)
    var profileView = UIView()

    @IBOutlet weak var spotTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUserData()
        
        appendSpotsArray()

        print(spots.count)
       
        spotTableView.register(HeaderCell.self, forCellReuseIdentifier: "headerCell")
        
        print(UIScreen.main.bounds.height)
     
    }
    
    
    func addUserData(){
    
        DataService.instance.getCurrentUserData(userRef: currentUserRef.child("profile"), completionHandlerForGET: { success, data in
            
            if let data = data{
                
                self.user = data

                DispatchQueue.main.async {
                    self.spotTableView.reloadData()
                }
               
                
            }else{
                print("data is empty")
            }

 
        })

    }
    
    
    func appendSpotsArray(){
        
        DataService.instance.getSpotsFromUser(userRef: currentUserRef, completionHandlerForGET: {success, data, error in
            
            if error == nil{
                self.spots = data!
            }
            DispatchQueue.main.async {
                self.spotTableView.reloadData()
            }
            
        })
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editProfile" {
            if let viewController = segue.destination as? EditProfileVC {
                if(self.user != nil){
                    viewController.user = self.user!
                }
            }
        }
    }
    
  
    
    @IBAction func backBtnPressed(_ sender: Any) {
       _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
}
extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.height / 2
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView =  UIView()
        headerView.frame = CGRect(x: 0, y: 50,  width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        
        if let userName = user?.userName{
         headerCell.userName.text = userName
        }
        
        headerCell.contributions.text = "Contributions: \(spots.count)"

        if let userImage = user?.userImageURL{
            let ref = FIRStorage.storage().reference(forURL: (userImage))
            ref.data(withMaxSize: 1 * 1024 * 1024, completion:{ (data, error) in
                if error != nil{
                    print("Mke: Unable to download image from firebase storage")
                }else{
                    
                    if let data = data{
                        headerCell.profilePhoto.image = UIImage(data:data)
                    }
                }
                
                
            })
        }
        
 
        headerView.addSubview(headerCell)
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileCell
        
        if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[0] as NSString){
            
            cell.configureCell(spot: spot, img: img, count: 0)
        }else{
            cell.configureCell(spot: spot, count: 0)
        }
    
        return cell
    }

}
