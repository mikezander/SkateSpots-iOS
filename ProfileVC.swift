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

class ProfileVC: UIViewController, ProfileEditedProtocol, SpotDetailDelegate {

    static let _instance = ProfileVC()
    
    var allSpots = [Spot]()
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

    //var segmentedControl: CustomSegmentControl!
    var segmentedControl: UISegmentedControl!
    
    var headerView2: UIView!

    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var directMessageButton: UIButton!
    
    @IBOutlet weak var spotTableView: UITableView!

    
//    @IBAction func valueChanged(_ sender: Any) {
//        let segmentedControl = sender as? UISegmentedControl
//        switch segmentedControl?.selectedSegmentIndex {
//            case 0:
//                segmentedControl?.selectedSegmentIndex = 1
//                spotTableView.reloadData()
//                break
//            case 1:
//                segmentedControl?.
//                spotTableView.reloadData()
//                break
//            case UISegmentedControl.noSegment:
//                // do something
//                break
//            default:
//                print("No option for: \(segmentedControl?.selectedSegmentIndex ?? 0)")
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
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
            
            let adminUser = "guYoQDlipBgkGxjxq7RwOYd1gnz1"
            if Auth.auth().currentUser?.uid == adminUser {
                allowEdit = true
            } else {
               allowEdit = false
            }
            
