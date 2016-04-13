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
    
    let randomAddressDictionaries = [
        ["latitude": 59.314446, "longitude": 18.074375, "name": "Frostlight Solutions AB", "simpleAddress": "Folkungagatan 49, 11622 Stockholm, SWEDEN"],
        ["latitude": 59.31896678, "longitude": 18.04416434],
        ["latitude": 59.29050261, "longitude": 18.07619457],
        ["latitude": 59.29147627, "longitude": 18.07859017],
        ["latitude": 59.30587091, "longitude": 18.02888337],
        ["latitude": 59.3271086, "longitude": 18.06120245],
        ["latitude": 59.30327769, "longitude": 18.05254242],
        ["latitude": 59.31181011, "longitude": 18.07480798],
        ["latitude": 59.34258002, "longitude": 18.08315992],
        ["latitude": 59.30417451, "longitude": 18.09245279],
        ["latitude": 59.28905485, "longitude": 18.07463282]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var addresses = [Address]()
        for addressDictionary in randomAddressDictionaries {
            
            let address = Address(dictionary: addressDictionary)
            addresses.append(address)
        }
        
        mapController.plotAddresses(addresses)
    }
    
}
