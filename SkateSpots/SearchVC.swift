//
//  SearchVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SearchVC: UIViewController {
    
    var users = [User]()
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    var selectedUser: User?
    var currentUserKey = String()
 
    @IBOutlet weak var userTableView: UITableView!
    
    @IBOutlet weak var searchView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .blackTranslucent
        searchView.addSubview(searchController.searchBar)
        
       // userTableView.tableHeaderView = searchController.searchBar
       
        userTableView.separatorStyle = .none

        currentUserKey = Auth.auth().currentUser!.uid
        retrieveUsers()
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func retrieveUsers() {
        let usersRef = DataService.instance.REF_USERS
        
        
//                    let db = Firestore.firestore()
//                    var firestoreCount = 0
//
//
//
//                    // Firestore migration - get `spots` table
//                    db.collection("users").getDocuments() { (querySnapshot, err) in
//                        if let err = err {
//                            print("DEBUG: Error getting documents: \(err)")
//                        } else {
//                            print("DEBUG: firstore spot count = \(querySnapshot!.documents.count)")
//                            for document in querySnapshot!.documents {
//                                print("DEBUG: \(document.documentID) => \(document.data())")
//                            }
//                        }
//                    }
//
//        print("DEBUG: firestoreCount = \(firestoreCount)")
        
        
//        if let dict = snap.value as? Dictionary<String, AnyObject>{

        // Firestore migration - post `spots` table
//                                   var ref: DocumentReference? = nil
//                                   ref = db.collection("users").addDocument(data: dict) { err in
//                                       if let err = err {
//                                           print("here123 - Error adding document: \(err)")
//                                       } else {
//                                           firestoreCount += 1
//                                           print("here123 - Document added with ID: \(ref!.documentID)")
//                                       }
//                                   }
//
//                    }
        
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key
                    if let userDict = snap.childSnapshot(forPath: "profile").value as? Dictionary<String, AnyObject> {
                        let user = User(userKey: key, userData: userDict)
                        if user.userKey != self.currentUserKey {
                            self.users.append(user)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.userTableView.reloadData()
                }
                
            }
        })
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileVC = segue.destination as? ProfileVC {
            if Auth.auth().currentUser!.uid == self.selectedUser!.userKey {
                profileVC.userKey = nil
            } else {
                profileVC.userKey = self.selectedUser!.userKey
            }
            
            
        }
    }
}
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredUsers.count > 0 {
            return filteredUsers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userTableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        
        let filteredUser = filteredUsers[indexPath.row]
        
        cell.configureCell(user: filteredUser)
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        self.selectedUser = filteredUsers[indexPath.row]
        performSegue(withIdentifier: "segueToProfileVC", sender: self)
    }
}

extension SearchVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredUsers = users.filter { filteredUser in
                return filteredUser.userName.lowercased().contains(searchText.lowercased())
            }
           // userTableView.reloadData()
        }
    userTableView.reloadData()
    
    }
}