            headerLabel.isHidden = true
        }
        
        segmentedControl = UISegmentedControl(items: ["", ""])
        segmentedControl.setImage(UIImage(named: "thumbnails")?.scaleImage(scaleToSize: CGSize(width: 20, height: 20)), forSegmentAt: 0)
        segmentedControl.setImage(UIImage(named: "list_view")?.scaleImage(scaleToSize: CGSize(width: 20, height: 20)), forSegmentAt: 1)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segmentedToggled)))
        //view.addSubview(segmentedControl)


        //segmentedControl.addTarget(self,action:#selector(valueChanged(_:)), for: .valueChanged)

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
        
        if profileEdited {
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
            if tabBarHeight != 0.0 {
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
            
            if let data = data {
                
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
        } else if segue.identifier == "sendMessage"{
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
 
//    func setGestureRecognizer() -> UITapGestureRecognizer {
//        var tapGestureRecognizer = UITapGestureRecognizer()
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(spotCicked))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        return tapGestureRecognizer
//    }
    
    @objc func firstSpotCicked(tapGesture:UITapGestureRecognizer) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
            vc.spot = spots[tapGesture.view!.tag]
            vc.spots = allSpots
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
        @objc func secondSpotCicked(tapGesture:UITapGestureRecognizer) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
                vc.spot = spots[tapGesture.view!.tag]
                vc.spots = allSpots
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        }
    
    func nearbySpotPressed(spot: Spot, spots: [Spot]) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
            vc.spot = spot
            vc.spots = allSpots
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        } 
    }
    
    func instagramLinkPressed(){
        print("pressed")
    }
    
    @objc func segmentedToggled() {
        segmentedControl.selectedSegmentIndex = segmentedControl.selectedSegmentIndex == 0 ? 1 : 0
        spotTableView.reloadData()
    }
}
extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300.0 //335.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView =  UIView()
        headerView.frame = CGRect(x: 0, y: 0,  width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell

        if let userName = user?.userName {
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

//        headerCell.contributions.text = "👊 Contributions: \(spots.count)"
        headerCell.contributions.text = "          Spots: \(spots.count)"
        if let userImage = user?.userImageURL{
            headerCell.configureProfilePic(userImage: userImage)
        }


        //segmentedControl.frame = CGRect(x: 0, y: headerCell.contributions.frame.maxY + 5, width: self.view.frame.width, height: 35)
        //segmentedControl.selectedSegmentIndex = 0
//        headerView.addSubview(segmentedControl)
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        segmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
//        segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
//        segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
//        segmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true



        //segmentedControl.frame = headerView.frame
        //segmentedControl.selectedSegmentIndex = 0
        //segmentedControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segmentedToggled)))
        headerView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        //segmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true



        //headerViewHeight = headerCell.returnHeight()

        headerView.addSubview(headerCell)
        return headerView
    }
    
    
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////
//        if headerView2 == nil {
//            headerView2 =  UIView()
//
//            segmentedControl.frame = headerView.frame
//            segmentedControl.selectedSegmentIndex = 0
//            segmentedControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segmentedToggled)))
//            headerView2.addSubview(segmentedControl)
//            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//            segmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
//            segmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
//            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
//            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
//            segmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        }
//
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return segmentedControl.selectedSegmentIndex == 1 ? 125 : view.frame.width / 2
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 200//headerView.frame.height//35.0
//    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return spots.count
        } else {
            var count = spots.count / 2
            count += spots.count % 2
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
  
        if editingStyle == .delete {
            
            if segmentedControl.selectedSegmentIndex == 0 {
 
                let alertController = UIAlertController(title: "Delete Spot", message: "Which spot would you like to delete??", preferredStyle: .alert)

                let deleteAction1 = UIAlertAction(title: "1st: \(spots[indexPath.row * 2].spotName)", style: .destructive, handler: { (action) in
                    
                    
                    let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(self.spots[indexPath.row * 2].spotName)?", preferredStyle: .alert)
                    let deleteAction = UIAlertAction(title: "Delete Spot", style: .destructive, handler: { (action) in
                        
                        let index = indexPath.row * 2
                        
                        DataService.instance.REF_SPOTS.child(self.spots[index].spotKey).removeValue()
                        self.userRef.child("spots").child(self.keys[index]).removeValue()

                        for url in self.spots[index].imageUrls {
                            DataService.instance.deleteFromStorage(urlString: url, completion: { error in })
                        }

                        self.spots.remove(at: index)
                        self.keys.remove(at: index)

                        DispatchQueue.main.async {
                            //self.spotTableView.deleteRows(at: [indexPath], with: .fade)
                            self.spotTableView.reloadData()
                        }
                         
                    })
                    
                    alertController.addAction(deleteAction)

                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)

                    self.present(alertController, animated: true, completion: nil)
                    
                })
                
                alertController.addAction(deleteAction1)

                if indexPath.row * 2 + 1 <= spots.count - 1 {
                    let deleteAction2 = UIAlertAction(title: "2nd: \(spots[indexPath.row * 2 + 1].spotName)", style: .destructive, handler: { (action) in
                        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(self.spots[indexPath.row * 2 + 1].spotName)?", preferredStyle: .alert)
                        let deleteAction = UIAlertAction(title: "Delete Spot", style: .destructive, handler: { (action) in
                            
                            let index = indexPath.row * 2 + 1
                            
                            DataService.instance.REF_SPOTS.child(self.spots[index].spotKey).removeValue()
                            self.userRef.child("spots").child(self.keys[index]).removeValue()

                            for url in self.spots[index].imageUrls {
                                DataService.instance.deleteFromStorage(urlString: url, completion: { error in })
                            }

                            self.spots.remove(at: index)
                            self.keys.remove(at: index)

                            DispatchQueue.main.async {
                                //self.spotTableView.deleteRows(at: [indexPath], with: .fade)
                                self.spotTableView.reloadData()
                            }

                            // delete logic
                        })
                        
                        alertController.addAction(deleteAction)

                        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alertController.addAction(cancelAction)

                        self.present(alertController, animated: true, completion: nil)
                    })
                    
                    alertController.addAction(deleteAction2)

                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                present(alertController, animated: true, completion: nil)

            } else {
                let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(spots[indexPath.row].spotName)?", preferredStyle: .alert)

                let deleteAction = UIAlertAction(title: "Delete Spot", style: .destructive, handler: { (action) in
                    self.deleteSpot(indexPath: indexPath)
                })

                alertController.addAction(deleteAction)

                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func deleteSpot(indexPath: IndexPath) {
        DataService.instance.REF_SPOTS.child(self.spots[indexPath.row].spotKey).removeValue()
        self.userRef.child("spots").child(self.keys[indexPath.row]).removeValue()

        for url in self.spots[indexPath.row].imageUrls {
            DataService.instance.deleteFromStorage(urlString: url, completion: { error in })
        }

        self.spots.remove(at: indexPath.item)
        self.keys.remove(at: indexPath.item)

        DispatchQueue.main.async {
            self.spotTableView.deleteRows(at: [indexPath], with: .fade)
            self.spotTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowEdit
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 1 {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spot_detail_vc") as? SpotDetailVC {
                vc.spot = spots[indexPath.row]
                vc.spots = allSpots
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! ProfileImagesCell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spot = spots[indexPath.row]

        if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProfileCell
            
            cell.activityIdicator.startAnimating()
            
            
            cell.configureCell(spot: spot)
            
//            cell.spotImage.isUserInteractionEnabled = true
//
//            cell.spotImage.tag = indexPath.row
//
//            cell.spotImage.addGestureRecognizer(setGestureRecognizer())
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! ProfileImagesCell

            let index = indexPath.row * 2
            if index + 1 <= spots.count - 1 {

                cell.configureCells(spotOne: spots[index], spotTwo: spots[index + 1])
                
                cell.spotImageFirst.tag = index
                cell.spotImageSecond.tag = index + 1
                
                cell.spotImageFirst.isUserInteractionEnabled = true
                cell.spotImageSecond.isUserInteractionEnabled = true

                
                cell.spotImageFirst.addGestureRecognizer( UITapGestureRecognizer(target: self, action:#selector(firstSpotCicked)))
                cell.spotImageSecond.addGestureRecognizer( UITapGestureRecognizer(target: self, action:#selector(secondSpotCicked)))

            } else {

                cell.configureCell(spotOne: spots[index])
                cell.spotImageFirst.tag = index
                cell.spotImageFirst.isUserInteractionEnabled = true
                cell.spotImageFirst.addGestureRecognizer( UITapGestureRecognizer(target: self, action:#selector(firstSpotCicked)))
                
                cell.spotImageSecond.isUserInteractionEnabled = false
                cell.spotImageSecond.image = nil
                
            }
            return cell

        }

        //cell.configureCell(spot: spot, row: indexPath.row)

    }
}

extension UIImage {
    func scaleImage(scaleToSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaleToSize)

        self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: scaleToSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return newImage!
    }
}



    
    




