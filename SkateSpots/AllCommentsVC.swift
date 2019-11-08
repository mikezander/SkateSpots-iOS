//
//  AllCommentsVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/8/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit

class AllCommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var comments = [Comment]()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
}
