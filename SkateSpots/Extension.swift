//
//  Extension.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

extension UIImageView{

    func loadImageUsingCacheWithUrlString(urlString: String){
    
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        
            }.resume()
        
    }
}
