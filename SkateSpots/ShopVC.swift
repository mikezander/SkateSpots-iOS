//
//  ShopVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 8/28/21.
//  Copyright © 2021 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ShopVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let url = URL(string: "https://sk8spots.square.site")!
    
    override func viewDidLoad() {
        webView.loadRequest(URLRequest(url: url))
//        webView.load(URLRequest(url: url))
    }
    
    @IBAction func backButtonPressed() {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
