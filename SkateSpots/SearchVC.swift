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
    
    @IBOutlet weak var userTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        userTableView.tableHeaderView = searchController.searchBar
        
        retrieveUsers()
        
    }
    
    func retrieveUsers() {
        let usersRef = DataService.instance.REF_USERS
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let key = snap.key
                    if let userDict = snap.childSnapshot(forPath: "profile").value as? Dictionary<String, AnyObject> {
                        let user = User(userKey: key, userData: userDict)
                        self.users.append(user)
                    }
                }
                
                DispatchQueue.main.async {
                    self.userTableView.reloadData()
                }
                
            }
        })
            
    }
}
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userTableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        
        let filteredUser = filteredUsers[indexPath.row]
        
        cell.configureCell(user: filteredUser)
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
    }
}

extension SearchVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredUsers = users.filter { filteredUser in
                return filteredUser.userName.lowercased().contains(searchText.lowercased())
            }
            userTableView.reloadData()
        }
    }
}
