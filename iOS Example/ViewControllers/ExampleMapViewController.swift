//
//  ExampleMapViewController.swift
//  iOS Example
//
//  Created by James Barrow on 07/02/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import FrostKit
import CoreLocation

class ExampleMapViewController: MapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let addressDictionary = ["latitude": 59.314446, "longitude": 18.074375, "name": "Frostlight Solutions AB", "simpleAddress": "Folkungagatan 49, 11622 Stockholm, SWEDEN"]
        let address = Address(dictionary: addressDictionary)
        mapController.plotAddress(address)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
