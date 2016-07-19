//
//  MapClusterTests.swift
//  FrostKit
//
//  Created by James Barrow on 11/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import MapKit
@testable import FrostKit

class MapClusterTests: XCTestCase {
    
    let mapView = MKMapView()
    let mapController = MapController()
    let mapVC = UIViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mapController.mapView = mapView
        mapController.viewController = mapVC
        
        let randomAddressDictionaries = [
            ["latitude": 59.31444600, "longitude": 18.07437500],
            ["latitude": 59.31896678, "longitude": 18.04416434],
            ["latitude": 59.29050261, "longitude": 18.07619457],
            ["latitude": 59.29147627, "longitude": 18.07859017],
            ["latitude": 59.30587091, "longitude": 18.02888337],
            ["latitude": 59.32710860, "longitude": 18.06120245],
            ["latitude": 59.30327769, "longitude": 18.05254242],
            ["latitude": 59.31181011, "longitude": 18.07480798],
            ["latitude": 59.34258002, "longitude": 18.08315992],
            ["latitude": 59.30417451, "longitude": 18.09245279],
            ["latitude": 59.28905485, "longitude": 18.07463282]
        ]
        
        var addresses = [Address]()
        for addressDictionary in randomAddressDictionaries {
            let address = Address(dictionary: addressDictionary)
            addresses.append(address)
        }
        mapController.plot(addresses: addresses)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClusterAnnotationsCalculations() {
        
        measure {
            
            let expectation = self.expectation(description: "calculateAndUpdateClusterAnnotations")
            
            self.mapController.calculateAndUpdateClusterAnnotations {
                
                XCTAssert(true, "Clusters calculated and updated")
                expectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 120) { (error) in
                XCTAssertNil(error, "Error")
            }
        }
    }
    
}
