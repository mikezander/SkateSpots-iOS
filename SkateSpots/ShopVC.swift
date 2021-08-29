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
    }
    
    @IBAction func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
        }
    }
}
