//
//  Extension.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

let imageCache: NSCache<NSString, UIImage> = NSCache()

extension UIImageView {

    func loadImageUsingCacheWithUrlString(urlString: String){
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString){
            self.image = cachedImage
            return
        }
    
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = UIImage(data: data!)
                }
            }
        
        }.resume()
        
    }
}
