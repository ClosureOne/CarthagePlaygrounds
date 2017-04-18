//
//  ViewController.swift
//  Example
//
//  Created by Richard Nees on 18.04.17.
//  Copyright © 2017 Richard Nees. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let reachabilityManager = NetworkReachabilityManager()
        if let isNetworkReachable = reachabilityManager?.isReachable {
            label.text = isNetworkReachable
            ? "We have a connection"
            : "We don't have a connection"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

