//
//  PlaceholderDetailVC.swift
//  iOS Example
//
//  Created by James Barrow on 11/06/2015.
//  Copyright © 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit

class PlaceholderDetailVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        label.font = UIFont.fontAwesome(ofSize: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = FontAwesome.longArrowLeft
        navigationItem.titleView = label
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
