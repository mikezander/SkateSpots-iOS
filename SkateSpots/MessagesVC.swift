//
//  MessagesVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/20/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class MessagesVC: UIViewController{

    @IBOutlet weak var messagesCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        
    }
}

extension MessagesVC: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath)
        
        return cell
    }

}
