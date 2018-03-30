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
import FirebaseDatabase

class ProfileVC: UIViewController, ProfileEditedProtocol{
    
    static let _instance = ProfileVC()
    
    var spots = [Spot]()
    var user: User? = nil
    var userKey : String? = nil
    var userRef:DatabaseReference!
    var profileView = UIView()
    var status = String()
    var headerViewHeight = CGFloat()
    var profileEdited: Bool = false
    var igUsername = ""
    var allowEdit = false
    var keys = [String]()
    var key = String()
    var tabBarHeight:CGFloat = 0.0
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var directMessageButton: UIButton!
    
    @IBOutlet weak var spotTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userKey == nil {
            userRef = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid)
            allowEdit = true
            backButton.isEnabled = false
            backButton.isHidden = true
            directMessageButton.isHidden = true
            directMessageButton.isEnabled = false
            
        } else {
            
            if let key = userKey {
                self.key = key
                userRef = DataService.instance.REF_USERS.child(key)
            }
            editButton.isEnabled = false
            editButton.isHidden = true
            allowEdit = false
            headerLabel.isHidden = true
        }

        addUserData()
 
        appendSpotsArray()
 
        spotTableView.register(HeaderCell.self, forCellReuseIdentifier: "headerCell")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard hasConnected else{
            errorAlert(title: "Network Connection Error", message: "Make sure you have a connection and try again")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if profileEdited{
            
            addUserData()
            spotTableView.reloadData()
            profileEdited = false
            
        }
        
        if userKey != nil{
            if let tabHeight = tabBarController?.tabBar.frame.height{
                tabBarController?.tabBar.isHidden = true
                tabBarHeight = tabHeight
                tabBarController?.tabBar.frame.size.height = 0
            }
        }
    
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userKey != nil{
            if tabBarHeight != 0.0{
                tabBarController?.tabBar.isHidden = false
                tabBarController?.tabBar.frame.size.height = tabBarHeight
            }
            
        }
        
    }
    
    func hasProfileBeenEdited(edited: Bool){
        self.profileEdited = edited
    }
    
    
    func addUserData(){
        
        DataService.instance.getCurrentUserProfileData(userRef: userRef.child("profile"), completionHandlerForGET: { success, data in
            
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
        
        DataService.instance.getSpotsFromUser(userRef: userRef, child: "spots",completionHandlerForGET: {success, data,keys, error in
            
            if error == nil{
                self.spots = data!
                self.keys = keys
            }
            DispatchQueue.main.async {
                print(keys)
                self.spotTableView.reloadData()
            }
            
        })
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var connected = Bool()
        
        if isInternetAvailable() && hasConnected{
            connected = true
        }else if !isInternetAvailable(){
            errorAlert(title: "Network Connection Error", message: "Make sure you have a connection and try again")
            connected = false
            
        }
        
        return connected
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editProfile" {
            if let viewController = segue.destination as? EditProfileVC {
                if self.user != nil{
                    viewController.user = self.user!
                    viewController.spots = self.spots //double check this
                    viewController.delegate = self
                }
                
            }
        }else if segue.identifier == "sendMessage"{
            if let vc = segue.destination as? ChatLogVC{
                if self.user != nil{
                //vc.hidesBottomBarWhenPushed = true
                vc.user = self.user
                vc.userKey = self.key
                }
            }
        
        }
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        
        _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
 
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(spotCicked))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    func spotCicked(tapGesture:UITapGestureRecognizer){
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "goToDetail") as! DetailVC
        vc.spot = spots[tapGesture.view!.tag]
        self.present(vc, animated: true, completion: nil)
    }
    
    func instagramLinkPressed(){
        print("pressed")
    }
    
    
}
extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 295.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView =  UIView()
        headerView.frame = CGRect(x: 0, y: 0,  width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        
        if let userName = user?.userName{
            headerCell.userName.text = userName
        }
        
        if let bio = user?.bio{
            headerCell.bio.text = bio
            headerCell.bio.sizeToFit()
            headerCell.bio.center.x = view.frame.width / 2
        }
        
        if let linkText = user?.link{
            headerCell.link.center.x = view.frame.width / 2
            
            if headerCell.bio.text == ""{
                headerCell.link.center.y = headerCell.bio.frame.origin.y + 10
            }else{
                headerCell.link.center.y = headerCell.bio.frame.origin.y + headerCell.bio.frame.height - 5
            }
            
            var link = UITextView() //work around for bug
            link = headerCell.link
            link.text = linkText
            link.sizeToFit()
            link.center.x = view.frame.width / 2
            
            headerView.addSubview(link)
        }
        
        if let igLinkText = user?.igLink{
            
            if headerCell.bio.text == "" && headerCell.link.text == ""{
                headerCell.igLink.center.y = headerCell.bio.frame.origin.y + 18
            }else if headerCell.link.text == ""{
                headerCell.igLink.center.y = headerCell.link.frame.origin.y + 15
            }else{
                headerCell.igLink.center.y = headerCell.link.frame.origin.y + headerCell.link.frame.height + 2
            }
            
            if user?.igLink != ""{
                headerCell.igLink.isHidden = false
                headerCell.igUsername = igLinkText
                headerCell.igLink.setTitle(igLinkText, for: .normal)
                headerCell.igLink.sizeToFit()
                headerCell.igLink.center.x = view.frame.width / 2
                headerView.addSubview(headerCell.igLink)
            }
            
        }
        
        headerCell.contributions.text = "👊 Contributions: \(spots.count)"
        
        if let userImage = user?.userImageURL{
            
            headerCell.configureProfilePic(userImage: userImage)

        }

        headerViewHeight = headerCell.returnHeight()
        headerView.addSubview(headerCell)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  
        if editingStyle == .delete{
    
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(spots[indexPath.row].spotName)?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete Spot", style: .destructive, handler: { (action) in
                
                DataService.instance.REF_SPOTS.child(self.spots[indexPath.row].spotKey).removeValue()
                self.userRef.child("spots").child(self.keys[indexPath.row]).removeValue()
                
                for url in self.spots[indexPath.row].imageUrls{
                
                    DataService.instance.deleteFromStorage(urlString: url, completion: { error in })
                
                }
                
                self.spots.remove(at: indexPath.item)
                self.keys.remove(at: indexPath.item)
                
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.spotTableView.reloadData()
                }
            })
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowEdit
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let spot = spots[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileCell
        
        cell.activityIdicator.startAnimating()
        
        cell.configureCell(spot: spot)

        cell.spotImage.isUserInteractionEnabled = true
        
        cell.spotImage.tag = indexPath.row
        
        cell.spotImage.addGestureRecognizer(setGestureRecognizer())
        
        return cell
    }
    
}
